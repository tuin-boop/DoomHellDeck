extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func setup(id: String) -> void:
	game.chosen_commander = id
	game.new_battle()
	assert(game.player_commander==id and game.enemy_commander!=id)
	game.souls = 5
	game.player_hp = 20
	game.enemy = [Cards.unit(1),Cards.unit(1),Cards.unit(1),{}]
	for unit in game.enemy:
		if not unit.is_empty(): unit.hp = 10
func run() -> void:
	Engine.time_scale = 12
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	var power = game.hero_power
	assert(game.projectile_key(16)=="BAL7")
	assert(game.side_projectile_flipped("BAL7",0) and not game.side_projectile_flipped("BAL7",1),"Knight projectile faces its target on both sides, including counters")
	game.art.side_effect_textures["BAL7"][0].get_image().save_png("res://captures/knight-projectile-source.png")
	setup("oculus")
	power.activate(0,1)
	while power.attack_phase=="windup":
		assert(game.enemy[1].hp==10,"Anticipation never applies early damage")
		await process_frame
	while power.active: await process_frame
	assert(game.enemy[1].hp==7)
	for id in power.POWERS:
		if power.POWERS[id].has("buff_hp"): continue
		setup(id)
		var rule: Dictionary = power.POWERS[id]
		await power.activate(0,1)
		assert(game.enemy[1].hp==10-rule.damage)
		assert(game.enemy[0].hp==10-(1 if rule.get("volley",false) else rule.get("splash",0)) and game.enemy[2].hp==10-(1 if rule.get("volley",false) else rule.get("splash",0)))
		assert(game.player_hp==20+rule.get("heal",0),"No unit counter against a hero power")
		assert(power.target_at(game.lane_rect(0,1).get_center())==-1,"Player power cannot target a friendly lane")
		assert(game.souls==0 and power.used[0] and not game.busy and not power.active)
		game.souls = 10
		await power.activate(0,1)
		assert(game.souls==10,"Once per round cannot be bypassed")
		setup(id)
		var before: int = game.enemy_hp
		await power.activate(0,4)
		assert(game.enemy_hp==before-rule.hero)
	setup("ashfang")
	game.enemy[1].shield = true
	await power.activate(0,1)
	assert(game.enemy[1].hp==10 and not game.enemy[1].get("chilled",false))
	setup("goremaw")
	game.souls = 4
	await power.activate(0,1)
	assert(game.souls==4 and not power.used[0] and game.enemy[1].hp==10)
	game.souls = 5
	await power.activate(0,3)
	assert(game.souls==5 and not power.used[0],"Invalid targets never spend Souls")
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(128,185)
	assert(power.handle(click) and power.armed)
	var cancel := InputEventKey.new()
	cancel.keycode = KEY_ESCAPE
	cancel.pressed = true
	assert(power.handle(cancel) and not power.armed and game.souls==5)
	setup("graves")
	click.position = Vector2(128,185)
	click.pressed = true
	assert(power.handle(click))
	click.pressed = false
	assert(power.handle(click) and power.armed,"Click-release keeps targeting active")
	click.position = game.lane_rect(1,1).get_center()
	click.pressed = true
	assert(power.handle(click))
	while power.active: await process_frame
	assert(game.enemy[1].hp==7 and game.enemy[0].hp==9 and game.souls==0)
	setup("goremaw")
	click.position = Vector2(128,185)
	assert(power.handle(click))
	var motion := InputEventMouseMotion.new()
	motion.position = game.lane_rect(1,0).get_center()
	assert(power.handle(motion))
	click.position = motion.position
	click.pressed = false
	assert(power.handle(click))
	while power.active: await process_frame
	assert(game.enemy[0].hp==6 and game.souls==0,"Portrait drag/drop activates power")
	setup("ashfang")
	await power.activate(0,0)
	assert(game.enemy[0].get("chilled",false))
	setup("oculus")
	game.enemy[0] = Cards.unit(145)
	var copy: Dictionary = game.enemy[0].duplicate(true)
	Cards.receive_damage(copy,3)
	await power.activate(0,0)
	assert(game.enemy[0].hp==copy.hp,"Hero damage obeys armour and suit protection")
	setup("oculus")
	game.enemy_commander = "graves"
	game.friendly = [Cards.unit(1),{},{},{}]
	assert(power.target_at(game.lane_rect(1,1).get_center(),1)==-1,"CPU power cannot target its own cards")
	power.cpu_souls = 5
	game.player_hp = 3
	game.busy = true
	await power.cpu_turn()
	assert(game.player_hp==0 and game.ended and power.cpu_souls==0 and power.used[1],"CPU uses its own Souls for lethal")
	setup("graves")
	game.friendly[0] = Cards.unit(1)
	game.friendly[0].hp = 1
	game.hit(0,0,5,"FIRE")
	assert(power.cpu_souls==1,"CPU earns Souls from kills")
	if "--visual-test" in OS.get_cmdline_user_args():
		Engine.time_scale = 1
		setup("oculus")
		power.armed = true
		power.pointer = game.lane_rect(1,1).get_center()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hero-power-targeting.png")
		power.activate(0,1)
		while power.attack_phase!="impact": await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hero-power-bite.png")
		while power.active: await process_frame
		setup("graves")
		power.activate(0,1)
		while not power.shooting: await process_frame
		await create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hero-power-rocket.png")
		while power.active: await process_frame
	print("PASS: all six powers, direct hero damage, splash, shields, no counters, Soul cost, once per round, invalid targets, input cancellation, CPU lethal and Soul income")
	game.queue_free()
	await process_frame
	quit()
