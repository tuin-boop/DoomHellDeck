extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")

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
	assert(Cards.CATALOG_SIZE==155 and Cards.DATA.size()==1550)
	assert(Cards.PACK.DATA.size()==63 and Squads.COMBOS.size()==19)
	var old_collection: Array = []
	old_collection.resize(82)
	old_collection.fill(3)
	assert(game.apply_saved_progress({"version":1,"wins":3,"credits":321,"collection":old_collection,"deck":Cards.STARTER.duplicate()}))
	assert(game.collection.size()==Cards.CATALOG_SIZE and game.decklist==Cards.STARTER and game.credits==321 and game.wins==3)
	assert(Cards.pack_starter().size()==20 and Cards.pack_starter().all(func(id): return id>=0 and id<145))
	game.wins = 0
	for id in range(82,145):
		var card: Dictionary = Cards.DATA[id]
		assert(Cards.by_actor(card.actor)==id)
		for bank in [game.art.textures,game.art.attack_textures,game.art.side_textures,game.art.side_attack_textures]:
			assert(bank.has(card.art) and not bank[card.art].is_empty())
		# These source actors have one idle pose and use the renderer's floating motion.
		var single_pose: bool = card.actor in ["GuardianCube","DarkCaco","Abaddon","Incarnate","Aracnorb","SupremeMind","AracnorbQueen"]
		assert(single_pose or game.art.textures[card.art].size()>1,"Armory needs the animated cycle: "+card.actor)
		assert(single_pose or game.art.side_textures[card.art].size()>1,"Side view needs the animated cycle: "+card.actor)
		for event in game.art.monster_sounds[card.art]:
			for path in game.art.monster_sounds[card.art][event]:
				assert(game.art.sounds[path] is AudioStream and game.art.sounds[path].get_length()>0)
		var prism := Cards.leveled_id(id,10)
		assert(Cards.DATA[prism].actor==card.actor and Cards.DATA[prism].level==10)
		game.new_battle()
		game.hand = [id]
		game.energy = 8
		game.selected = 0
		await game.play_card(0)
		assert(game.hand.is_empty() and game.energy==8-card.cost and game.friendly[0].id==id)
		assert(not game.friendly[0].ready,"New pack units retain summon delay")
		game.friendly[0].ready = true
		game.enemy = [Cards.unit(16),{},{},{}]
		game.enemy[0].hp = 100
		await game.attack(0,0)
		assert(game.enemy[0].hp<100,"Every selected unit attacks through the real battle code")
	# Shields prevent chill, and chilling lasts exactly one complete attack phase.
	game.new_battle()
	game.friendly = [Cards.unit(Cards.by_actor("ScientistFreeze")),{},{},{}]
	game.enemy = [Cards.unit(5),{},{},{}]
	await game.attack(0,0)
	assert(not game.enemy[0].get("chilled",false) and not game.enemy[0].shield)
	await game.attack(0,0)
	assert(game.enemy[0].get("chilled",false))
	game.friendly = [{},{},{},{}]
	var before: int = game.player_hp
	await game.attack(1,0)
	assert(game.player_hp==before-1 and not game.enemy[0].get("chilled",false))
	# Both factions receive drain healing, but never from a blocked hit.
	for side in 2:
		game.new_battle()
		var attacker := Cards.unit(Cards.by_actor("BloodFiend"))
		game.friendly = [attacker,{},{},{}] if side==0 else [Cards.unit(5),{},{},{}]
		game.enemy = [Cards.unit(5),{},{},{}] if side==0 else [attacker,{},{},{}]
		game.player_hp = 20
		game.enemy_hp = 20
		await game.attack(side,0)
		assert((game.player_hp if side==0 else game.enemy_hp)==20)
		await game.attack(side,0)
		assert((game.player_hp if side==0 else game.enemy_hp)==21)
	game.new_battle()
	game.friendly = [Cards.unit(Cards.by_actor("SoulHarvester")),{},{},{}]
	game.enemy = [Cards.unit(1),{},{},{}]
	game.enemy[0].hp = 1
	await game.attack(0,0)
	assert(game.souls==2,"Soul Harvester grants the additional kill Soul")
	game.modal = "collection"
	game.modal_click(game.PACK_FILTER.get_center())
	assert(game.pack_only and game.armory_count()==Cards.CATALOG_SIZE-Cards.LEGACY_SIZE and game.collection_page==0)
	game.decklist.pop_back()
	game.modal_click(game.collection_rect(0).get_center())
	assert(game.decklist.back()==82,"Filtered Armory uses correct IDs")
	game.modal_click(Vector2(500,840))
	assert(game.decklist==Cards.pack_starter(),"Mix starter is an explicit Armory action")
	for encounter in 5:
		var deck: Array = game.EnemyAI.deck_for(encounter)
		assert(deck.size()==20 and game.DeckRules.issue(deck).is_empty() and deck.filter(func(id): return id>=82).size()>=3)
	print("PASS: all 63 selections playable, 4 sprite banks each, imported audio, level 10, old save migration, chill, shield blocking, drain on both sides, Soul Harvester, filtered Armory, Mix starter and CPU decks")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	# Fixed-fps headless tests run faster than the audio mixing thread.
	OS.delay_msec(200)
	await process_frame
	game.queue_free()
	await process_frame
	await process_frame
	quit()
