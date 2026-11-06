extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var g = load("res://scripts/main.gd").new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var p = g.hell_meld.profile
	p.path = "user://leaderboard-preview.cfg"
	p.high_scores = []
	for i in 10: p.high_scores.append({"name":["DOOMGUY","SLAYER","CACO FARMER"][i%3],"score":12500-i*930,"stage":9-i/2})
	p.pending_score = {"score":6480,"stage":5}
	g.frontend.show_scores(g)
	g.frontend.leaderboard.name_text = "SLAYER"
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/high-scores.png")
	print("Leaderboard preview captured")
	quit()
