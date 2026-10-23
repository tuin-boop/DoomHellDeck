extends SceneTree
const Game = preload("res://scripts/main.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	game = Game.new()
	root.add_child(game)
	var fx = game.hero_feedback
	fx.set_process(false)
	game.souls = 5
	fx._process(0)
	assert(fx.ready_border_visible())
	assert(fx.border_point(0)==fx.border_point(512))
	fx._process(0.2)
	assert(fx.border_phase>0)
	fx.reminder_age = 0
	fx.ready_elapsed = 0
	assert(fx.reminder_age==0)
	fx._process(19.9)
	assert(fx.reminder_age>1.2)
	fx._process(0.11)
	assert(fx.reminder_age==0,"Ready power pulses again at 20 seconds")
	game.busy = true
	assert(not fx.ready_border_visible())
	var elapsed: float = fx.ready_elapsed
	fx._process(25)
	assert(fx.ready_elapsed==elapsed and fx.ready_tilt()==0,"Pause reminder during combat")
	game.busy = false
	game.hero_power.used[0] = true
	assert(not fx.ready_border_visible())
	fx._process(0)
	assert(not fx.was_ready and fx.reminder_age>1.2)
	game.hero_power.used[0] = false
	game.souls = 4
	assert(not fx.ready_border_visible())
	fx._process(21)
	assert(not fx.was_ready)
	game.battle_voice.speech_age = 2
	assert(fx.portrait_center(1).is_equal_approx(game.battle_voice.speaking_portrait_rect(2).get_center()))
	var random_state: int = game.rng.state
	var before: int = game.enemy_hp
	game.damage_hero(1,3)
	assert(game.enemy_hp==before-3 and fx.hit_age[1]==0 and fx.blood.size()>0)
	fx._process(0.05)
	assert(not fx.offset(1).is_zero_approx())
	game.damage_hero(0,2)
	assert(game.player_hp==28 and fx.hit_age[0]==0)
	assert(game.rng.state==random_state,"Feedback does not change gameplay randomness")
	fx._process(2)
	assert(fx.blood.is_empty() and fx.offset(0).is_zero_approx() and fx.offset(1).is_zero_approx())
	game.damage_hero(0,0)
	assert(fx.blood.is_empty(),"Zero damage doesn't bleed")
	game.new_battle()
	assert(fx.blood.is_empty() and not fx.was_ready)
	if "--visual-test" in OS.get_cmdline_user_args():
		game.battle_voice.speech_age = 99
		game.souls = 5
		fx._process(0)
		fx._process(0.3)
		fx.reminder_age = 99
		fx.border_phase = 0.36
		root.warp_mouse(Vector2(1420,920))
		fx.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/hero-ready-border.png")
	print("PASS: ready pulse cadence, unavailable/busy suppression, both hero damage reactions, moving portrait position, cleanup, zero damage, reset and independent randomness")
	game.queue_free()
	await process_frame
	quit()
