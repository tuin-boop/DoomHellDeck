extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.profile.path = "user://endless-ui-profile.cfg"
	m.run.path = "user://endless-ui-run.cfg"
	m.start(g)
	m.run.enabled = true
	m.progression.enabled = true
	m.profile.highest_stage = 4
	m.profile.best_run = 3250
	m.support.chosen = m.support.offers[0]
	m.support.finish_pick(m)
	m.progression.credits[0] = 30
	m.progression.preview_pack = 1
	m.progression.preview_tier = 2
	await shot("legendary-pack-preview")
	m.progression.preview_pack = -1
	m.progression.open_pack(m,1,2)
	m.progression.pack_age = 0.65
	await shot("legendary-pack-sealed")
	m.progression.pack_age = 1.22
	await shot("legendary-pack-burst")
	m.progression.pack_age = 4.0
	await shot("legendary-edition-choices")
	m.progression.pack_kind = -1
	m.progression.finish(m)
	m.round_intro = false
	m.run.stage = 3
	m.run.banked = 1900
	await shot("endless-hud")
	m.rounds = [2,0]
	m.round_number = 3
	m.round_history = [{"points":[170,125],"winner":0},{"points":[220,130],"winner":0}]
	m.scores = [390,255]
	m.round_start_scores = [390,255]
	m.finish_round(0,"test")
	m.result_age = 99
	m.banner_age = 99
	await shot("endless-stage-cleared")
	g.frontend.finish_leaving(g)
	await shot("endless-main-menu")
	m.run.enabled = false
	for path in [m.run.path,m.run.path+".tmp",m.profile.path]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS: tier preview, pack opening, eight edition choices, endless HUD, stage results and resume menu rendered")
	quit()
