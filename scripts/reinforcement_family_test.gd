extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	Engine.time_scale = 80
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	var pinky := Cards.by_actor("VoidPinky")
	for level in range(1,11):
		var unit := Cards.unit(Cards.leveled_id(pinky,level))
		for id in Cards.DATA.size():
			if Cards.base_id(id) in [1,3,23]:
				assert(not Squads.can_reinforce(unit,id),"Human soldiers cannot reinforce Void Pinky at any level")
		assert(Squads.can_reinforce(unit,2) and Squads.can_reinforce(unit,14),"Pinky/Spectre reinforcement remains valid")
	game.enemy = [Cards.unit(pinky),Cards.unit(pinky),Cards.unit(pinky),Cards.unit(pinky)]
	game.enemy_hand = [3]
	game.enemy_energy = 8
	var before: Array = game.enemy.duplicate(true)
	var discard_before: Array = game.enemy_discard.duplicate()
	game.reinforce_lane(1,0,3)
	assert(game.enemy==before and game.enemy_discard==discard_before,"Invalid direct reinforcement is safely rejected")
	await game.deploy_enemy_cards()
	assert(game.enemy==before and game.enemy_hand==[3] and game.enemy_energy==8,"CPU cannot spend Shotgun Guy on any occupied Void Pinky lane")
	game.enemy[2] = {}
	game.friendly = [{},{},{},{}]
	await game.deploy_enemy_cards()
	assert(game.enemy[2].get("id",-1)==3 and not game.enemy[0].has("reinforced"),"Shotgun Guy deploys separately into an empty lane")
	game.enemy[0] = Cards.unit(pinky)
	game.reinforce_lane(1,0,2)
	assert(game.enemy[0].reinforced and game.feed[0].contains("PINKY reinforces VOID PINKY"),"Valid reinforcement names its supporting card and target")
	print("PASS: all soldier variants/levels rejected for Void Pinky, legal demon families accepted, direct guard, CPU spending, separate deployment, explicit reinforcement message")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	game.queue_free()
	await process_frame
	quit()
