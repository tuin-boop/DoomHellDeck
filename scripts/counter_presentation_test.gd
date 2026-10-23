extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	var visual := "--visual-test" in OS.get_cmdline_user_args()
	Engine.time_scale = 1 if visual else 8
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	for cinema in ([true] if visual else [false,true]):
		for side in ([0] if visual else [0,1]):
			for lethal in ([false] if visual else [false,true]):
				game.new_battle()
				game.cinematic_enabled = cinema
				game.friendly = [Cards.unit(4 if side==0 else 18),{},{},{}]
				game.enemy = [Cards.unit(18 if side==0 else 4),{},{},{}]
				var attackers: Array = game.friendly if side==0 else game.enemy
				var defenders: Array = game.enemy if side==0 else game.friendly
				attackers[0].hp = 100
				defenders[0].hp = 1 if lethal else 100
				game.attack(side,0)
				while not game.counter_animating:
					if lethal and defenders[0].is_empty():
						assert(game.counter_visual_active,"Lethal defender stays visible while attacker retreats")
						assert(not game.pending_counter_death.is_empty(),"Death effects wait until counter finishes")
					await process_frame
				assert(game.moving_offset.is_zero_approx() and not game.duel_attacking,"Lost Soul must return before Mancubus counters")
				assert(attackers[0].hp==100 and game.retaliation_started<0,"No counter damage before shooting")
				assert(game.counter_visual_id==18 and game.projectile_side==1-side)
				if lethal:
					assert(defenders[0].is_empty(),"A lethal defender still gets its final counter animation")
					assert(game.counter_visual_active and not game.pending_counter_death.is_empty())
				while game.projectile.x<0: await process_frame
				assert(game.counter_animating and game.projectile_art==game.projectile_key(18))
				assert(attackers[0].hp==100,"Counter waits for projectile impact")
				if visual:
					await create_timer(0.15).timeout
					await RenderingServer.frame_post_draw
					root.get_texture().get_image().save_png("res://captures/mancubus-counter.png")
				while game.counter_animating: await process_frame
				assert(not game.counter_visual_active and game.pending_counter_death.is_empty(),"Death effects finish after the counter, without resurrecting a card")
				assert(attackers[0].hp==98 and game.counter_offset.is_zero_approx())
				assert(game.counter_finished_at-game.counter_pose_started>=1.6,"Counter includes pose, flight, hold and return")
				if cinema: assert(game.duel_active,"Cards stay dissolved through the full counter")
				while game.moving_side>=0: await process_frame
				assert(not game.duel_active)
	print("PASS: Lost Soul returns before full Mancubus pose/projectile/counter/recovery; both sides/views and lethal defenders")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	game.queue_free()
	await process_frame
	quit()
