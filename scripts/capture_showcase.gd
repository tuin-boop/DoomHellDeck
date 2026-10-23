extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game

func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()

func stage(hero: String, rival: String) -> void:
	game.chosen_commander = hero
	game.new_battle()
	game.enemy_commander = rival
	game.battle_voice.reset(rival)
	game.battle_voice.speech_age = 99
	game.battle_voice.headline_age = 99
	game.friendly = [Cards.unit(Cards.leveled_id(3,6)),Cards.unit(Cards.leveled_id(15,7)),Cards.unit(8),Cards.unit(Cards.leveled_id(1,10))]
	game.enemy = [Cards.unit(6),Cards.unit(18),Cards.unit(5),Cards.unit(7)]
	game.hand = [Cards.leveled_id(0,5),Cards.leveled_id(5,7),7,9,22]
	game.souls = 8
	game.energy = 8
	game.max_energy = 8
	game.turn = 10
	game.toast_time = 0
	game.selected = -1
	game.particles.clear()
	game.numbers.clear()
	game.hero_feedback.reminder_age = 99
	game.hero_feedback.was_ready = true
	game.hero_feedback.ready_elapsed = 0

func snap(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/showcase/"+name+".png")
	print("CAPTURED "+name)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://captures/showcase")
	root.size = Vector2i(1440,940)
	game = Game.new()
	root.add_child(game)
	root.warp_mouse(Vector2(1425,920))
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	stage("graves","iron_tyrant")
	game.formation_effect(0,3,game.friendly[3].id)
	await create_timer(0.65).timeout
	await snap("01-prismatic-dead-patrol")
	game.hero_power.activate(0,1)
	while not game.hero_power.shooting: await process_frame
	await create_timer(0.57).timeout
	await snap("02-rocket-strike")
	while game.hero_power.active: await process_frame
	stage("oculus","goremaw")
	game.hero_power.activate(0,1)
	while game.hero_power.attack_phase!="impact": await process_frame
	await create_timer(0.12).timeout
	await snap("03-cacodemon-bite")
	while game.hero_power.active: await process_frame
	stage("graves","iron_tyrant")
	game.friendly[0] = Cards.unit(8)
	game.enemy[0] = Cards.unit(6)
	game.enemy[0].hp = 20
	game.cinematic_enabled = true
	game.busy = true
	game.attack(0,0)
	while game.projectile.x<0: await process_frame
	await create_timer(0.2).timeout
	await snap("04-cyberdemon-duel")
	while game.moving_side>=0: await process_frame
	game.busy = false
	stage("graves","ashfang")
	game.battle_voice.react("opening",true)
	game.battle_voice.speech_center = Vector2(735,300)
	game.battle_voice.speech_tilt = deg_to_rad(-5)
	await create_timer(1.6).timeout
	await snap("05-ashfang-taunt")
	print("PASS: five staged in-engine showcase screenshots; player saves untouched")
	game.queue_free()
	await process_frame
	quit()
