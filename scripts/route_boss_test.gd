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
	m.profile.path = "user://route-test-profile.cfg"
	m.run.path = "user://route-test-run.cfg"
	m.start(g)
	m.support.pending = false
	m.progression.active = false
	m.finish_round(0,"test")
	m.power_panel = true
	assert(m.route_turn==0 and m.cpu_route==-1)
	var expected: Dictionary = m.route_offers[1].duplicate()
	m.choose_upgrade(1)
	assert(m.modifier==expected.modifier and m.relic==expected.relic)
	assert(m.route_turn==1)
	m.support.pending = false
	m.progression.active = false
	m.finish_round(1,"test")
	m.power_panel = true
	assert(m.cpu_route>=0)
	var committed: Dictionary = m.route_offers[m.cpu_route].duplicate()
	var other: int = (m.cpu_route+1)%3
	var family: String = m.upgrade_offers[other]
	var before: int = m.upgrades[0].get(family,0)
	await shot("cpu-route-choice")
	m.run.save_run(m)
	var chooser: int = m.cpu_route
	assert(m.run.resume(g,m))
	assert(m.cpu_route==chooser and m.route_turn==1)
	m.choose_upgrade(other)
	assert(m.modifier==committed.modifier and m.relic==committed.relic and m.boss==committed.boss)
	assert(m.upgrades[0][family]==before+1 and m.route_turn==2)
	m.support.pending = false
	m.progression.active = false
	m.power_panel = false
	m.start_round_intro()
	assert(m.round_intro_age<0)
	await shot("boss-round-announcement")
	# Later stages retain normal rounds, including route previews.
	for stage in [1,3,7]:
		m.run.stage = stage
		for round_index in range(1,6):
			m.round_number = round_index
			m.next_round()
			assert((m.boss>=0)==(round_index in [3,5]),"Boss schedule changed at stage %d round %d" % [stage,round_index])
			m.upgrade_offers = ["march","duo","trinity"]
			m.make_routes()
			for route in m.route_offers:
				assert((route.boss>=0)==(round_index+1 in [3,5]),"Route preview must match next round")
	m.run.enabled = false
	for path in [m.run.path,m.run.path+".tmp",m.profile.path]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS: alternating routes, independent upgrades, saved CPU choice, boss intro")
	quit()
