extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var g = load("res://scripts/main.gd").new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var p = g.hell_meld.profile
	p.path = "user://leaderboard-test.cfg"
	p.high_scores = []
	p.pending_score = {"score":1234,"stage":3,"date":"2026-10-30"}
	p.submit_score("SLAYER")
	p.submit_score("DUPLICATE")
	assert(p.high_scores.size()==1)
	for i in 12:
		p.pending_score = {"score":i*200,"stage":i+1,"date":"2026-10-30"}
		p.submit_score("PLAYER")
	assert(p.high_scores.size()==10 and p.high_scores[0].score==2200)
	var reload_profile = load("res://scripts/hellatro_profile.gd").new()
	reload_profile.path = p.path
	reload_profile.ensure_loaded()
	assert(reload_profile.high_scores==p.high_scores)
	p.pending_score = {"score":3456,"stage":6,"date":"2026-10-30"}
	g.frontend.show_scores(g)
	g.frontend.leaderboard.name_text = ""
	var event := InputEventKey.new()
	event.pressed = true
	event.unicode = 65
	g.frontend.handle(g,event)
	assert(g.frontend.leaderboard.name_text=="A")
	event.unicode = 0
	event.keycode = KEY_BACKSPACE
	g.frontend.handle(g,event)
	assert(g.frontend.leaderboard.name_text=="")
	event.keycode = KEY_ENTER
	g.frontend.handle(g,event)
	assert(p.high_scores[0].name=="DOOMGUY" and p.pending_score.is_empty())
	g.hell_meld.run.path = "user://leaderboard-test-run.cfg"
	g.hell_meld.start(g)
	g.hell_meld.run.save_run(g.hell_meld)
	assert(g.hell_meld.run.available())
	g.frontend.finish_leaving(g)
	g.frontend.click(g,Vector2(800,815))
	assert(g.frontend.restart_confirm)
	g.frontend.click(g,Vector2(800,520))
	assert(not g.frontend.restart_confirm and g.hell_meld.run.available())
	g.frontend.click(g,Vector2(800,815))
	g.frontend.click(g,Vector2(450,520))
	assert(g.modal=="hell_meld" and g.hell_meld.run.stage==1)
	assert(p.high_scores.size()==10)
	g.hell_meld.run.enabled = false
	print("PASS: name input, single submission, top 10 sorting, persistence, restart/cancel and preserved records")
	quit()
