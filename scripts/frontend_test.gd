extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	run.call_deferred()
func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func run() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	var g = Game.new()
	root.add_child(g)
	g.commander_selected = true
	g.new_battle()
	var hand: Array = g.hand.duplicate()
	var wins: int = g.wins
	var credits: int = g.credits
	g.frontend.open(g)
	assert(g.modal=="leave_match" and not g.ended and g.frontend.started)
	await capture("leave-match-warning")
	g.frontend.click(g,Vector2(300,605))
	assert(g.modal=="" and g.hand==hand and not g.ended)
	g.modal = "mulligan"
	g.battle_tools.pending = true
	g.frontend.open(g)
	var escape := InputEventKey.new()
	escape.pressed = true
	escape.keycode = KEY_ESCAPE
	assert(g.frontend.handle(g,escape))
	assert(g.modal=="mulligan" and g.battle_tools.pending)
	g.frontend.open(g)
	g.frontend.click(g,Vector2(300,525))
	assert(g.modal=="home" and g.ended and not g.frontend.started and not g.battle_tools.pending)
	assert(g.wins==wins and g.credits==credits)
	g.frontend.handle(g,escape)
	assert(g.modal=="home","No Escape-to-resume path")
	await capture("main-menu-two-modes")
	g.frontend.click(g,Vector2(300,430))
	assert(g.modal=="new_match")
	await capture("choose-match-mode")
	g.frontend.click(g,Vector2(300,580))
	assert(g.random_mode and not g.ended and g.frontend.started)
	g.frontend.open(g)
	g.frontend.click(g,Vector2(300,525))
	g.frontend.click(g,Vector2(300,430))
	g.frontend.click(g,Vector2(300,440))
	assert(not g.random_mode and not g.ended)
	g.enemy_hp = 0
	g.check_end()
	g.modal_click(Vector2(450,400))
	g.modal_click(Vector2(850,875))
	assert(g.modal=="new_match","Victory Next Match selects mode")
	g.frontend.handle(g,escape)
	assert(g.modal=="home")
	g.frontend.click(g,Vector2(260,790))
	assert(g.modal=="options")
	g.frontend.handle(g,escape)
	assert(g.modal=="home")
	g.new_battle()
	g.busy = true
	g.frontend.open(g)
	assert(g.modal=="","Cannot leave midway through an attack")
	g.busy = false
	print("PASS: leave warning, cancel and Escape preservation, confirmed abandonment without rewards, no resume, random/built choice, victory next-match picker, options and combat lock")
	g.queue_free()
	await process_frame
	quit()
