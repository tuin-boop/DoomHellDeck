extends SceneTree
## Render two deterministic Armory frames to check the live artwork path.
const Game = preload("res://scripts/main.gd")

func _initialize() -> void:
	if not "--balance-test" in OS.get_cmdline_user_args():
		quit(1)
		return
	run.call_deferred()

func run() -> void:
	var game = Game.new()
	root.add_child(game)
	game.set_process(false)
	game.modal = "collection"
	game.pack_only = true
	game.collection_page = 0
	game.toast_time = 0.0
	var captures: Array[Image] = []
	for tick in 2:
		game.clock = tick * 0.4
		game.queue_redraw()
		await RenderingServer.frame_post_draw
		var rendered := root.get_texture().get_image()
		rendered.save_png("res://captures/armory-animation-%d.png" % tick)
		captures.append(rendered)
	assert(captures[0].get_data()!=captures[1].get_data(),"Armory must redraw its animated art")
	print("PASS: Armory renders different poses at consecutive animation ticks")
	quit()
