extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.start(g)
	m.support.chosen = m.support.offers[0]
	m.support.finish_pick(m)
	assert(m.round_intro)
	m.side = 1
	m.cpu_wait = 0
	for t in [1.2,3.4,5.6,7.8,10.0]:
		m.round_intro_age = t
		m.tick(g,0.01)
		assert(m.turns==[0,0],"CPU must wait during reveal")
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/round-reveal-%d.png" % int(t))
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_ENTER
	m.handle(g,key)
	assert(not m.round_intro)
	m.side = 0
	m.draw_flights.clear()
	g.joker_reminders = true
	m.support.reminder_age = 0.8
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-reminder.png")
	key.keycode = KEY_SPACE
	m.handle(g,key)
	assert(m.support.player_drawer_open)
	assert(m.support.reminder_age==m.support.REMINDER_TIME)
	m.support.update_drawers(Vector2.ZERO,0.3,true)
	assert(m.support.drawer[0]==1)
	m.handle(g,key)
	assert(m.support.player_drawer_open,"Repeated keydown must not close the tray")
	assert(is_equal_approx(m.support.slot_rect(0,0).get_center().x,720))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/hold-joker-tray.png")
	key.pressed = false
	m.handle(g,key)
	assert(not m.support.player_drawer_open)
	m.support.update_drawers(Vector2.ZERO,0.5,true)
	assert(m.support.drawer[0]==0)
	m.round_number = 2
	m.next_round()
	m.support.offer(m)
	m.support.chosen = m.support.offers[0]
	m.support.finish_pick(m)
	assert(m.round_intro and m.round_intro_age==0)
	assert(m.support.reminder_age==0)
	m.tick(g,m.ROUND_INTRO_TIME+0.1)
	assert(not m.round_intro and m.turns==[0,0])
	m.relic = 2
	m.relic_used = [false,true]
	m.drew_this_round = [false,false]
	assert(m.relic_status(0)=="DRAW TO READY" and m.relic_status(1)=="USED")
	m.drew_this_round[0] = true
	assert(m.relic_status(0)=="READY")
	m.power_panel = true
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/all-match-powers.png")
	print("PASS: round reveal, CPU waits, skip, automatic completion, next-round restart, hold/release Space tray")
	quit()
