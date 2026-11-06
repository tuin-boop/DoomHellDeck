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
	m.profile.path = "user://visual-fix-profile.cfg"
	m.start(g)
	m.run.enabled = false
	m.support.pending = false
	m.progression.active = false
	m.round_intro = false
	m.hands = [[1,3,15,0],[1,0,0]]
	m.draw_flights.clear()
	m.side = 0
	assert(m.play(0,[0,1,2],-1))
	m.flights.clear()
	m.banner_age = 1.3
	m.boss = 1
	await shot("firing-squad-single-cards")
	assert(m.melds[0].ids.size()==3)
	m.banner_age = 99
	m.finish_round(0,"won on round points")
	m.result_age = 1.1
	await shot("boss-round-reaction")
	assert(g.ui_help.button_help("CHOOSE ROUTE").contains("alternate"))
	m.run.enabled = false
	print("PASS: named-team render, boss reaction, route help")
	quit()
