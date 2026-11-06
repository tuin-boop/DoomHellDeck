extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
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
	m.boss = 0
	assert(m.boss_advice()[1]=="ANY VALID COMBO")
	m.mutation_last[0] = "team"
	assert(m.boss_advice()[2]=="NAMED TEAMS")
	m.boss = 1
	assert(m.boss_advice()[1]=="Table is empty")
	m.boss = 2
	assert(m.boss_advice()[0]=="PLAY 3+ NEW CARDS")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/boss-advice.png")
	print("PASS boss advice conditions and render")
	quit()
