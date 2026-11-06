extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func click(m,g,pos: Vector2) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = pos
	m.handle(g,event)
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.start(g)
	m.support.pending = false
	m.round_intro = false
	m.draw_flights.clear()
	m.banner_age = 99
	m.side = 0
	assert(not m.tools_visible())
	click(m,g,Vector2(1200,205))
	assert(not m.power_panel)
	click(m,g,Vector2(1200,50))
	assert(m.tools_pinned and m.tools_visible())
	m.tick(g,0.25)
	m.melds = [{"ids":[0,0],"kind":"set","points":10,"name":"IMP MISCHIEF","owner":1}]
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/tools-menu-open.png")
	click(m,g,Vector2(1200,255))
	assert(m.support.library)
	m.support.library = false
	click(m,g,Vector2(1200,205))
	assert(m.power_panel)
	m.power_panel = false
	click(m,g,Vector2(1200,50))
	assert(not m.tools_pinned)
	m.tools_hover = 0
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/tools-menu-closed.png")
	print("PASS tools pin, unpin, hidden hit targets, powers and collection")
	quit()
