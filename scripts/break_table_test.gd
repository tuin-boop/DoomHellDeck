extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	for example in [[[21,19],"SPIDER NEST"],[[15,2],"COVERING FIRE"],[[0,8,2,19],"WALKING ARSENAL"],[[8,0,15],"HEAVY ESCORT"],[[21,15,0],"CROSSFIRE"]]:
		assert(Meld.pattern(example[0]).name==example[1])
	assert(Meld.pattern([0,8,2,19,15]).name=="APOCALYPSE")
	assert(Meld.pattern([0,8]).is_empty())
	var m = Meld.new()
	for owner in 2:
		m.side = owner
		m.round_over = false
		m.banner_age = 99
		m.break_age = 99
		m.break_used = [false,false]
		m.round_scores = [30,30]
		m.scores = [130,130]
		m.turns = [2,2]
		m.hands[owner] = [21,19]
		m.melds = [{"ids":[0,0],"kind":"set","points":10}]
		assert(m.evaluate(owner,[0,1]).is_empty())
		assert(m.break_table(owner))
		assert(m.round_scores[owner]==20 and m.scores[owner]==120)
		assert(m.turns==[2,2] and m.side==owner)
		assert(not m.evaluate(owner,[0,1]).is_empty())
		assert(not m.break_table(owner))
		var snapshot = m.run.snapshot(m,m.run.MELD_KEYS)
		var restored = Meld.new()
		m.run.restore(restored,snapshot,m.run.MELD_KEYS)
		assert(restored.break_used[owner])
	m.next_round()
	assert(m.break_used==[false,false])
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	m = g.hell_meld
	m.start(g)
	m.support.pending = false
	m.round_intro = false
	m.draw_flights.clear()
	m.banner_age = 99
	m.side = 0
	m.hands[0] = [21,0,8,15,2,19]
	m.melds = [{"ids":[0,0],"kind":"set","points":10,"name":"IMP MISCHIEF","owner":1}]
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/break-table.png")
	assert(m.break_table(0))
	assert(m.sound_cues.any(func(c): return c.key=="DSBAREXP"))
	m.tick(g,0.02)
	assert(g.position.length()>0)
	m.tick(g,0.7)
	assert(g.position==Vector2.ZERO)
	m.side = 1
	m.hands[1] = [21,19]
	m.melds = [{"ids":[0,0],"kind":"set","points":10,"name":"IMP MISCHIEF","owner":0}]
	m.cpu_wait = 0
	m.tick(g,0.02)
	assert(m.break_used[1] and m.melds.is_empty())
	g.position = Vector2.ZERO
	print("PASS five combos, Apocalypse extension, both owners, cost, turn preservation, once per round, save state and presentation")
	quit()
