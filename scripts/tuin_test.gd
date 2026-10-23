extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	Engine.time_scale = 12
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	game.chosen_commander = "tuin"
	game.new_battle()
	var power = game.hero_power
	game.friendly = [Cards.unit(1),{},{},{}]
	game.enemy = [Cards.unit(1),{},{},{}]
	game.souls = 5
	assert(game.player_commander=="tuin" and game.enemy_commander!="tuin")
	assert(power.target_at(game.lane_rect(0,0).get_center())==0)
	assert(power.target_at(game.lane_rect(1,0).get_center())==-1)
	await power.activate(0,4)
	await power.activate(0,1)
	assert(game.souls==5 and not power.used[0])
	game.friendly[0].shield = true
	var before: Dictionary = game.friendly[0].duplicate(true)
	await power.activate(0,0)
	before.hp += 2
	assert(game.friendly[0]==before,"Only health changes, including above starting health")
	assert(game.souls==0 and power.used[0] and not game.busy)
	game.souls = 10
	await power.activate(0,0)
	assert(game.souls==10 and game.friendly[0]==before)
	power.used[0] = false
	game.souls = 4
	await power.activate(0,0)
	assert(game.souls==4 and not power.used[0])
	game.enemy_commander = "tuin"
	power.cpu_souls = 5
	assert(power.target_at(game.lane_rect(1,0).get_center(),1)==0)
	assert(power.target_at(game.lane_rect(0,0).get_center(),1)==-1)
	var enemy_hp: int = game.enemy[0].hp
	game.busy = true
	await power.cpu_turn()
	assert(game.enemy[0].hp==enemy_hp+2 and game.friendly[0]==before)
	assert(power.cpu_souls==0 and power.used[1])
	power.used[1] = false
	power.cpu_souls = 5
	game.enemy = [{},{},{},{}]
	await power.cpu_turn()
	assert(power.cpu_souls==5 and not power.used[1])
	if "--visual-test" in OS.get_cmdline_user_args():
		Engine.time_scale = 1
		game.busy = false
		game.souls = 5
		power.armed = true
		power.pointer = game.lane_rect(0,0).get_center()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/tuin-targeting.png")
		game.open_commanders()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/tuin-chooser.png")
	print("PASS: Tuin support targeting, permanent +2 HP, shields preserved, invalid targets, cost, once per round, CPU friendly buff and empty board")
	game.queue_free()
	await process_frame
	quit()
