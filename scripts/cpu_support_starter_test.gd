extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	Engine.time_scale = 20
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	assert(game.DeckRules.issue(Cards.SQUAD_STARTER,game.collection).is_empty())
	assert(game.deck_combo_count(Cards.SQUAD_STARTER)>=5)
	var prior: Array = game.deck_book.entries.duplicate(true)
	game.modal = "decks"
	game.deck_manager_click(Vector2(180,860))
	assert(game.deck_book.entries.size()==prior.size()+1)
	assert(game.deck_book.entries[0]==prior[0],"Preset does not overwrite existing deck")
	assert(game.deck_book.entries[-1].cards==Cards.SQUAD_STARTER)
	assert(game.deck_book.activate(game.editing_deck,game.collection))
	game.modal = ""
	var id := Cards.by_actor("VoidPinky")
	game.enemy = [Cards.unit(id),Cards.unit(id),Cards.unit(id),Cards.unit(id)]
	game.friendly = [{},{},{},{}]
	game.enemy_hand = [2]
	game.enemy_energy = 2
	var hp: int = game.enemy[0].hp
	game.deploy_enemy_cards()
	assert(not game.cpu_support.is_empty(),"Supporting card is revealed before bonus")
	var lane: int = game.cpu_support.lane
	assert(game.cpu_support.id==2 and game.enemy[lane].hp==hp and not game.enemy[lane].has("reinforced"))
	await create_timer(1.8).timeout
	assert(game.cpu_support.is_empty() and game.enemy[lane].reinforced and game.enemy[lane].hp==hp+2)
	assert(game.enemy_hand.is_empty() and game.enemy_energy==0 and game.enemy_discard.has(2))
	assert(game.feed.any(func(line): return line.contains("PINKY reinforces VOID PINKY")))
	print("PASS: legal squad preset, five formations, non-destructive deck creation/activation, CPU reveal precedes gain, animation clears, payment/discard/bonus unchanged")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	game.queue_free()
	await process_frame
	quit()
