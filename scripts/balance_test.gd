extends SceneTree
## Runs the real battle code: no alternate combat simulator or preview of enemy intent.
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const DiverseDecks = preload("res://scripts/diverse_decks.gd")
var game
var results: Array = []
var plays: Dictionary = {}
var card_games: Dictionary = {}
var card_wins: Dictionary = {}
var drawn: Dictionary = {}
var actions: Dictionary = {}

func _initialize() -> void:
	if not "--balance-test" in OS.get_cmdline_user_args():
		push_error("Use --balance-test to protect normal saves")
		quit(1)
		return
	run.call_deferred()

func variant(base: int, tier: int) -> int:
	for id in Cards.DATA.size():
		if Cards.DATA[id].get("base_id",-1) == base and Cards.DATA[id].rarity == tier:
			return id
	return base

func decks() -> Dictionary:
	return {
		"Starter": Cards.STARTER.duplicate(),
		"Cheap pressure": [0,0,0,1,1,2,2,2,3,3,4,4,14,14,14,15,15,16,10,11],
		"Heavy weapons": [0,0,1,2,3,14,15,16,5,6,7,8,9,10,11,17,18,19,21,22],
		"Rare and Elite": [0,0,1,2,3,14,10,11,variant(0,1),variant(2,1),variant(5,1),variant(14,1),variant(17,1),variant(0,4),variant(2,4),variant(3,4),variant(14,4),variant(15,4),variant(19,4),variant(21,4)],
		"Mythic and Souls": [0,0,1,2,3,14,10,11,11,11,23,23,13,7,variant(0,5),variant(2,5),variant(14,5),variant(15,5),variant(19,5),variant(21,5)]
	}

