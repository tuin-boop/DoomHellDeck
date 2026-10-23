extends SceneTree
const Game = preload("res://scripts/main.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func right_click(index: int) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	event.position = game.get_global_transform_with_canvas()*game.hand_rect(index).get_center()
	game._unhandled_input(event)
func run() -> void:
	Engine.time_scale = 80
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	game.hand = [0,0,3]
	game.energy = 0
	right_click(1)
	assert(game.squad_marks=={1:true},"Can mark an unaffordable copy independently")
	right_click(1)
	assert(game.squad_marks.is_empty(),"Right click toggles off")
	right_click(1)
	game.modal = "collection"
	right_click(0)
	assert(game.squad_marks=={1:true},"Modal blocks marking hidden hand")
	game.modal = ""
	game.energy = 8
	game.test_mouse(game.hand_rect(0).get_center(),true)
	right_click(0)
	assert(game.squad_marks=={1:true} and game.drag_index==-1,"Drag cancel does not mark")
	game.selected = 0
	await game.play_card(0)
	assert(game.squad_marks=={0:true} and game.hand==[0,3],"Mark follows its copy when an earlier card is played")
	game.selected = 0
	await game.play_card(1)
	assert(game.squad_marks.is_empty() and game.friendly[1].id==0,"Marked card remains playable; mark is consumed")
	right_click(0)
	game.draw_card()
	assert(game.squad_marks=={0:true},"Draw does not transfer mark")
	game.new_battle()
	assert(game.squad_marks.is_empty(),"New match clears reminders")
	print("PASS: independent duplicate markers, affordability, toggle, modal protection, drag cancellation, hand reindexing, playing marks, draw, reset")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	game.queue_free()
	await process_frame
	quit()
