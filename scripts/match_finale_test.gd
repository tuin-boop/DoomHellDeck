extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var example = preload("res://scripts/hell_meld.gd").new()
	example.round_number = 5
	example.rounds = [1,3]
	example.scores = [869,808]
	example.finish_round(0,"test")
	assert(example.scores==[899,808] and example.rounds==[2,3] and example.result_winner==0)
	example.round_over = false
	example.scores = [778,899]
	example.rounds = [3,1]
	example.finish_round(0,"test")
	assert(example.result_winner==1,"Points override more round wins")
	example.round_over = false
	example.scores = [778,808]
	example.finish_round(0,"test")
	assert(example.result_winner==-1,"Equal totals draw regardless of rounds")
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.start(g)
	m.support.pending = false
	m.support.reminder_age = 99
	for r in 5:
		m.round_number = r+1
		m.next_round()
		m.round_scores = [40+r*20,60+r*10]
		m.scores[0] += m.round_scores[0]
		m.scores[1] += m.round_scores[1]
		m.finish_round(0 if r>=2 else 1,"won")
	assert(m.round_history.size()==5 and m.finished)
	assert(m.finale.totals_at(m,0)==[0.0,0.0])
	assert(m.finale.totals_at(m,99)==[float(m.scores[0]),float(m.scores[1])])
	assert(m.result_winner==0)
	m.banner_age = 99
	m.draw_flights.clear()
	m.result_age = 5.1
	assert(not m.finale.done(m))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/hellatro-final-count.png")
	m.result_age = m.finale.duration(m)+1
	assert(m.finale.done(m))
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/hellatro-final-winner.png")
	m.result_winner = 1
	m.result_age = m.finale.duration(m)+0.5
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/hellatro-final-defeat.png")
	m.start(g)
	assert(m.round_history.is_empty())
	print("PASS: five round history, exact cumulative totals, delayed winner reveal and new-match reset")
	quit()