func run() -> void:
	Engine.time_scale = 80.0
	game = Game.new()
	root.add_child(game)
	game.cinematic_enabled = false
	# Same code paths and animations, accelerated. Audio muted for unattended testing.
	AudioServer.set_bus_mute(0,true)
	if "--cheese-cost-trial" in OS.get_cmdline_user_args():
		for card in Cards.DATA:
			if card.get("actor","")=="D3PistolMan": card.cost = mini(8,3+int(card.level/4))
	var setups := {"Mirror":game.EnemyAI.DECK.duplicate()} if "--mirror" in OS.get_cmdline_user_args() else decks()
	var seed_start := 2026101400 if "--holdout" in OS.get_cmdline_user_args() else 2026101300
	var output_path := "res://reports/balance-final-"+("mirror" if "--mirror" in OS.get_cmdline_user_args() else ("holdout" if "--holdout" in OS.get_cmdline_user_args() else "training"))+".json"
	var games_per_deck := 10
	if "--hundred" in OS.get_cmdline_user_args():
		setups = decks()
		games_per_deck = 20
		seed_start = 2026101500
		output_path = "res://reports/balance-100-matches.json"
	if "--retaliation-hundred" in OS.get_cmdline_user_args():
		setups = {
			"UAC Starter": Cards.STARTER.duplicate(),
			"Monster Mix": Cards.pack_starter(),
			"Cheap pressure": game.DeckRules.legalize(decks()["Cheap pressure"]),
			"Rare and Elite": game.DeckRules.legalize(decks()["Rare and Elite"]),
			"Mythic and Souls": game.DeckRules.legalize(decks()["Mythic and Souls"])
		}
		games_per_deck = 20
		seed_start = 2026101600
		output_path = "res://reports/balance-retaliation-squads-100.json"
	var comparison: Dictionary = {}
	if "--tuned" in OS.get_cmdline_user_args():
		comparison = JSON.parse_string(FileAccess.get_file_as_string("res://reports/balance-retaliation-squads-100.json"))
		setups = comparison.decks
		output_path = "res://reports/balance-retaliation-squads-tuned-100.json"
	var diverse := "--diverse-hundred" in OS.get_cmdline_user_args()
	var seen_cpu := {}
	var budget_recheck: Dictionary = {}
	if "--budget-recheck" in OS.get_cmdline_user_args():
		budget_recheck = JSON.parse_string(FileAccess.get_file_as_string("res://reports/balance-deck-budget-100.json"))
	if diverse:
		setups = DiverseDecks.generate()
		games_per_deck = 1
		seed_start = 2026101800
		output_path = "res://reports/balance-100-distinct-decks.json"
	var diverse_replay: Dictionary = {}
	if "--diverse-tuned" in OS.get_cmdline_user_args():
		diverse_replay = JSON.parse_string(FileAccess.get_file_as_string("res://reports/balance-100-distinct-decks.json"))
		setups = {}
		for prior in diverse_replay.matches:
			setups[prior.deck] = diverse_replay.decks[prior.deck].map(func(id): return int(id))
		games_per_deck = 1
		seed_start = int(diverse_replay.seed_start)
		output_path = "res://reports/balance-100-distinct-decks-tuned.json"
	var focus := "--focus-hundred" in OS.get_cmdline_user_args()
	if focus:
		var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://reports/balance-100-distinct-decks-tuned.json"))
		setups = {}
		for prior in source.matches:
			if prior.deck.begins_with("Mythic ") or prior.deck.begins_with("Cheap pressure "):
				setups[prior.deck] = source.decks[prior.deck].map(func(id): return int(id))
		games_per_deck = 5
		seed_start = 2026101900
		output_path = "res://reports/balance-mythic-pressure-focus-100.json"
	# Repeated all-style audit. Shards are independent processes with disjoint decks.
	var audit := "--audit" in OS.get_cmdline_user_args()
	if audit:
		var source: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://reports/balance-100-distinct-decks-tuned.json"))
		var shard := 0
		var audit_tag := "baseline"
		var fresh := false
		var audit_round := 1
		for arg in OS.get_cmdline_user_args():
			if arg.begins_with("--shard="): shard = int(arg.get_slice("=",1))
			if arg.begins_with("--audit-tag="): audit_tag = arg.get_slice("=",1)
			if arg=="--fresh": fresh = true
			if arg.begins_with("--audit-round="): audit_round = int(arg.get_slice("=",1))
		assert(shard in [0,1])
		var all_setups: Dictionary = DiverseDecks.generate(2026102300) if fresh else source.decks
		var names: Array = all_setups.keys()
		names.sort()
		setups = {}
		for i in names.size():
			if i % 2 == shard: setups[names[i]] = all_setups[names[i]].map(func(id): return int(id))
		games_per_deck = 5
		seed_start = (2026102400 if fresh else 2026102000) + (audit_round-1)*1000
		output_path = "res://reports/balance-audit-%s-%d.json" % [audit_tag,shard]
	if "--starter-check" in OS.get_cmdline_user_args():
		setups = {"UAC Starter":Cards.STARTER.duplicate(),"Squad Starter":Cards.SQUAD_STARTER.duplicate()}
		games_per_deck = 50
		seed_start = 2026104000
		output_path = "res://reports/balance-starter-comparison.json"
	var wolf_audit := "--wolf-hundred" in OS.get_cmdline_user_args()
	var wolf_opponents := {}
	if wolf_audit:
		setups = {}
		var profiles := {"Mecha-Hitler":[145],"Schabbs":[146,146],"Hans":[147],"Demolitron":[Cards.by_actor("Demolitron")],"Mixed Wolf guns":[145,146,146,147,Cards.by_actor("Demolitron")]}
		var focus_ids: Array = [145,146,147,Cards.by_actor("Demolitron")]
		var profile_index := 0
		for profile in profiles:
			var control: Array = game.EnemyAI.deck_for(0,2026105100+profile_index).filter(func(id): return id not in focus_ids)
			control = game.DeckRules.legalize(control)
			# Put required cards first so budget legalization cannot silently omit them.
			var featured: Array = profiles[profile].duplicate()
			for card in control:
				if game.DeckRules.issue(featured+[card],[],false).is_empty() and game.DeckRules.cheapest_fill(featured+[card],[],true,true).size()==20:
					featured.append(card)
			featured = game.DeckRules.cheapest_fill(featured,[],true,true)
			for id in profiles[profile]: assert(featured.count(id)>=profiles[profile].count(id))
			setups[profile+" / player"] = featured
			wolf_opponents[profile+" / player"] = control
			setups[profile+" / cpu"] = control
			wolf_opponents[profile+" / cpu"] = featured
			profile_index += 1
		games_per_deck = 10
		seed_start = 2026105200
		output_path = "res://reports/balance-wolf-demolitron-100.json"
	if "--wolf-tuned" in OS.get_cmdline_user_args():
		wolf_audit = true
		var previous: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://reports/balance-wolf-demolitron-100.json"))
		setups = previous.decks
		for name in setups: setups[name] = setups[name].map(func(id): return int(id))
		for prior in previous.matches: wolf_opponents[prior.deck] = prior.cpu_deck.map(func(id): return int(id))
		games_per_deck = 10
		seed_start = int(previous.seed_start)
		output_path = "res://reports/balance-wolf-demolitron-tuned-100.json"
		if "--wolf-final" in OS.get_cmdline_user_args(): output_path = "res://reports/balance-wolf-demolitron-final-100.json"
	if "--budget-hundred" in OS.get_cmdline_user_args():
		setups = DiverseDecks.generate(2026106100)
		diverse = true
		games_per_deck = 1
		seed_start = 2026106200
		output_path = "res://reports/balance-deck-budget-100.json"
	if "--mythic-review" in OS.get_cmdline_user_args():
		setups = DiverseDecks.generate(2026107100,["Mythic","Rare"])
		games_per_deck = 5
		seed_start = 2026107200
		output_path = "res://reports/balance-mythic-rare-review-100.json"
	if "--weapon-hundred" in OS.get_cmdline_user_args():
		wolf_audit = true
		setups = {}
		var profiles := {"Pistol":[150,150],"Shotgun":[151,151],"Super Shotgun":[152,152],"Chaingun":[153,153],"Rocket Launcher":[154,154],"Plasma Gun":[149,149],"BFG":[9],"Light weapons":[150,151,153],"Heavy weapons":[149,152,154],"Weapon heavy":[150,151,152,153,154,149]}
		var profile_index := 0
		for profile in profiles:
			var control: Array = game.EnemyAI.deck_for(0,2026109100+profile_index,false)
			var featured: Array = profiles[profile].duplicate()
			for card in control:
				if game.DeckRules.issue(featured+[card],[],false).is_empty() and game.DeckRules.cheapest_fill(featured+[card],[],true,true).size()==20:
					featured.append(card)
			featured = game.DeckRules.cheapest_fill(featured,[],true,true)
			for id in profiles[profile]: assert(featured.count(id)>=profiles[profile].count(id))
			setups[profile+" / player"] = featured
			wolf_opponents[profile+" / player"] = control
			setups[profile+" / cpu"] = control
			wolf_opponents[profile+" / cpu"] = featured
			profile_index += 1
		games_per_deck = 5
		seed_start = 2026109200
		output_path = "res://reports/balance-weapons-100.json"
		if "--weapon-holdout" in OS.get_cmdline_user_args():
			seed_start += 100
			output_path = "res://reports/balance-weapons-holdout-100.json"
	if "--cheese-hundred" in OS.get_cmdline_user_args():
		var cheese = preload("res://scripts/cheese_decks.gd")
		wolf_audit = true
		setups = {}
		var n := 0
		for style in cheese.STYLES:
			for version in 2:
				var featured: Array = cheese.build(style,version)
				var control: Array = game.EnemyAI.deck_for(0,2026101950+n)
				var label: String = style+" v"+str(version+1)
				setups[label+" / player"] = featured
				wolf_opponents[label+" / player"] = control
				setups[label+" / cpu"] = control
				wolf_opponents[label+" / cpu"] = featured
				n += 1
		games_per_deck = 5
		seed_start = 2026101960
		output_path = "res://reports/balance-cheese-100.json"
		if "--cheese-cost-trial" in OS.get_cmdline_user_args(): output_path = "res://reports/balance-cheese-cost-trial-100.json"
	for name in setups:
		setups[name] = game.DeckRules.legalize(setups[name])
		assert(setups[name].size() == 20)
		assert(game.DeckRules.issue(setups[name]).is_empty(),"Test decks must obey current rules")
		for repeat in games_per_deck:
			var match_seed := seed_start+(results.size() if diverse else repeat)
			if not diverse_replay.is_empty():
				match_seed = int(diverse_replay.matches[results.size()].seed)
			seed(match_seed)
			game.rng.seed = match_seed
			game.decklist = setups[name].duplicate()
			game.deck_book.entries[0].cards = setups[name].duplicate()
			game.deck_book.active = 0
			game.wins = 0
			game.new_battle()
			# Seed CPU composition too; live deck generation intentionally randomizes.
			var cpu_list: Array = game.EnemyAI.deck_for(0,match_seed+700)
			if diverse:
				var attempt := 0
				while seen_cpu.has(DiverseDecks.fingerprint(cpu_list)):
					attempt += 1
					assert(attempt<1000)
					cpu_list = game.EnemyAI.deck_for(0,match_seed+700+attempt*123)
				seen_cpu[DiverseDecks.fingerprint(cpu_list)] = true
			if not comparison.is_empty():
				cpu_list = comparison.matches[repeat].cpu_deck.map(func(id): return int(id))
			if not diverse_replay.is_empty():
				assert(diverse_replay.matches[results.size()].deck == name)
				cpu_list = diverse_replay.matches[results.size()].cpu_deck.map(func(id): return int(id))
			if wolf_audit: cpu_list = wolf_opponents[name].duplicate()
			if not budget_recheck.is_empty():
				var prior: Dictionary = budget_recheck.matches[results.size()]
				assert(prior.deck==name and int(prior.seed)==match_seed)
				assert(budget_recheck.decks[name].map(func(id): return int(id))==setups[name])
				if prior.cpu_deck.map(func(id): return int(id))==cpu_list:
					results.append(prior)
					print("REUSED unchanged seeded match ",results.size())
					continue
			game.enemy_deck = cpu_list.duplicate()
			game.enemy_deck.shuffle()
			game.enemy_hand.clear()
			game.cpu_director.reset(match_seed+900)
			for draw in 5: game.draw_enemy_card()
			assert(game.DeckRules.issue(cpu_list).is_empty())
			plays = {}
			drawn = {}
			actions = {"surges":0,"revives":0,"idle_turns":0,"reinforcements":0,"squad_turns":0,"mythic_soul_blocked_turns":0,"mythic_energy_blocked_turns":0,"mythic_affordable_turns":0}
			var history: Array = []
			var end_reason := "combat"
			while not game.ended and game.turn <= 60:
				for id in game.hand:
					drawn[id] = true
				var mythics: Array = game.hand.filter(func(id): return Cards.DATA[id].rarity==5)
				if mythics.any(func(id): return Cards.DATA[id].get("soul_cost",0)>game.souls): actions.mythic_soul_blocked_turns += 1
				if mythics.any(func(id): return Cards.DATA[id].cost>game.energy): actions.mythic_energy_blocked_turns += 1
				if mythics.any(func(id): return Cards.DATA[id].cost<=game.energy and Cards.DATA[id].get("soul_cost",0)<=game.souls): actions.mythic_affordable_turns += 1
				var before: int = plays.values().reduce(func(total,n): return total+n,0)
				await choose_plays()
				if before == plays.values().reduce(func(total,n): return total+n,0):
					actions.idle_turns += 1
				if not game.Squads.active(game.friendly).is_empty(): actions.squad_turns += 1
				history.append({"turn":game.turn,"player_hp":game.player_hp,"enemy_hp":game.enemy_hp,"energy_unspent":game.energy,"souls":game.souls})
				if not game.ended:
					var previous_turn: int = game.turn
					await game.end_turn()
					if game.ended and game.turn > previous_turn:
						end_reason = "collapse"
			var outcome: String = "win" if game.ended and game.won else ("draw" if game.modal=="draw" or not game.ended else "loss")
			for id in plays:
				card_games[id] = card_games.get(id,0)+1
				card_wins[id] = card_wins.get(id,0)+(1 if outcome == "win" else 0)
			results.append({"deck":name,"cpu_deck":cpu_list,"seed":match_seed,"outcome":outcome,"end_reason":end_reason if game.ended else "round_limit","turns":mini(game.turn,60),"player_hp":maxi(0,game.player_hp),"enemy_hp":maxi(0,game.enemy_hp),"plays":plays.duplicate(),"seen_in_hand":drawn.keys(),"actions":actions.duplicate(),"cpu_plays":game.enemy_plays,"cpu_energy_spent":game.enemy_spent,"history":history})
			print("MATCH %02d | %s | %s | turn %d | HP %d:%d" % [results.size(),name,outcome,game.turn,maxi(0,game.player_hp),maxi(0,game.enemy_hp)])
	card_games = {}
	card_wins = {}
	for result in results:
		for id in result.plays:
			card_games[id] = card_games.get(id,0)+1
			card_wins[id] = card_wins.get(id,0)+int(result.outcome=="win")
	DirAccess.make_dir_recursive_absolute("res://reports")
	var file := FileAccess.open(output_path,FileAccess.WRITE)
	file.store_string(JSON.stringify({"matches":results,"decks":setups,"cards":Cards.DATA,"card_games_played":card_games,"card_wins_when_played":card_wins,"round_limit":60,"seed_start":seed_start,"opponent":"Draw director + Energy/deck Overseer, wins=0, 30 HP, empty starting board","policy":"Shared bounded placement search for both bots; player events use heuristic scoring; no enemy intent access; heal, BFG, resurrection and Soul Surge enabled"},"\t"))
	file.close()
	print("Saved "+output_path)
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	await process_frame
	game.queue_free()
	await process_frame
	await process_frame
	quit()

