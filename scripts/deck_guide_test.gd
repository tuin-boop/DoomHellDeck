extends SceneTree
const Game = preload("res://scripts/main.gd")
const Guide = preload("res://scripts/deck_guide.gd")
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const Squads = preload("res://scripts/squads.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func capture(name: String) -> void:
	if "--visual-test" not in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/deck-guide-"+name+".png")
func click(pos: Vector2) -> void:
	game.deck_guide_click(pos)
	game.guide_tutorial = false

func run() -> void:
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	for index in Squads.COMBOS.size():
		var deck := Guide.seed_squads([index],game.collection)
		assert(Guide.complete(deck,index),"Every single squad can be seeded")
		var full := Guide.fill(deck,[index],game.collection)
		assert(Rules.issue(full,game.collection).is_empty())
		assert(Guide.complete(full,index),"Fill preserves squad picks")
	var limited: Array = []
	limited.resize(Cards.CATALOG_SIZE)
	limited.fill(0)
	limited[0] = 1
	assert(Guide.fill([],[],limited)==[0],"Never invent unowned cards")
	game.modal = "decks"
	game.deck_manager_click(Vector2(450,860))
	assert(game.modal=="deck_guide")
	game.guide_tutorial = false
	click(game.guide_squad_rect(1).get_center())
	click(game.guide_squad_rect(3).get_center())
	await capture("squads")
	click(Vector2(1100,870))
	assert(game.guide_step==1 and Guide.complete(game.guide_cards,1) and Guide.complete(game.guide_cards,3))
	var original: Array = game.guide_cards.duplicate()
	click(Vector2(76+3*125+10,160))
	assert(game.guide_rarity==2)
	var suggestions := Guide.suggestions(game.guide_cards,game.guide_squads,game.collection,2)
	assert(not suggestions.is_empty() and suggestions.all(func(id): return Cards.DATA[id].rarity==2))
	click(game.guide_card_rect(0).get_center())
	assert(game.guide_cards.size()==original.size()+1)
	await capture("cards")
	click(Vector2(1000,225+(game.guide_cards.size()-1)*25))
	assert(game.guide_cards==original,"Removal edits only the chosen copy")
	click(Vector2(650,810))
	assert(Rules.issue(game.guide_cards,game.collection).is_empty())
	for id in original: assert(game.guide_cards.count(id)>=original.count(id))
	click(Vector2(1100,870))
	assert(game.guide_step==2)
	await capture("review")
	var old_active: int = game.deck_book.active
	var count: int = game.deck_book.entries.size()
	click(Vector2(1100,870))
	assert(game.modal=="deck_name" and game.deck_book.entries.size()==count+1)
	game.name_input.text = "My Guided Squad"
	game.finish_deck_name(true)
	assert(game.deck_book.entries[-1].name=="My Guided Squad" and game.deck_book.active==old_active)
	assert(Rules.issue(game.deck_book.entries[-1].cards,game.collection).is_empty())
	game.deck_book.activate(game.deck_book.entries.size()-1,game.collection)
	assert(game.deck_book.active==count)
	print("PASS: all 18 squad seeds/fills, ownership, rarity suggestions, UI pick/remove/review/name, legal deck and explicit activation")
	game.queue_free()
	await process_frame
	quit()
