extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	g.new_battle()
	g.hand = [149]
	g.selected = 0
	g.energy = 8
	g.friendly = [Cards.unit(1),{},{},{}]
	g.enemy = [Cards.unit(2),Cards.unit(5),{},{}]
	assert(Cards.DATA[149].hp==0 and Cards.DATA[149].level==1)
	assert(not g.art.textures.PLAS.is_empty())
	assert(g.weapon_target_at(g.lane_rect(1,0).get_center())==4)
	assert(g.weapon_target_at(g.lane_rect(0,0).get_center())==0)
	assert(g.weapon_target_at(g.lane_rect(1,3).get_center())==-1)
	await g.play_card(7)
	assert(g.hand.size()==1 and g.energy==8)
	g.hero_power.pointer = g.lane_rect(1,0).get_center()
	for frame in 30: await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/plasma-target-arrow.png")
	var hp: int = g.enemy[0].hp
	await g.play_card(4)
	assert(g.enemy[0].hp==hp-4 and g.energy==4 and g.hand.is_empty())
	assert(not g.discard.has(149) and g.friendly[0].hp==Cards.DATA[1].hp)
	g.hand = [149]
	g.selected = 0
	hp = g.enemy[1].hp
	await g.play_card(5)
	assert(g.enemy[1].hp==hp and not g.enemy[1].shield)
	g.hand = [149]
	g.selected = 0
	g.energy = 8
	await g.play_card(0)
	assert(g.friendly[0].is_empty())
	g.souls = 5
	g.hero_power.armed = true
	g.hero_power.pointer = g.lane_rect(1,1).get_center()
	assert(g.hero_power.target_at(g.lane_rect(0,0).get_center())==-1)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/hero-target-arrow.png")
	print("PASS: weapon targeting, invalid target safety, energy, damage, shields, friendly targets, exhaust and no retaliation")
	g.queue_free()
	await process_frame
	quit()