func score_card(id: int, lane: int) -> float:
	if game.Weapons.is_weapon(id): return game.Weapons.score(id,game.enemy,lane-4 if lane>=4 else lane)
	var data: Dictionary = Cards.DATA[id]
	if data.hp == 0:
		if id == 10:
			return minf(6,30-game.player_hp)*1.5-2.0
		if id == 11:
			return 6.0 if game.souls < 9 else -1.0
		if id == 9:
			var value := 0.0
			for unit in game.enemy:
				if not unit.is_empty():
					value += 1.0 if unit.shield else minf(unit.hp,4)*1.3+(3.0 if unit.hp <= 4 else 0.0)
			return value-6.0
		return -1.0
	var strikes: int = data.get("strikes",1)
	var value: float = data.atk*strikes+data.hp*0.5-data.cost*0.35
	if data.get("ambush",false):
		value += 2.5
	if data.get("starting_shield",false) or Cards.base_id(id)==5:
		value += 2.0
	value += float(data.get("armor",0))*1.5
	var enemy: Dictionary = game.enemy[lane]
	if not enemy.is_empty():
		var threat: Dictionary = Cards.DATA[enemy.id]
		value += threat.atk*threat.get("strikes",1)*1.5
		value += Cards.damage(id,enemy.id)*0.5
		if Cards.damage(enemy.id,id) >= data.hp and not data.get("ambush",false):
			value -= 3.5
	else:
		value += data.atk*strikes*0.35
	if id == 12:
		for adjacent in [lane-1,lane+1]:
			if adjacent >= 0 and adjacent < 4 and not game.friendly[adjacent].is_empty() and not game.friendly[adjacent].shield:
				value += 2.0
	return value

