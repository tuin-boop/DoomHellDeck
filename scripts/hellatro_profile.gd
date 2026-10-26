extends RefCounted
var path := "user://hellatro_profile.cfg"
var loaded := false
var selected := "hellatro"
var unlocked: Array = ["hellatro","obsidian"]
var best_run := 0
var highest_stage := 1
var last_run_score := 0
var last_run_stage := 0
var best_total := 0
var best_play := 0
var matches := 0
var wins := 0
var last_run := {}
var entries: Array = []
var textures := {}
var open := false
var page := 0
var selection_started := -10000.0
func selection_age() -> float:
	return Time.get_ticks_msec()/1000.0-selection_started
func ensure_loaded() -> void:
	if loaded: return
	loaded = true
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/card_backs/catalogue.json"))
	if parsed is Array: entries = parsed
	var cfg := ConfigFile.new()
	if cfg.load(path)==OK:
		selected = str(cfg.get_value("profile","selected","hellatro"))
		unlocked = cfg.get_value("profile","unlocked",["hellatro","obsidian"])
		best_run = int(cfg.get_value("profile","best_run",0))
		highest_stage = int(cfg.get_value("profile","highest_stage",1))
		last_run_score = int(cfg.get_value("profile","last_run_score",0))
		last_run_stage = int(cfg.get_value("profile","last_run_stage",0))
		best_total = int(cfg.get_value("profile","best_total",0))
		best_play = int(cfg.get_value("profile","best_play",0))
		matches = int(cfg.get_value("profile","matches",0))
		wins = int(cfg.get_value("profile","wins",0))
		last_run = cfg.get_value("profile","last_run",{})
	for entry in entries:
		if entry.unlock=="default" and not entry.id in unlocked: unlocked.append(entry.id)
	if not selected in unlocked: selected = "hellatro"
func save() -> void:
	var cfg := ConfigFile.new()
	for key in ["best_run","highest_stage","last_run_score","last_run_stage","selected","unlocked","best_total","best_play","matches","wins","last_run"]: cfg.set_value("profile",key,get(key))
	cfg.save(path)
func entry_for(id: String) -> Dictionary:
	ensure_loaded()
	for entry in entries:
		if entry.id==id: return entry
	return entries[0]
func finish(m, recap: Dictionary) -> Array:
	ensure_loaded()
	var earned: Array = []
	matches += 1
	if m.result_winner==0: wins += 1
	best_total = maxi(best_total,m.scores[0])
	best_play = maxi(best_play,int(recap.best[0].get("gain",0)))
	for entry in entries:
		var qualifies: bool = (entry.unlock=="stage2" and highest_stage>=2) or (entry.unlock=="stage4" and highest_stage>=4) or entry.unlock=="default" or (entry.unlock=="win" and m.result_winner==0) or (entry.unlock=="score" and m.scores[0]>=1000) or (entry.unlock=="families" and recap.families[0].size()>=5) or (entry.unlock=="rest" and recap.draws[0]>=5) or (entry.unlock=="extensions" and recap.extensions[0]>=10)
		if qualifies and not entry.id in unlocked:
			unlocked.append(entry.id)
			earned.append(entry.name)
	last_run = {"scores":m.scores.duplicate(),"best":recap.best[0].duplicate(),"winner":m.result_winner}
	save()
	return earned
func draw_back(g, bounds: Rect2, id := "") -> void:
	var entry := entry_for(selected if id=="" else id)
	var art_path: String = entry.texture
	if not textures.has(art_path): textures[art_path] = load(art_path) if ResourceLoader.exists(art_path) else load("res://assets/cards/hellatro-back.png")
	var texture: Texture2D = textures[art_path]
	var size := texture.get_size()
	size *= minf(bounds.size.x/size.x,bounds.size.y/size.y)
	g.draw_texture_rect(texture,Rect2(bounds.get_center()-size/2,size),false,Color(entry.tint))
	if entry.id!="hellatro":
		var accent := Color(entry.accent)
		if entry.id=="prism": accent = Color.from_hsv(fposmod(g.clock*0.1,1),0.5,1)
		g.draw_rect(Rect2(bounds.get_center()-size/2,size).grow(-3),accent,false,2)
