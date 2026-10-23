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
	for side in 2:
		game.new_battle()
		var squad: Array = [Cards.unit(3),Cards.unit(15),{},Cards.unit(1)]
		squad[0].hp = 1
		game.friendly = squad if side==0 else [Cards.unit(8),{},{},{}]
		game.enemy = [Cards.unit(8),{},{},{}] if side==0 else squad
		game.enemy_hand = []
		game.enemy_deck = []
		game.enemy_discard = []
		game.enemy_energy = 0
		assert(Squads.bonus(squad,1,"attack")==1)
		await game.end_turn()
		assert(squad[0].is_empty(),"First member dies before later squad attacks")
		assert((game.enemy_hp if side==0 else game.player_hp)==21,"Survivors retain +1: Chaingunner 3x2 plus Zombieman 3")
		assert(Squads.bonus(squad,1,"attack")==0 and not squad[1].has("combat_attack"),"Broken squad loses bonus after End Turn")
	var row: Array = [Cards.unit(0),Cards.unit(18),{},{ }]
	Squads.lock_combat(row)
	row[0] = {}
	assert(Squads.bonus(row,1,"breach")==1)
	row[0] = Cards.unit(1)
	assert(Squads.bonus(row,0,"breach")==0,"Replacement does not inherit dead member's bonus")
	Squads.clear_combat(row)
	assert(Squads.bonus(row,1,"breach")==0)
	print("PASS: player and CPU keep squad damage after an early death through the whole End Turn; bonuses expire and replacements do not inherit them")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	await process_frame
	quit()
