extends SceneTree
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var g = preload("res://scripts/main.gd").new()
	root.add_child(g)
	root.warp_mouse(Vector2(1420,920))
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99
	g.hero_power.cpu_souls = 5
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/battle-menu-spacing.png")
	g.queue_free()
	await process_frame
	quit()