func draw(g) -> void:
	ensure_loaded()
	g.ui_help.reset()
	g.draw_rect(Rect2(0,0,1440,940),Color("080e12"))
	g.menu_frame(Rect2(80,70,1280,800))
	g.label_at(Vector2(120,130),"HELLATRO / CARD BACKS",30,g.ORANGE)
	g.label_at(Vector2(120,165),"Cosmetic only. Your choice never changes scores or card odds.",18,g.INK)
	for i in mini(5,entries.size()-page*5):
		var entry: Dictionary = entries[page*5+i]
		var rect := Rect2(125+i*245,225,210,315)
		if selected==entry.id:
			var accent := Color(entry.accent)
			var pulse := 0.5+0.5*sin(g.clock*3.5)
			for ring in range(4,0,-1):
				g.draw_rect(rect.grow(3+ring*3),Color(accent,0.04+0.035*pulse),false,3)
			g.draw_rect(rect.grow(4),accent,false,2)
			var age := selection_age()
			if age<1.2:
				for spark in 16:
					var angle := TAU*spark/16.0
					var pos := rect.get_center()+Vector2(cos(angle)*120,sin(angle)*175)*(1.0+age*0.5)
					g.draw_circle(pos,3.0*(1.0-age/1.2),Color(accent,1.0-age/1.2))
		draw_back(g,rect,entry.id)
		var available: bool = entry.id in unlocked
		if not available: g.draw_rect(rect,Color(0,0,0,0.65))
		g.label_at(Vector2(rect.position.x,580),entry.name,17,g.INK if available else g.MUTED)
		g.label_at(Vector2(rect.position.x,615),"SELECTED" if selected==entry.id else ("SELECT" if available else "LOCKED"),16,g.ORANGE)
		g.ui_help.offer(rect,entry.name,entry.description)
	g.label_at(Vector2(125,690),"Wins: %d   /   Matches: %d   /   Best total: %d   /   Best play: %d" % [wins,matches,best_total,best_play],18,g.INK)
	g.label_at(Vector2(125,730),"EQUIPPED: "+str(entry_for(selected).name)+"  /  Hover a back for its unlock condition.",16,g.ORANGE)
	g.button(Rect2(570,785,300,50),"BACK")
	g.button(Rect2(130,785,250,50),"PREVIOUS")
	g.button(Rect2(1040,785,250,50),"NEXT")
	var age := selection_age()
	if age>=0 and age<3.0:
		var entry := entry_for(selected)
		var accent := Color(entry.accent)
		var slide := pow(1.0-clampf(age/0.25,0,1),3)*90.0
		var toast := Rect2(865,85-slide,450,115)
		g.draw_rect(toast,Color("132322"))
		g.draw_rect(toast,accent,false,2)
		draw_back(g,Rect2(toast.position+Vector2(14,10),Vector2(65,95)))
		g.label_at(toast.position+Vector2(95,36),"CARD BACK EQUIPPED",18,accent)
		g.label_at(toast.position+Vector2(95,65),entry.name,20,g.INK)
		g.label_at(toast.position+Vector2(95,90),"Saved for your next deal",15,g.MUTED)
		g.draw_rect(Rect2(toast.position+Vector2(0,112),Vector2(450*(1-age/3.0),3)),accent)
func handle(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE: open = false
	if not (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT): return
	if Rect2(570,785,300,50).has_point(event.position): open = false
	if Rect2(130,785,250,50).has_point(event.position): page = posmod(page-1,ceili(entries.size()/5.0))
	if Rect2(1040,785,250,50).has_point(event.position): page = (page+1)%ceili(entries.size()/5.0)
	for i in mini(5,entries.size()-page*5):
		if Rect2(125+i*245,225,210,410).has_point(event.position) and entries[page*5+i].id in unlocked:
			selected = entries[page*5+i].id
			selection_started = Time.get_ticks_msec()/1000.0
			save()
