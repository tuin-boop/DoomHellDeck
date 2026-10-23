extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var r = g.radio
	assert(r.tracks.size()==72 and r.albums.size()==4)
	for t in r.tracks:
		assert(t.album in ["DOOM","DOOM II","Donkey Kong Country 2","Donkey Kong Country 3"])
		assert(ResourceLoader.exists(t.file))
	g.frontend.at_home = true
	g.modal = "home"
	r.update_context(g)
	assert(r.current==r.menu_index and r.tracks[r.current].title=="Wrinkly's Save Cave")
	r.next_track()
	assert(r.current==r.menu_index,"Menu theme repeats")
	r.toggle()
	r.update_context(g)
	assert(r.player.stream_paused,"Menu music respects pause")
	r.toggle()
	g.frontend.at_home = false
	g.modal = "hell_meld"
	r.update_context(g)
	assert(r.current!=r.menu_index and not r.pool().has(r.menu_index))
	r.mode = 0
	r.album = r.albums[0]
	var pool: Array = r.pool()
	assert(pool.size()>1)
	r.current = pool[-1]
	assert(r.next_index()==pool[0], "Ordered albums wrap")
	r.mode = 1
	for i in 100:
		var next: int = r.next_index()
		assert(next!=r.current and r.tracks[next].album==r.album)
		r.current = next
	r.mode = 2
	for i in 100:
		var next: int = r.next_index()
		assert(next!=r.current)
		r.current = next
	r.play_track(pool[0])
	assert(r.player.playing and r.player.stream.get_length()>10)
	r.toggle()
	assert(r.player.stream_paused)
	r.toggle()
	assert(not r.player.stream_paused)
	g.modal = "hell_meld"
	r.open(g)
	assert(g.modal=="radio" and r.return_modal=="hell_meld")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/hell-radio.png")
	var escape := InputEventKey.new()
	escape.pressed = true
	escape.keycode = KEY_ESCAPE
	r.handle(g,escape)
	assert(g.modal=="hell_meld" and r.player.playing)
	g.modal = "home"
	g.frontend.click(g,Vector2(1200,50))
	assert(g.modal=="radio" and r.return_modal=="home")
	g.frontend.at_home = true
	g.modal = "home"
	r.update_context(g)
	assert(r.current==r.menu_index,"Returning home restores Save Cave")
	print("PASS: 72 tracks, 4 albums, Save Cave menu/repeat/pause/return, gameplay exclusion, ordered wrap, album/all shuffle, playback, pause/resume, radio return")
	g.queue_free()
	await process_frame
	quit()
