extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	Engine.time_scale = 50
	var g = Game.new()
	root.add_child(g)
	g.new_battle()
	g.busy = true
	for id in g.Weapons.IDS:
		assert(Cards.DATA[id].hp==0 and Cards.DATA[id].exhaust)
		assert(not g.art.textures[Cards.DATA[id].art].is_empty(),"Weapon artwork must load")
		for side in 2:
			for defender in [1,5,22,145,20]:
				var row: Array = [Cards.unit(1),Cards.unit(defender),Cards.unit(2),{}]
				if defender==20: row[1].hp = 1
				var preview: Dictionary = g.Weapons.preview(id,row,1)
				g.friendly = row if side==0 else [{},{},{},{}]
				g.enemy = row if side==1 else [{},{},{},{}]
				await g.fire_weapon(id,side,1,Vector2(720,800),1-side)
				for lane in 4:
					assert(row[lane].is_empty()==preview.row[lane].is_empty())
					if not row[lane].is_empty():
						assert(row[lane].id==preview.row[lane].id and row[lane].hp==preview.row[lane].hp and row[lane].shield==preview.row[lane].shield,"Preview and live damage must match")
				assert(not g.battle_tools.events.any(func(e): return "retaliates" in e.title))
	g.busy = false
	g.friendly = [{},{},{},{}]
	g.enemy = [Cards.unit(2),{},{},{}]
	for id in range(149,155):
		g.hand = [id]
		g.selected = 0
		g.energy = Cards.DATA[id].cost-1
		await g.play_card(4)
		assert(g.hand==[id] and g.energy==Cards.DATA[id].cost-1)
	assert(g.EnemyAI.plan([{},{},{},{}],g.enemy,[150],8,30,30).is_empty(),"Weapons cannot be deployed as monsters")
	g.new_battle()
	g.friendly = [Cards.unit(1),{},{},{}]
	g.friendly[0].hp = 2
	g.enemy_hand = [150]
	g.enemy_energy = 2
	await g.deploy_enemy_cards()
	assert(g.friendly[0].is_empty() and g.enemy_hand.is_empty() and g.enemy_energy==0)
	g.hand = [150,151,152,153,154,149]
	g.selected = -1
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/ranged-weapons.png")
	print("PASS: all seven weapon arts, 70 live/preview comparisons, shields, armour, mech suit, death-spawn safety, no counters, unaffordable safety, CPU use")
	g.queue_free()
	await process_frame
	quit()
