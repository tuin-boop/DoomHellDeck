extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Director = preload("res://scripts/draw_director.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	game = Game.new()
	root.add_child(game)
	root.warp_mouse(Vector2(1420,920))
	var helper = game.battle_tools
	for count in range(6):
		var hand: Array = [0,1,2,3,4]
		var pile: Array = [5,6,7,8,9,10,11,12,13,14,15,16,17,18,19]
		var director = Director.new()
		director.reset(44+count)
		helper.exchange(hand,pile,range(count),director)
		assert(hand.size()==5 and pile.size()==15)
		var all_cards: Array = (hand+pile).map(func(id): return Cards.DATA[id].source_id)
		all_cards.sort()
		assert(all_cards==range(20),"Redraw preserves every deck copy")
		for id in range(count): assert(not hand.has(id),"Rejected copies cannot be immediately redrawn")
		for id in range(count,5): assert(hand.has(id),"Kept cards remain")
	helper.pending = true
	game.modal = "mulligan"
	game.hand = [0,1,7,8,9]
	game.deck = [0,1,2,3,4,5,6,10,11,12,13,14,15,16,17]
	game.enemy_hand = [0,1,7,8,9]
	game.enemy_deck = game.deck.duplicate()
	game.end_turn()
	assert(game.turn==1 and not game.busy,"Cannot attack before confirming the opening hand")
	game.modal_click(Vector2(145+2*232+30,300))
	assert(helper.replaced.has(2))
	if "--visual-test" in OS.get_cmdline_user_args(): await capture("opening-redraw")
	game.modal_click(Vector2(700,770))
	assert(not helper.pending and game.modal=="" and game.hand.size()==5 and game.enemy_hand.size()==5)
	assert(not game.enemy_hand.has(7) and not game.enemy_hand.has(8) and not game.enemy_hand.has(9),"CPU replaces expensive opening cards")
	var original: Array = game.hand.duplicate()
	helper.confirm(game)
	assert(game.hand==original,"Cannot redraw twice")
	game.enemy[0] = Cards.unit(1)
	game.enemy[0].shield = true
	game.hit(1,0,3,"FIRE")
	assert(helper.events[0].detail.contains("Shield consumed"))
	game.hit(1,0,2,"BULLET",true)
	assert(helper.events[0].title.contains("COUNTER") and helper.events[0].detail.contains("ignored"))
	game.damage_hero(0,3)
	assert(helper.events[0].detail.contains("30 -> 27"))
	for i in 30: game.log_line("Visible event %d" % i)
	helper.open_history(game)
	game.modal_click(Vector2(330,830))
	assert(helper.page==1)
	game.modal_click(Vector2(100,170))
	assert(helper.selected==12)
	helper.page = 2
	helper.selected = 30
	if "--visual-test" in OS.get_cmdline_user_args(): await capture("combat-history")
	game.modal_click(Vector2(1200,830))
	assert(game.modal=="")
	game.modal = "deck_guide"
	game.guide_step = 1
	game.guide_cards = Cards.STARTER.duplicate()
	game.modal_click(helper.CURVE_BUTTON.get_center())
	assert(game.modal=="energy_curve")
	var bins: Array = helper.counts(game.guide_cards)
	var total := 0
	for n in bins: total += n
	assert(total==20 and helper.counts([0,0])[Cards.DATA[0].cost]==2)
	if "--visual-test" in OS.get_cmdline_user_args(): await capture("energy-curve")
	game.modal_click(Vector2(1200,830))
	assert(game.modal=="deck_guide")
	print("PASS: redraw 0-5 cards, copy conservation, exclusion, kept cards, CPU redraw, one-use, revealed history, damage details, paging, Energy counts and builder navigation")
	game.queue_free()
	await process_frame
	quit()
func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
