extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	Engine.time_scale = 1 if "--visual-test" in OS.get_cmdline_user_args() else 80
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	var count := 0
	for id in range(82,145):
		var key: String = game.projectile_key(id)
		if not key.begins_with("MMM_SHOT_"): continue
		count += 1
		assert(not game.art.effect_textures[key].is_empty() and not game.art.side_effect_textures[key].is_empty())
		if Cards.DATA[id].has("impact"):
			assert(not game.art.effect_textures[Cards.DATA[id].impact].is_empty())
	assert(count==46)
	var mini := Cards.by_actor("Demolitron")
	assert(Cards.DATA[mini].type=="BULLET" and Cards.DATA[mini].strikes==2 and Cards.DATA[mini].splash==0)
	assert(game.art.attack_textures[Cards.DATA[mini].art].size()==7)
	game.minigun_firing = true
	assert(game.attack_frame(mini,game.attack_pose_duration,3)==1)
	assert(game.attack_frame(mini,game.attack_pose_duration+0.09,3)==2)
	game.minigun_firing = false
	if "--visual-test" in OS.get_cmdline_user_args():
		game.cinematic_enabled = true
		game.friendly = [Cards.unit(mini),{},{},{}]
		game.enemy = [Cards.unit(1),{},{},{}]
		game.friendly[0].hp = 100
		game.enemy[0].hp = 100
		game.attack(0,0)
		while not game.minigun_firing: await process_frame
		await create_timer(0.06).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/demolitron-burst.png")
		while game.moving_side>=0: await process_frame
	else:
		for cinema in [false,true]:
			for side in [0,1]:
				game.cinematic_enabled = cinema
				game.friendly = [Cards.unit(mini if side==0 else 1),{},{},{}]
				game.enemy = [Cards.unit(1 if side==0 else mini),{},{},{}]
				game.friendly[0].hp = 100
				game.enemy[0].hp = 100
				await game.attack(side,0)
				assert(game.friendly[0].hp==(98 if side==0 else 96) and game.enemy[0].hp==(96 if side==0 else 98),"Dual miniguns deal two 2-damage strikes and take two counters")
				assert(not game.minigun_firing and not game.duel_active)
	print("PASS: 46 native projectile banks, firing loop frames, Demolitron dual bullet bursts, two strikes/two counters on both sides/views")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	game.queue_free()
	await process_frame
	quit()
