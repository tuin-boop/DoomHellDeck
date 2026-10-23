extends SceneTree
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var g = preload("res://scripts/main.gd").new()
	root.add_child(g)
	root.warp_mouse(Vector2(1420,920))
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99
	g.hand = []
	var state: int = g.rng.state
	var flair = g.match_flair
	var seen := {}
	for trial in 100:
		var delay: float = flair.next_scenery_effect-flair.scenery_time
		assert(delay>=10 and delay<=45)
		flair.tick(g,delay)
		for i in 5:
			if flair.ambient_started[i]!=flair.scenery_time: continue
			seen[i] = true
			var duration := 6.0 if i in [1,2,4] else 3.6
			assert(flair.ambient_strength(i,flair.scenery_time)==0)
			assert(flair.ambient_strength(i,flair.scenery_time+duration/2)>0.6)
			assert(flair.ambient_strength(i,flair.scenery_time+duration+0.1)==0)
	assert(seen.size()==5 and g.rng.state==state)
	for i in 5: assert(g.match_flair.click_toy(g,g.match_flair.scenery_center(g,i)))
	assert(g.rng.state==state)
	g.match_flair.toy_age = [0.25,0.25,0.25,0.25,0.25]
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/background-interactions.png")
	for i in [0,3]:
		flair.green_eyes[i] = true
		flair.ambient_started[i] = flair.scenery_time-1.8
	flair.ambient_started[1] = flair.scenery_time-3.0
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/background-green-eyes.png")
	g.selected = 0
	assert(not g.match_flair.click_toy(g,g.match_flair.scenery_center(g,0)))
	g.selected = -1
	g.modal = "home"
	assert(not g.match_flair.click_toy(g,g.match_flair.scenery_center(g,0)))
	g.modal = ""
	g.enemy[1] = g.Cards.unit(0)
	var covered: Vector2 = g.match_flair.scenery_offset(g)+Vector2(260,130)*g.match_flair.scenery_scale(g)
	assert(g.lane_rect(1,1).has_point(covered))
	assert(not g.match_flair.click_toy(g,covered),"Card gets priority")
	g.match_flair.prepare_mask()
	assert(g.match_flair.mask_textures.size()==5)
	var skull: Image = g.match_flair.mask_textures[0].get_image()
	assert(skull.get_pixel(0,0).a==0,"Black mask stays transparent")
	g.match_flair.tick(g,3)
	assert(g.match_flair.toy_age[0]>2.4)
	print("PASS: five background hotspots, no combat RNG changes, card/selection/menu priority, glow expires")
	g.queue_free()
	await process_frame
	quit()
