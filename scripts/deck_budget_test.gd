extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const Guide = preload("res://scripts/deck_guide.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	game = Game.new()
	root.add_child(game)
	var owned: Array = game.collection
	assert(Rules.points(0)==3 and Rules.points(25)==7)
	assert(Rules.points(63)==Cards.DATA[63].cost+11)
	var heavy: Array = [63,64,44,45,46,47]
	for id in range(25,44):
		if Rules.issue(heavy+[id],owned,false).is_empty(): heavy.append(id)
	assert(heavy.size()<20 and Rules.cost(heavy)<=120)
	assert(Rules.completion_message(heavy,owned).contains("free at least"))
	var filled := Guide.fill(heavy,[],owned)
	assert(filled.size()<20 and not Rules.issue(filled,owned).is_empty())
	for id in heavy: assert(filled.count(id)>=heavy.count(id),"Never discard expensive player picks to pretend a deck fits")
	var draft: int = game.deck_book.create("Premium draft",filled)
	assert(not game.deck_book.activate(draft,owned))
	var old_starter: Array = [0,0,0,1,12,2,14,3,15,4,16,5,17,6,7,22,9,10,13,11]
	assert(Rules.cost(old_starter)>120)
	assert(game.apply_saved_progress({"version":1,"collection":owned,"deck":old_starter,"credits":333,"wins":9}))
	assert(game.deck_book.entries[0].cards==old_starter and game.credits==333 and game.wins==9)
	assert(Rules.issue(game.deck_book.battle_cards(),owned).is_empty())
	assert(Rules.issue(Cards.SQUAD_STARTER,owned).is_empty())
	if "--visual-test" in OS.get_cmdline_user_args():
		game.modal = "deck_guide"
		game.guide_step = 1
		game.guide_cards = heavy
		game.guide_message = "Expensive picks stay yours. Remove some to make room for a complete deck."
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/deck-budget-warning.png")
	print("PASS: higher rarity prices, premium-heavy deck cannot reach 20, draft activation blocked, auto-fill preserves picks, legacy deck/progress preserved, legal starters")
	game.queue_free()
	await process_frame
	quit()

