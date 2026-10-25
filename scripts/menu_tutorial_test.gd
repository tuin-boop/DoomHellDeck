extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var original: bool = g.mode_tutorials
	g.frontend.finish_leaving(g)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/art-home.png")
	g.mode_tutorials = true
	g.frontend.select_mode(g,1)
	assert(g.modal=="mode_tutorial")
	g.frontend.tutorial_click(g,Vector2(1000,740))
	assert(g.frontend.tutorial_page==1)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/quick-start.png")
	g.frontend.tutorial_click(g,Vector2(250,740))
	assert(g.frontend.tutorial_page==0)
	g.frontend.tutorial_click(g,Vector2(300,640))
	assert(not g.mode_tutorials)
	g.frontend.tutorial_click(g,Vector2(450,740))
	assert(g.modal=="hell_meld")
	g.frontend.finish_leaving(g)
	g.frontend.select_mode(g,0)
	assert(g.modal=="new_match")
	g.frontend.open_tutorial(g,0,false)
	g.frontend.tutorial_page = 2
	g.frontend.tutorial_click(g,Vector2(1000,740))
	assert(g.modal=="home")
	for mode in 2:
		for page in 3:
			g.frontend.open_tutorial(g,mode,false)
			g.frontend.tutorial_page = page
			g.frontend.tutorial_started_at = g.clock-2.7
			await process_frame
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://captures/tutorial-%d-%d.png" % [mode,page])
	g.mode_tutorials = original
	g.save_view_setting()
	print("PASS: both mode routes, tutorial next/back/skip, opt-out, manual replay and screenshots")
	quit()
