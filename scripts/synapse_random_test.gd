extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
func _initialize() -> void:
	run.call_deferred()
func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func run() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	Engine.time_scale = 25
	var g = Game.new()
	root.add_child(g)
	g.chosen_commander = "synapse"
	g.new_battle()
	g.open_commanders()
	await capture("synapse-selection")
	assert(g.commander_choice_rect(5).end.x<1440)
	g.modal = ""
	for side in 2:
		g.new_battle()
		if side==1: g.enemy_commander = "synapse"
		var row: Array = [Cards.unit(1),{},Cards.unit(1),Cards.unit(1)]
		row[0].hp = 1
		row[2].shield = true
		if side==0: g.enemy = row
		else: g.friendly = row
		g.souls = 5
		g.hero_power.cpu_souls = 5
		await g.hero_power.activate(side,0)
		assert(row[0].is_empty() and not row[2].shield and row[2].hp==4 and row[3].hp==3)
		assert(g.hero_power.used[side])
		assert(not g.battle_tools.events.any(func(e): return "retaliates" in e.title))
	g.new_battle()
	g.souls = 5
	var hp: int = g.enemy_hp
	await g.hero_power.activate(0,4)
	assert(g.enemy_hp==hp-3)
	var saved: Dictionary = g.deck_book.snapshot()
	g.modal = "home"
	g.frontend.choose_match(g)
	g.commander_selected = true
	g.frontend.click(g,Vector2(300,580))
	assert(g.next_random_mode and g.random_mode)
	await capture("random-cards-menu")
	g.new_battle()
	assert(g.random_mode and g.deck.size()+g.hand.size()==20 and g.enemy_deck.size()+g.enemy_hand.size()==20)
	assert(g.player_hp==30 and g.enemy_hp==30 and g.deck_book.snapshot()==saved)
	var original: Array = g.deck+g.hand
	g.new_battle()
	assert(g.deck+g.hand!=original and g.deck_book.snapshot()==saved)
	var seen := {}
	for i in 100:
		var random_deck: Array = g.random_match_deck()
		assert(random_deck.size()==20)
		for id in random_deck: seen[id] = true
	assert(seen.size()>150,"Full catalogue including weapons and rare cards is eligible")
	g.hand = []
	g.deck = [81,150]
	g.draw_card()
	assert(g.hand==[150] and g.deck==[81],"No director weighting or level conversion")
	g.next_random_mode = false
	assert(g.random_mode,"Changing next mode does not alter current match")
	g.new_battle()
	assert(not g.random_mode and g.deck_book.snapshot()==saved)
	print("PASS: sixth hero selection, both-side three-target volley through gaps, shields, lethal primary, hero damage, soul use, random mode 20-card decks, full roster, unchanged saved decks and mode isolation")
	g.queue_free()
	await process_frame
	quit()
