extends RefCounted
var name_text := ""
var art := {}
var portraits: Array = []
var visual_rng := RandomNumberGenerator.new()
func randomize_portraits(g) -> void:
	var choices: Array = []
	for id in g.hell_meld.support.BASE_IDS:
		var art_id: int = {47:6,48:14,49:16}.get(id,id)
		var path: String = "res://assets/jokers/"+g.hell_meld.support.DATA[art_id][0]+(".tres" if art_id==57 else ".png")
		if ResourceLoader.exists(path) and not choices.has(path): choices.append(path)
	visual_rng.randomize()
	portraits.clear()
	while portraits.size()<8 and not choices.is_empty():
		var index := visual_rng.randi_range(0,choices.size()-1)
		portraits.append(choices[index])
		choices.remove_at(index)
func draw(g) -> void:
	var profile = g.hell_meld.profile
	g.draw_rect(Rect2(0,0,1440,940),Color("090e13"))
	for i in 30:
		var p := Vector2(fposmod(i*173.0,1440),940-fposmod(g.clock*25+i*61,940))
		g.draw_rect(Rect2(p,Vector2(3,7)),Color(1,0.3,0.05,0.35))
	# Familiar Jokers frame the board without covering its rows or controls.
	for i in portraits.size():
		var path: String = portraits[i]
		if not art.has(path): art[path] = load(path)
		var tex: Texture2D = art[path]
		if tex==null: continue
		var center := Vector2(120 if i<4 else 1320,190+(i%4)*180+sin(g.clock*1.8+i)*9)
		var size := tex.get_size()
		size *= minf(175/size.x,165/size.y)
		g.draw_set_transform(center,sin(g.clock*1.3+i)*0.065)
		g.draw_texture_rect(tex,Rect2(-size/2,size),false)
		g.draw_set_transform(Vector2.ZERO)
	g.menu_frame(Rect2(235,55,970,830))
	g.label_at(Vector2(290,125),"HELLATRO / HALL OF LEGENDS",34,g.ORANGE)
	g.label_at(Vector2(290,164),"LOCAL HIGH SCORES / COMPLETED RUNS / TOP 10",17,g.MUTED)
	g.label_at(Vector2(290,215),"RANK     NAME",19,g.INK)
	g.label_at(Vector2(800,215),"POINTS",19,g.INK)
	g.label_at(Vector2(1020,215),"STAGE",19,g.INK)
	for i in profile.high_scores.size():
		var row: Dictionary = profile.high_scores[i]
		var y: int = 252+i*36
		if i%2==0: g.draw_rect(Rect2(275,y-24,890,34),Color("18262a"))
		var color: Color = Color("ffdb79") if i==0 else g.INK
		g.label_at(Vector2(290,y),"%02d" % (i+1),20,color)
		g.label_at(Vector2(390,y),row.name,20,color)
		g.label_at(Vector2(800,y),str(row.score),20,color)
		g.label_at(Vector2(1040,y),str(row.stage),20,color)
	if profile.high_scores.is_empty():
		g.label_at(Vector2(350,340),"YOUR FIRST LEGEND STARTS HERE",25,g.ORANGE)
		g.label_at(Vector2(350,385),"Finish a run, enter your name and claim your place.",18,g.INK)
	if not profile.pending_score.is_empty():
		var pending: Dictionary = profile.pending_score
		g.label_at(Vector2(290,650),"RUN COMPLETE / %d POINTS / STAGE %d" % [pending.score,pending.stage],22,g.ORANGE)
		g.label_at(Vector2(290,686),"TYPE YOUR NAME / 16 CHARACTERS / ENTER TO SAVE",16,g.MUTED)
		g.draw_rect(Rect2(290,700,560,55),Color("1c3031"))
		g.draw_rect(Rect2(290,700,560,55),Color("ffcf6c"),false,2)
		g.label_at(Vector2(308,737),name_text+("_" if int(g.clock*2)%2==0 else ""),25,g.INK)
		g.button(Rect2(875,700,270,55),"SAVE SCORE")
	else:
		g.label_at(Vector2(290,690),"KEEP CLIMBING. GIVE THE NEXT RUN YOUR BEST SHOT.",18,g.MUTED)
	g.button(Rect2(290,795,350,55),"MAIN MENU")
	if profile.pending_score.is_empty(): g.button(Rect2(795,795,350,55),"NEW RUN")
func handle(g,event: InputEvent) -> void:
	var profile = g.hell_meld.profile
	if event is InputEventKey and event.pressed:
		if event.keycode==KEY_ESCAPE:
			g.frontend.scores_open = false
		elif not profile.pending_score.is_empty():
			if event.keycode==KEY_ENTER or event.keycode==KEY_KP_ENTER: profile.submit_score(name_text)
			elif event.keycode==KEY_BACKSPACE: name_text = name_text.left(maxi(0,name_text.length()-1))
			elif event.unicode>=32 and event.unicode!=127 and name_text.length()<16: name_text += String.chr(event.unicode)
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if Rect2(875,700,270,55).has_point(event.position): profile.submit_score(name_text)
		elif Rect2(290,795,350,55).has_point(event.position): g.frontend.scores_open = false
		elif profile.pending_score.is_empty() and Rect2(795,795,350,55).has_point(event.position):
			g.frontend.scores_open = false
			if g.hell_meld.run.available(): g.frontend.restart_confirm = true
			else: g.hell_meld.start(g)

