extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func click(g,m,p: Vector2) -> void:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	e.position = p
	m.progression.handle(g,m,e)
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.profile.path = "user://upgrade-ui-profile.cfg"
	m.run.path = "user://upgrade-ui-run.cfg"
	m.start(g)
	m.support.pending = false
	m.support.slots[0] = [22,2]
	m.support.editions[0] = {22:2}
	m.support.stats[0].barrel = 2
	m.progression.open_shop(m)
	m.progression.credits[0] = 20
	await shot("joker-upgrade-shop")
	assert(m.progression.open_pack(m,1))
	m.progression.pack_choices = [5,3,1]
	m.progression.pack_age = 5
	await shot("joker-upgrade-choices")
	assert(m.progression.choose_pack(m,0))
	await shot("joker-upgrade-select")
	click(g,m,Vector2(150,800))
	assert(m.support.edition_of(0,22)==2,"Preview must not apply")
	await shot("joker-upgrade-preview")
	click(g,m,Vector2(350,790))
	assert(m.progression.upgrade_target==-1 and m.progression.apply_edition==5)
	click(g,m,Vector2(150,800))
	m.run.save_run(m)
	assert(m.run.resume(g,m))
	assert(m.progression.upgrade_target==22 and m.progression.apply_edition==5)
	click(g,m,Vector2(950,790))
	assert(m.progression.replace_warning and m.support.edition_of(0,22)==2)
	await shot("joker-replacement-warning")
	click(g,m,Vector2(400,750))
	assert(not m.progression.replace_warning and m.support.edition_of(0,22)==2)
	click(g,m,Vector2(950,790))
	click(g,m,Vector2(950,750))
	assert(m.support.edition_of(0,22)==5 and m.progression.pack_kind==-1)
	assert(m.support.stats[0].barrel==2,"Replacing must preserve charge")
	assert(m.progression.credits[0]==17,"No extra cost to apply")
	await shot("joker-upgrade-complete")
	m.run.enabled = false
	for path in [m.run.path,m.run.path+".tmp",m.profile.path]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS: upgrade preview, cancel, resume, replacement and one-time payment")
	quit()
