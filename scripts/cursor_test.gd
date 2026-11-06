extends SceneTree
const Profile = preload("res://scripts/hellatro_profile.gd")
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var p = Profile.new()
	p.path = "user://cursor-test.cfg"
	p.loaded = true
	assert(p.equip_cursor("doomguy"))
	assert(not p.equip_cursor("imp"))
	assert(not p.cursor_unlocked("baron"))
	p.wins = 1
	assert(p.equip_cursor("baron"))
	assert(not p.cursor_unlocked("imp"))
	p.highest_stage = 3
	assert(p.equip_cursor("imp"))
	var restored = Profile.new()
	restored.path = p.path
	restored.ensure_loaded()
	assert(restored.cursor_selected=="imp")
	assert(restored.equip_cursor("default"))
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	g.hell_meld.profile = p
	g.frontend.at_home = true
	g.modal = "options"
	g.frontend.cursors_open = true
	p.equip_cursor("doomguy")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/cursor-options.png")
	print("PASS cursor unlocks, equip, persistence and options render")
	p.equip_cursor("default")
	quit()
