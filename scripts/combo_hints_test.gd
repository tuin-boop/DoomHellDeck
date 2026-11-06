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
	m.hands[0] = [21,0,8,15,2,19]
	m.cheat_hints = true
	var moves = m.best_move(0)
	assert(moves.all.size()>8)
	var highest := -1
	for option in moves.all:
		highest = maxi(highest,option.gain)
		for index in option.indices: assert(option in moves.hints[index])
	assert(m.evaluate(0,moves.indices).gain==highest)
	m.tick(g,0.01)
	assert(m.hint_all.size()==moves.all.size() and m.hint_best_gain==highest)
	print("PASS full combo list, per-card membership, points and best-play ranking")
	quit()
