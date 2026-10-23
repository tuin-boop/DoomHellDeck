extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
const Director = preload("res://scripts/draw_director.gd")

func _initialize() -> void:
	if not "--balance-test" in OS.get_cmdline_user_args():
		quit(1)
		return
	run.call_deferred()

func run() -> void:
	Engine.time_scale = 80
	var game = Game.new()
	root.add_child(game)
	game.cinematic_enabled = false
	AudioServer.set_bus_mute(0,true)
	assert(Cards.DATA.size()==Cards.CATALOG_SIZE*10 and game.collection.size()==Cards.CATALOG_SIZE)
	for id in Cards.CATALOG_SIZE:
		for level in range(1,11):
			var upgraded := Cards.leveled_id(id,level)
			assert(Cards.base_id(upgraded)==Cards.base_id(id))
			assert(Cards.DATA[upgraded].cost<=8)
			assert(Cards.leveled_id(upgraded,level)==upgraded,"No compounded upgrades")
	var director = Director.new()
	var prism := 0
	var total := 0
	for match_seed in 200:
		director.reset(match_seed)
		var match_prisms := 0
		for draw in 100:
			var level: int = director.roll_level(18,0)
			assert(level>=5 and level<=10)
			if level==10:
				prism += 1
				match_prisms += 1
			total += 1
		assert(match_prisms<=1)
	assert(prism>0 and prism<100,"Prism is rare, not guaranteed")
	director.reset(42)
	for draw in 20:
		assert(director.roll_level(1,20)==1,"No early comeback jackpots")
	for combo in Squads.COMBOS:
		var row: Array = [{},{},{},{}]
		for i in combo.groups.size():
			row[i] = Cards.unit(Cards.leveled_id(combo.groups[i][0],6))
		assert(not Squads.members(row,combo).is_empty())
		assert(Squads.bonus(row,0,combo.bonus)==1)
		row[0] = {}
		assert(Squads.members(row,combo).is_empty(),"Death breaks the formation")
	game.friendly = [Cards.unit(1,true),{},{},{}]
	game.friendly[0].hp = 2
	game.hand = [Cards.leveled_id(3,7),1]
	game.energy = 8
	game.selected = 0
	await game.play_card(0)
	assert(game.friendly[0].reinforced and not game.friendly[0].ready)
	assert(Cards.DATA[game.friendly[0].id].level==7 and game.friendly[0].hp==7)
	assert(game.energy==5 and game.hand==[1] and game.discard.size()==1)
	game.selected = 0
	await game.play_card(0)
	assert(game.energy==5 and game.hand==[1],"Cannot reinforce twice")
	game.friendly = [Cards.unit(16),Cards.unit(15),Cards.unit(18),{}]
	game.enemy = [Cards.unit(2),{},{},{}]
	var before: int = game.enemy[0].hp
	await game.attack(0,0)
	assert(game.enemy[0].hp==before-Cards.damage(16,2)-1,"Siege bonus reaches real combat")
	game.friendly = [Cards.unit(Cards.leveled_id(1,10)),{},{},{}]
	game.enemy = [Cards.unit(18),{},{},{}]
	before = game.enemy[0].hp
	await game.attack(0,0)
	assert(game.enemy[0].hp==before-Cards.damage(Cards.leveled_id(1,10),18)-1,"Prism strike reaches real combat")
	var board: Array = [Cards.unit(1),Cards.unit(1),Cards.unit(1),Cards.unit(1)]
	var moves: Array = game.EnemyAI.plan(board,[{},{},{},{}],[1],1,30,30)
	assert(not moves.is_empty(),"AI can reinforce a full board")
	assert(not board[0].get("reinforced",false),"AI search is non-mutating")
	game.enemy = board
	game.friendly = [{},{},{},{}]
	game.enemy_hand = [1]
	game.enemy_energy = 1
	await game.deploy_enemy_cards()
	assert(game.enemy_hand.is_empty() and game.enemy_energy==0 and game.enemy.any(func(u): return u.get("reinforced",false)))
	game.new_battle()
	assert(game.collection.size()==Cards.CATALOG_SIZE and game.hand.all(func(id): return id<Cards.CATALOG_SIZE),"Level rolls never enter collection or next opening hand")
	print("PASS: all level definitions, rare Prism distribution (%d/%d), all 18 formations, reinforcement costs/readiness/cap, real combo and Prism damage, CPU reinforcement, save isolation" % [prism,total])
	game.queue_free()
	await process_frame
	await process_frame
	quit()
