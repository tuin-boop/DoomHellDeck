extends Node
var player := AudioStreamPlayer.new()
var tracks: Array = []
var albums: Array = []
var album := ""
var mode := 2
var volume := 0.35
var enabled := true
var current := -1
var album_page := 0
var track_page := 0
var query := ""
var return_modal := "home"
var rng := RandomNumberGenerator.new()
var history: Array = []
var status := ""
var menu_music := true
var menu_index := -1
const PAGE_SIZE := 8
const SETTINGS := "user://radio.cfg"

func _ready() -> void:
	rng.randomize()
	add_child(player)
	player.finished.connect(next_track)
	var file := FileAccess.open("res://assets/radio/tracks.json",FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if parsed is Array: tracks = parsed
	for track in tracks:
		if not albums.has(track.album): albums.append(track.album)
		if track.get("menu_only",false): menu_index = tracks.find(track)
	albums.sort()
	if not albums.is_empty(): album = albums[0]
	if "--balance-test" not in OS.get_cmdline_user_args():
		var config := ConfigFile.new()
		if config.load(SETTINGS)==OK:
			mode = clampi(int(config.get_value("radio","mode",2)),0,2)
			volume = clampf(float(config.get_value("radio","volume",0.35)),0,1)
			enabled = bool(config.get_value("radio","enabled",true))
			var saved: String = config.get_value("radio","album",album)
			if albums.has(saved): album = saved
		if enabled: next_track()
	player.volume_db = linear_to_db(maxf(volume,0.001))
	player.volume_db = -80 if volume==0 else player.volume_db

func save_settings() -> void:
	if "--balance-test" in OS.get_cmdline_user_args(): return
	var config := ConfigFile.new()
	config.set_value("radio","mode",mode)
	config.set_value("radio","volume",volume)
	config.set_value("radio","enabled",enabled)
	config.set_value("radio","album",album)
	config.save(SETTINGS)

func pool() -> Array:
	var result: Array = []
	for i in tracks.size():
		if tracks[i].get("menu_only",false): continue
		if mode==2 or tracks[i].album==album: result.append(i)
	return result

func next_index() -> int:
	var choices := pool()
	if choices.is_empty(): return -1
	if mode==0: return choices[(choices.find(current)+1)%choices.size()]
	if choices.size()>1: choices.erase(current)
	return choices[rng.randi_range(0,choices.size()-1)]

func next_track() -> void:
	if menu_music and menu_index>=0 and get_parent().modal!="radio":
		play_track(menu_index)
		return
	var index := next_index()
	if index>=0: play_track(index)

func update_context(g) -> void:
	# Radio previews are temporary; closing it at home restores the menu theme.
	if g.modal=="radio": return
	var wants_menu: bool = g.frontend.at_home
	if wants_menu==menu_music:
		if wants_menu and enabled and current!=menu_index and menu_index>=0: play_track(menu_index)
		return
	menu_music = wants_menu
	if enabled: next_track()
	else:
		player.stop()
		player.stream_paused = false
		current = -1

func play_track(index: int) -> void:
	if index<0 or index>=tracks.size(): return
	if tracks[index].get("menu_only",false) and not menu_music:
		status = "Save Cave is reserved for menus. Choose another track for this match."
		return
	var stream = load(tracks[index].file)
	if not stream is AudioStream:
		status = "Unable to load this track. Try NEXT."
		return
	if stream is AudioStreamOggVorbis: stream.loop = false
	if current>=0 and current!=index: history.append(current)
	if history.size()>100: history.pop_front()
	current = index
	player.stream = stream
	player.stream_paused = false
	player.volume_db = -80 if volume==0 else linear_to_db(volume)
	player.play()
	enabled = true
	status = ""
	save_settings()

func toggle() -> void:
	if player.stream_paused:
		player.stream_paused = false
		enabled = true
	elif player.playing:
		player.stream_paused = true
		enabled = false
	else: next_track()
	save_settings()

func open(g) -> void:
	if g.modal=="radio": return
	return_modal = g.modal
	g.cancel_drag()
	g.hell_meld.cancel_drag()
	g.modal = "radio"

func filtered_albums() -> Array:
	return albums.filter(func(a): return query=="" or str(a).to_lower().contains(query.to_lower()))

func filtered_tracks() -> Array:
	var result: Array = []
	for i in tracks.size():
		var t: Dictionary = tracks[i]
		if t.album==album and (query=="" or (str(t.title)+" "+str(t.album)+" "+str(t.composer)).to_lower().contains(query.to_lower())): result.append(i)
	return result

func draw(g) -> void:
	g.menu_frame(Rect2(0,0,1440,940))
	g.label_at(Vector2(80,82),"HELL RADIO",38,g.ORANGE)
	g.button(Rect2(1160,40,200,50),"BACK / F8")
	var now := "Choose an album or press PLAY"
	if current>=0: now = tracks[current].album+" / "+tracks[current].title
	g.label_at(Vector2(80,128),now.left(108),20,g.INK)
	g.label_at(Vector2(80,158),str(tracks.size())+" TRACKS / "+["ALBUM ORDER","ALBUM SHUFFLE","ALL MUSIC SHUFFLE"][mode]+(" / PAUSED" if player.stream_paused else ""),16,g.MUTED)
	g.button(Rect2(80,185,170,48),"PAUSE" if player.playing and not player.stream_paused else "PLAY")
	g.button(Rect2(265,185,170,48),"NEXT")
	g.button(Rect2(450,185,170,48),"STOP")
	g.button(Rect2(650,185,60,48),"-")
	g.label_at(Vector2(735,216),"MUSIC %d%%" % roundi(volume*100),19,g.INK)
	g.button(Rect2(925,185,60,48),"+")
	g.label_at(Vector2(1020,216),"%d:%02d" % [int(player.get_playback_position())/60,int(player.get_playback_position())%60],19,g.MUTED)
	for i in 3: g.button(Rect2(80+i*425,255,405,48),("* " if mode==i else "")+["PLAY ALBUM IN ORDER","SHUFFLE THIS ALBUM","SHUFFLE ALL MUSIC"][i])
	g.draw_rect(Rect2(80,320,1280,40),Color("203530"))
	g.label_at(Vector2(95,347),"SEARCH ALBUMS / CURRENT ALBUM TRACKS: "+query+"_",18,g.INK)
	g.label_at(Vector2(80,393),"ALBUMS",20,g.ORANGE)
	g.label_at(Vector2(570,393),album.left(58),20,g.ORANGE)
	var visible_albums := filtered_albums()
	var visible_tracks := filtered_tracks()
	album_page = clampi(album_page,0,maxi(0,(visible_albums.size()-1)/PAGE_SIZE))
	track_page = clampi(track_page,0,maxi(0,(visible_tracks.size()-1)/PAGE_SIZE))
	for row in PAGE_SIZE:
		var a := album_page*PAGE_SIZE+row
		if a<visible_albums.size(): g.button(Rect2(80,410+row*48,460,42),("* " if visible_albums[a]==album else "")+str(visible_albums[a]).left(39))
		var t := track_page*PAGE_SIZE+row
		if t<visible_tracks.size():
			var index: int = visible_tracks[t]
			g.button(Rect2(570,410+row*48,790,42),("PLAYING / " if current==index else "")+str(tracks[index].title).left(66))
	g.button(Rect2(80,810,215,45),"PREV ALBUMS")
	g.button(Rect2(325,810,215,45),"NEXT ALBUMS")
	g.button(Rect2(570,810,375,45),"PREV TRACKS")
	g.button(Rect2(985,810,375,45),"NEXT TRACKS")
	g.label_at(Vector2(80,900),status if status!="" else "Save Cave plays in menus. Your album/shuffle choice plays during matches.",17,g.MUTED)

func handle(g,event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE,KEY_F8]: g.modal = return_modal
		elif event.keycode==KEY_BACKSPACE: query = query.left(maxi(0,query.length()-1))
		elif event.unicode>=32 and query.length()<60: query += String.chr(event.unicode)
		album_page = 0
		track_page = 0
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT): return
	var pos: Vector2 = event.position
	if Rect2(1160,40,200,50).has_point(pos): g.modal = return_modal
	elif Rect2(80,185,170,48).has_point(pos): toggle()
	elif Rect2(265,185,170,48).has_point(pos): next_track()
	elif Rect2(450,185,170,48).has_point(pos):
		player.stop()
		enabled = false
		save_settings()
	elif Rect2(650,185,60,48).has_point(pos) or Rect2(925,185,60,48).has_point(pos):
		volume = clampf(volume+(-0.05 if pos.x<710 else 0.05),0,1)
		player.volume_db = -80 if volume==0 else linear_to_db(volume)
		save_settings()
	elif Rect2(80,810,215,45).has_point(pos): album_page = maxi(0,album_page-1)
	elif Rect2(325,810,215,45).has_point(pos): album_page += 1
	elif Rect2(570,810,375,45).has_point(pos): track_page = maxi(0,track_page-1)
	elif Rect2(985,810,375,45).has_point(pos): track_page += 1
	else:
		for i in 3:
			if Rect2(80+i*425,255,405,48).has_point(pos):
				mode = i
				if mode==0: current = -1
				next_track()
				return
		var aa := filtered_albums()
		var tt := filtered_tracks()
		for row in PAGE_SIZE:
			var a := album_page*PAGE_SIZE+row
			if a<aa.size() and Rect2(80,410+row*48,460,42).has_point(pos):
				album = aa[a]
				track_page = 0
				if mode==2: mode = 0
				current = -1
				next_track()
				return
			var t := track_page*PAGE_SIZE+row
			if t<tt.size() and Rect2(570,410+row*48,790,42).has_point(pos): play_track(tt[t])
