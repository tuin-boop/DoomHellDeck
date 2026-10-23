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
	var g = Game.new()
	root.add_child(g)
	g.new_battle()
	var draft: Array = []
	var pool: Array = range(Cards.CATALOG_SIZE)
	pool.sort_custom(func(a,b): return g.DeckRules.points(a)>g.DeckRules.points(b))
	for id in pool:
		for copy in 3:
			if draft.size()==15: break
			if g.DeckRules.issue(draft+[id],g.collection,false).is_empty() and g.DeckRules.cost(draft+[id])+(14-draft.size())*3<=118: draft.append(id)
	print("FIXTURE ",draft.size()," cards ",g.DeckRules.cost(draft)," points ",draft)
	assert(draft.size()==15 and g.DeckRules.cheapest_fill(draft,g.collection).size()<20)
	var index: int = g.deck_book.create("My unfinished deck",draft)
	var count: int = g.deck_book.entries.size()
	g.open_guided_deck(index)
	assert(g.guide_cards==draft and g.guide_tutorial)
	await capture("deck-builder-tutorial")
	g.deck_guide_click(Vector2(650,615))
	g.deck_guide_click(Vector2(500,875))
	assert(g.guide_step==3 and g.guide_repair.possible and not g.guide_repair.cuts.is_empty())
	assert(g.deck_book.entries[index].cards==draft)
	await capture("deck-suggested-cuts")
	g.deck_guide_click(Vector2(650,875))
	assert(g.guide_cards.size()<draft.size() and g.guide_step==1)
	g.deck_guide_click(Vector2(650,810))
	assert(g.DeckRules.issue(g.guide_cards,g.collection).is_empty())
	g.deck_guide_click(Vector2(1100,875))
	assert(g.guide_step==2 and g.guide_tutorial)
	g.deck_guide_click(Vector2(650,615))
	g.deck_guide_click(Vector2(1100,875))
	assert(g.deck_book.entries.size()==count and g.editing_deck==index)
	g.finish_deck_name(true)
	assert(g.deck_book.entries[index].name=="My unfinished deck")
	assert(g.DeckRules.issue(g.deck_book.entries[index].cards,g.collection).is_empty())
	# Cancel retains the saved deck, including with a full library.
	while g.deck_book.entries.size()<8: g.deck_book.create("Draft",[])
	g.open_guided_deck(index)
	g.guide_cards.clear()
	g.guide_tutorial = false
	g.deck_guide_click(Vector2(1250,65))
	assert(g.deck_book.entries[index].cards.size()==20)
	g.new_battle()
	g.enemy_hp = 0
	g.check_end()
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99
	var reward: int = g.rewards[0]
	var owned: int = g.collection[reward]
	g.modal_click(Vector2(450,400))
	assert(g.modal=="reward" and g.reward_claimed and g.collection[reward]==owned+1)
	g.modal_click(Vector2(450,400))
	assert(g.collection[reward]==owned+1)
	await capture("victory-next-or-menu")
	g.modal_click(Vector2(500,875))
	assert(g.modal=="home" and not g.frontend.started)
	g.new_battle()
	g.enemy_hp = 0
	g.check_end()
	g.modal_click(Vector2(450,400))
	g.modal_click(Vector2(850,875))
	assert(g.modal=="new_match")
	g.commander_selected = true
	g.frontend.click(g,Vector2(300,440))
	assert(not g.ended and not g.reward_claimed and g.player_hp==30)
	print("PASS: 15-card budget repair, non-destructive suggestions, tutorial, save to existing deck, cancel, reward once, main menu and next match")
	g.queue_free()
	await process_frame
	quit()
