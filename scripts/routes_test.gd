extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var m = Meld.new()
	m.relic = -1
	m.modifier = 3
	assert(m.score_play(0,[0,0],{"gain":10,"kind":"set"},false).round_bonus==0)
	m.mutation_last = ["run", "set"]
	assert(m.score_play(0,[0,0],{"gain":10,"kind":"set"},false).round_bonus==10)
	assert(m.score_play(1,[0,0],{"gain":10,"kind":"set"},false).round_bonus==0)
	m.modifier = 4
	assert(m.score_play(0,[0],{"gain":20,"kind":"set"},true).round_bonus==4)
	m.extension_chain = 8
	assert(m.score_play(1,[0],{"gain":20,"kind":"set"},true).round_bonus==20)
	assert(m.score_play(0,[0,0],{"gain":10,"kind":"set"},false).round_bonus==0)
	m.draw_one(0)
	assert(m.extension_chain==0)
	for mutation in [5,6,7]:
		m.modifier = mutation
		var ids: Array = [0,0,0,0] if mutation==7 else [0,0]
		for owner in 2:
			assert(m.score_play(owner,ids,{"gain":10,"kind":"set"},false).round_bonus==(12 if mutation==7 else 8))
	m.upgrade_offers = ["set","run","team"]
	m.modifier = 3
	m.make_routes()
	var seen := []
	for route in m.route_offers:
		assert(route.modifier!=3 and not route.modifier in seen)
		seen.append(route.modifier)
	var picked: Dictionary = m.route_offers[1].duplicate()
	m.round_over = true
	m.upgrade_pending = true
	m.choose_upgrade(1)
	assert(m.modifier==picked.modifier and m.relic==picked.relic)
	assert(m.round_number==2 and m.upgrades[0].run==1)
	assert(m.extension_chain==0 and m.mutation_last==["",""])
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	g.hell_meld.start(g)
	m = g.hell_meld
	m.support.pending = false
	m.round_intro = false
	m.finish_round(0,"test")
	m.power_panel = true
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/routes.png")
	print("PASS: routes, shared mutations, thresholds, resets and chosen battlefield")
	quit()
