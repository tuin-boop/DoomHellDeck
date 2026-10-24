extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.start(g)
	var common := 0
	var rare := 0
	m.support.slots = [[39],[39]]
	for trial in 3000:
		var offers: Array = m.support.draft_offers(m,0)
		assert(offers.size()==3 and offers[0]!=offers[1] and offers[1]!=offers[2] and offers[0]!=offers[2] and not offers.has(39))
		for id in offers:
			if m.support.rarity(id)=="COMMON": common += 1
			if m.support.rarity(id)=="RARE": rare += 1
	assert(common>rare*3)
	m.support.offers = [0,9,17]
	m.support.draft_age = 0.4
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/rarity-crates.png")
	m.support.pending = false
	m.round_intro = false
	m.draw_flights.clear()
	m.support.slots = [[0,25,22],[0]]
	m.hands[0] = [8,21,6]
	m.side = 0
	assert(m.play(0,[0,1,2],-1))
	m.announcement.gibs = true
	m.banner_age = 1.3
	assert(m.effects.gain_shown(m)<m.announcement.gain)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/combo-finisher.png")
	m.banner_age = 2.2
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/joker-score-chain.png")
	m.banner_age = 99
	assert(is_equal_approx(m.effects.gain_shown(m),m.announcement.gain))
	m.finish_round(0,"won")
	m.result_age = 1.1
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/round-score-tally.png")
	print("PASS: weighted unique offers, scoring animation endpoints, crate/finisher/chain/tally rendering; Common ",common," Rare ",rare)
	quit()
