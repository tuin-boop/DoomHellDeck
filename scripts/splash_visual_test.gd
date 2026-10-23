extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var finished := false
func _initialize() -> void:
	run.call_deferred()
func attack(g, side: int) -> void:
	await g.attack_once(side,1)
	finished = true
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	root.warp_mouse(Vector2(1420,920))
	for side in 2:
		g.new_battle()
		g.cinematic_enabled = true
		g.battle_voice.speech_age = 99
		g.battle_voice.headline_age = 99
		var attackers: Array = [{},Cards.unit(3),{},{}]
		var defenders: Array = [Cards.unit(1),Cards.unit(19),Cards.unit(1),{}]
		g.friendly = attackers if side==0 else defenders
		g.enemy = defenders if side==0 else attackers
		g.busy = true
		finished = false
		attack(g,side)
		while not g.duel_struck: await process_frame
		assert(g.duel_splash_targets.size()==2)
		assert(defenders[0].hp==Cards.DATA[1].hp-1 and defenders[2].hp==Cards.DATA[1].hp-1)
		assert(g.duel_hit_position(1-side,0).distance_to(g.lane_rect(1-side,0).get_center())>30)
		if side==0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://captures/splash-targets-visible.png")
		while not finished: await process_frame
		var counters: Array = g.battle_tools.events.filter(func(e): return "retaliates" in e.title)
		assert(counters.size()==1,"Only primary defender counters")
	g.new_battle()
	g.friendly = [Cards.unit(23),{},{},{}]
	g.Squads.reinforce(g.friendly[0],Cards.leveled_id(1,2))
	root.warp_mouse(g.get_global_transform_with_canvas()*g.lane_rect(0,0).get_center())
	await process_frame
	assert(g.inspected_unit_location()==Vector2i(0,0))
	assert(g.inspected_card()==g.friendly[0].id)
	await process_frame
	assert(g.friendly[0].reinforced and g.Squads.attack_value(g.friendly,0)==Cards.DATA[g.friendly[0].id].atk+1)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/reinforced-inspector.png")
	print("PASS: splash targets visible both sides, damage unchanged, only main defender counters, live reinforced unit inspection")
	g.queue_free()
	await process_frame
	quit()