func choose_plays() -> void:
	# Isolate card costs from hero selection: neither bot spends Souls on powers.
	if "--cheese-hundred" in OS.get_cmdline_user_args(): game.hero_power.used = [true,true]
	for step in 24:
		if game.ended:
			return
		var weapon: Dictionary = game.Weapons.best(game.hand,game.enemy,game.energy)
		if weapon.id>=0:
			game.selected = game.hand.find(weapon.id)
			await game.play_card(-1 if weapon.id==9 else weapon.lane+4)
			plays[weapon.id] = plays.get(weapon.id,0)+1
			continue
		var best := 0.0
		var index := -1
		var lane := -1
		for i in game.hand.size():
			var id: int = game.hand[i]
			if not game.can_afford(id) or Cards.DATA[id].hp>0 or game.Weapons.is_weapon(id):
				continue
			for slot in ([-1] if Cards.DATA[id].hp==0 else [0,1,2,3]):
				if slot >= 0 and not game.friendly[slot].is_empty():
					continue
				var value := score_card(id,slot)
				if value > best:
					best = value
					index = i
					lane = slot
		if index >= 0:
			var id: int = game.hand[index]
			game.selected = index
			await game.play_card(lane)
			plays[id] = plays.get(id,0)+1
			continue
		var units: Array = game.hand.filter(func(id): return Cards.DATA[id].hp>0)
		var moves: Array = game.EnemyAI.plan(game.friendly,game.enemy,units,game.energy,game.player_hp,game.enemy_hp,game.souls)
		if not moves.is_empty():
			for move in moves:
				game.selected = game.hand.find(move.id)
				if not game.friendly[move.lane].is_empty(): actions.reinforcements += 1
				await game.play_card(move.lane)
				plays[move.id] = plays.get(move.id,0)+1
			continue
		if game.can_revive():
			game.revive()
			actions.revives += 1
			continue
		var surge := false
		if game.souls >= 3:
			for id in game.hand:
				if Cards.DATA[id].cost > game.energy and Cards.DATA[id].cost <= game.energy+2 and game.souls-3 >= Cards.DATA[id].get("soul_cost",0):
					for slot in ([-1] if Cards.DATA[id].hp==0 else [0,1,2,3]):
						if (slot < 0 or game.friendly[slot].is_empty()) and score_card(id,slot)>0:
							surge = true
		if surge:
			game.souls -= 3
			game.energy += 2
			actions.surges += 1
			continue
		return
