extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const Book = preload("res://scripts/deck_book.gd")
const AI = preload("res://scripts/enemy_ai.gd")

func _initialize() -> void:
	if not "--balance-test" in OS.get_cmdline_user_args():
		quit(1)
		return
	run.call_deferred()

func run() -> void:
	var owned: Array = []
	owned.resize(Cards.CATALOG_SIZE)
	owned.fill(3)
	print("Starter points: ",Rules.cost(Cards.STARTER),"; mix: ",Rules.cost(Cards.pack_starter()))
	assert(Rules.issue(Cards.STARTER,owned).is_empty(),Rules.issue(Cards.STARTER,owned))
	var mix := Rules.legalize(Cards.pack_starter())
	assert(Rules.issue(mix,owned).is_empty())
	assert(not Rules.issue([0,0,0,0],owned,false).is_empty())
	assert(not Rules.issue([9,9],owned,false).is_empty())
	assert(not Rules.issue([Cards.leveled_id(0,10)],owned,false).is_empty())
	assert(Rules.issue([7,9,12,13,19,21,22],owned,false).contains("Maximum 6"))
	assert(Rules.issue([63,64,65],owned,false).contains("Maximum 2 Mythic"))
	var costly: Array = []
	for id in Cards.CATALOG_SIZE:
		if Cards.DATA[id].rarity<=1 and Cards.DATA[id].cost>=4:
			for copy in Rules.copies(id): costly.append(id)
	costly = costly.slice(0,20)
	assert(Rules.issue(costly,owned).contains("Over budget"))
	var uniques := {}
	for seed_value in 100:
		var cpu := AI.deck_for(seed_value%6,seed_value)
		assert(Rules.issue(cpu,owned).is_empty())
		assert(cpu.all(func(id): return Cards.DATA[id].hp>0 or Cards.DATA[id].get("targeted",false)),"CPU cards must be playable units or weapons")
		assert(cpu==AI.deck_for(seed_value%6,seed_value))
		var squad := false
		for theme in AI.THEMES:
			if theme.all(func(actor): return cpu.has(Cards.by_actor(actor))): squad = true
		assert(squad,"CPU keeps a complete themed squad")
		uniques[str(cpu)] = true
	assert(uniques.size()>10)
	var random := RandomNumberGenerator.new()
	random.seed = 7
	var base_cpu := AI.DECK.duplicate()
	var combo_cpu := AI.add_support_combo(base_cpu,random)
	var Squads = preload("res://scripts/squads.gd")
	assert(Rules.issue(combo_cpu).is_empty() and combo_cpu.slice(0,3)==base_cpu.slice(0,3))
	assert(Squads.active(combo_cpu.map(func(id): return Cards.unit(id))).size()>Squads.active(base_cpu.map(func(id): return Cards.unit(id))).size())
	var book = Book.new()
	var index: int = book.create("My Demons",[])
	assert(index==1 and not book.activate(index,owned))
	book.rename(index,"Frost Squad")
	book.entries[index].cards = mix
	assert(book.activate(index,owned))
	var restored = Book.new()
	restored.restore(JSON.parse_string(JSON.stringify(book.snapshot())),Cards.STARTER,owned)
	assert(restored.entries==book.entries and restored.active==index)
	assert(restored.remove(0,owned) and restored.active==0)
	assert(not restored.remove(0,owned))
	assert(restored.create("Frost Squad",[])==1 and restored.entries[1].name=="Frost Squad 2")
	while restored.entries.size()<Book.LIMIT: restored.create("Draft",[])
	assert(restored.create("Overflow",[])==-1)
	var game = Game.new()
	root.add_child(game)
	var original_match: Array = game.deck.duplicate()
	# Armory checks the working deck, not the board, hand or owned collection.
	game.decklist = [0,18]
	assert(game.deck_combo_count(game.decklist)==1)
	game.modal = "collection"
	game.modal_click(game.DECK_COMBOS_BUTTON.get_center())
	assert(game.modal=="deck_combos")
	game.modal_click(Vector2(100,270))
	assert(game.modal=="collection" and game.armory_combo_filter==2)
	assert(game.armory_ids().has(0) and game.armory_ids().has(18) and not game.armory_ids().has(1))
	game.modal_click(game.DECK_FILTER.get_center())
	assert(game.armory_combo_filter==-1)
	game.decklist = Cards.STARTER.duplicate()
	game.modal = "collection"
	game.modal_click(game.DECKS_BUTTON.get_center())
	assert(game.modal=="decks")
	game.deck_manager_click(Vector2(150,800))
	assert(game.modal=="deck_name" and game.name_input!=null)
	game.name_input.text = "Custom Deck"
	game.finish_deck_name(true)
	assert(game.modal=="collection" and game.decklist.is_empty())
	assert(game.deck==original_match,"Deck editing must not affect the current match")
	game.close_collection()
	assert(game.deck_book.entries[1].cards.is_empty() and game.deck_book.active==0)
	var persisted := game.progress_data()
	assert(game.apply_saved_progress(JSON.parse_string(JSON.stringify(persisted))))
	assert(game.deck_book.entries.size()==2 and game.deck_book.entries[1].name=="Custom Deck")
	game.editing_deck = 1
	game.decklist = mix.duplicate()
	game.close_collection()
	assert(game.deck_book.active==1)
	game.new_battle()
	var drawn: Array = game.deck+game.hand
	drawn.sort()
	var expected := mix.duplicate()
	expected.sort()
	assert(drawn.map(func(id): return Cards.DATA[id].source_id)==expected)
	# Legacy invalid decks are preserved, but may not bypass the new battle rules.
	var old := Cards.STARTER.duplicate()
	old[0] = 9
	old[1] = 9
	assert(game.apply_saved_progress({"version":1,"collection":owned,"deck":old,"wins":8,"credits":400}))
	assert(game.decklist==old and game.deck_book.active!=0 and game.wins==8 and game.credits==400)
	assert(Rules.issue(game.deck_book.battle_cards(),owned).is_empty())
	# Editing filters must keep source IDs stable when the last copy disappears.
	game.deck_only = true
	game.decklist = [0,1]
	game.modal = "collection"
	game.modal_click(game.collection_rect(0).position+Vector2(20,240))
	assert(game.decklist==[1] and game.armory_ids()==[1])
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	await process_frame
	print("PASS: deck creation, names, deletion, drafts, activation, JSON reload, migration, copy limits and 100 legal CPU decks (",uniques.size()," different lists)")
	quit()
