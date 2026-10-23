extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game

func _initialize() -> void:
	if not "--balance-test" in OS.get_cmdline_user_args():
		quit(1)
		return
	run.call_deferred()

func setup() -> void:
	game.new_battle()
	game.friendly = [{},{},{},{}]
	game.enemy = [{},{},{},{}]
	game.enemy_hand = []
	game.enemy_deck = []
	game.enemy_discard = []
	game.energy = 8
	game.souls = 9

func run() -> void:
	Engine.time_scale = 80
	game = Game.new()
	root.add_child(game)
	game.cinematic_enabled = false
	AudioServer.set_bus_mute(0,true)
	for id in Cards.CATALOG_SIZE:
		if Cards.base_id(id)!=14: continue
		setup()
		game.hand = [2,id]
		game.selected = 0
		await game.play_card(0)
		game.energy = 8
		game.selected = 0
		await game.play_card(1)
		assert(game.friendly[1].ready and not game.friendly[0].ready)
		assert(game.Squads.active(game.friendly).any(func(combo): return combo.name=="NIGHT HUNT"))
		assert(game.enemy_hp==30,"Ambush attacks in the first combat phase, not during placement")
		await game.end_turn()
		assert(game.enemy_hp==30-Cards.DATA[id].atk*Cards.DATA[id].get("strikes",1),"Every Spectre variant attacks on first End Turn")
	setup()
	game.friendly[0] = Cards.unit(2,true)
	game.friendly[0].hp = 3
	var incoming := Cards.leveled_id(14,7)
	var original: Array = game.friendly.duplicate(true)
	var preview: Dictionary = game.reinforcement_preview(0,incoming)
	assert(game.friendly==original,"Preview must not modify live cards")
	game.hand = [incoming]
	game.selected = 0
	await game.play_card(0)
	assert(game.friendly[0]==preview.unit and game.hand.is_empty())
	assert(Cards.base_id(game.friendly[0].id)==2 and not game.friendly[0].ready)
	assert(game.Squads.active(game.friendly).is_empty(),"Consumed Spectre cannot activate Night Hunt")
	await game.end_turn()
	assert(game.enemy_hp==30,"Reinforcement does not grant Ambush to Pinky")
	print("PASS: Spectre and all rarity variants attack first End Turn with Night Hunt; reinforcement preview matches actual stats, preserves state, and does not transfer Ambush or create a squad")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	await process_frame
	quit()
