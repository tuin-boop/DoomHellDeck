extends RefCounted
var path := "user://hellatro_profile.cfg"
var loaded := false
var selected := "hellatro"
var cursor_selected := "default"
var unlocked: Array = ["hellatro"]
var high_scores: Array = []
var score_name := ""
var pending_score: Dictionary = {}
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
		cursor_selected = str(cfg.get_value("profile","cursor_selected","default"))
		unlocked = cfg.get_value("profile","unlocked",["hellatro","obsidian"])
		high_scores = cfg.get_value("profile","high_scores",[])
		score_name = str(cfg.get_value("profile","score_name",""))
		pending_score = cfg.get_value("profile","pending_score",{})
		best_run = int(cfg.get_value("profile","best_run",0))
		highest_stage = int(cfg.get_value("profile","highest_stage",1))
		last_run_score = int(cfg.get_value("profile","last_run_score",0))
		last_run_stage = int(cfg.get_value("profile","last_run_stage",0))
		best_total = int(cfg.get_value("profile","best_total",0))
		best_play = int(cfg.get_value("profile","best_play",0))
		matches = int(cfg.get_value("profile","matches",0))
		wins = int(cfg.get_value("profile","wins",0))
		last_run = cfg.get_value("profile","last_run",{})
	var aliases := {"obsidian":"hellatro","gold":"hellatro","prism":"hellatro","abyssal_pirate":"pirate_cacodemon","sovereign":"scream_king"}
	selected = aliases.get(selected,selected)
	for old in aliases:
		if old in unlocked:
			if not aliases[old] in unlocked: unlocked.append(aliases[old])
			unlocked.erase(old)
	for entry in entries:
		if entry.unlock=="default" and not entry.id in unlocked: unlocked.append(entry.id)
	if not selected in unlocked: selected = "hellatro"
func save() -> void:
	var cfg := ConfigFile.new()
	for key in ["high_scores","score_name","pending_score","cursor_selected","best_run","highest_stage","last_run_score","last_run_stage","selected","unlocked","best_total","best_play","matches","wins","last_run"]: cfg.set_value("profile",key,get(key))
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

func cursor_unlocked(id: String) -> bool:
	ensure_loaded()
	return id in ["default","doomguy"] or (id=="baron" and wins>=1) or (id=="imp" and highest_stage>=3)
func equip_cursor(id: String) -> bool:
	if not cursor_unlocked(id): return false
	cursor_selected = id
	save()
	apply_cursor()
	return true
var cursor_cache := {}
func cursor_texture(id: String) -> Texture2D:
	if cursor_cache.has(id): return cursor_cache[id]
	var source: Texture2D = load("res://assets/cursors/"+id+".png")
	var src := source.get_image()
	if src.is_compressed(): src.decompress()
	var rotated := Image.create(80,80,false,Image.FORMAT_RGBA8)
	for y in 80:
		for x in 80:
			var sample := (Vector2(x,y)-Vector2(40,40)).rotated(deg_to_rad(15))+Vector2(32,32)
			var sx := roundi(sample.x)
			var sy := roundi(sample.y)
			if sx>=0 and sy>=0 and sx<src.get_width() and sy<src.get_height(): rotated.set_pixel(x,y,src.get_pixel(sx,sy))
	cursor_cache[id] = ImageTexture.create_from_image(rotated)
	return cursor_cache[id]
func apply_cursor() -> void:
	ensure_loaded()
	if not cursor_unlocked(cursor_selected): cursor_selected = "default"
	if DisplayServer.get_name()=="headless": return
	var cursor: Texture2D = null
	if cursor_selected!="default": cursor = cursor_texture(cursor_selected)
	# Native 64px sprite; the raised fingertip is the actual click point.
	Input.set_custom_mouse_cursor(cursor,Input.CURSOR_ARROW,Vector2(27,16) if cursor!=null else Vector2.ZERO)
	Input.set_custom_mouse_cursor(cursor,Input.CURSOR_POINTING_HAND,Vector2(27,16) if cursor!=null else Vector2.ZERO)

func submit_score(player_name: String) -> void:
	ensure_loaded()
	if pending_score.is_empty(): return
	score_name = player_name.strip_edges().left(16)
	if score_name.is_empty(): score_name = "DOOMGUY"
	var row := pending_score.duplicate(true)
	row["name"] = score_name
	high_scores.append(row)
	high_scores.sort_custom(func(a,b): return a.score>b.score if a.score!=b.score else a.stage>b.stage)
	if high_scores.size()>10: high_scores.resize(10)
	pending_score.clear()
	save()
