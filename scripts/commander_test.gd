extends SceneTree
const Game = preload("res://scripts/main.gd")
const Commanders = preload("res://scripts/commanders.gd")
var game

func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()

func run() -> void:
	game = Game.new()
	root.add_child(game)
	var random := RandomNumberGenerator.new()
	random.seed = 1983
	for character in Commanders.ROSTER:
		assert(character.portrait.get_width()>0)
		var seen := {}
		for i in 100:
			var rival := Commanders.opponent(character.id,random)
			assert(rival != character.id and Commanders.valid(rival))
			seen[rival] = true
		assert(seen.size()==Commanders.ROSTER.size()-1)
	var saved: Dictionary = game.progress_data().duplicate(true)
	saved.commander = "oculus"
	assert(game.apply_saved_progress(saved))
	assert(game.chosen_commander=="oculus" and game.commander_selected)
	game.new_battle()
	assert(game.player_commander=="oculus" and game.enemy_commander!="oculus")
	var previous_rival: String = game.enemy_commander
	var combat_rng_state: int = game.rng.state
	game.open_commanders()
	game.modal_click(game.commander_choice_rect(2).get_center())
	game.modal_click(Vector2(700,675))
	assert(game.chosen_commander=="iron_tyrant")
	assert(game.player_commander=="oculus" and game.enemy_commander==previous_rival)
	assert(game.rng.state==combat_rng_state)
	assert(game.progress_data().commander=="iron_tyrant")
	game.new_battle()
	assert(game.player_commander=="iron_tyrant" and game.enemy_commander!="iron_tyrant")
	saved.erase("commander")
	assert(game.apply_saved_progress(saved))
	assert(game.chosen_commander==Commanders.DEFAULT and not game.commander_selected)
	for invalid in [null,12,true,"missing",[],{}]:
		saved.commander = invalid
		assert(game.apply_saved_progress(saved))
		assert(game.chosen_commander==Commanders.DEFAULT and not game.commander_selected)
	game.initial_commander_choice = true
	game.open_commanders()
	game.modal_click(game.commander_choice_rect(0).get_center())
	game.modal_click(Vector2(700,675))
	assert(game.player_commander=="ashfang" and game.enemy_commander!="ashfang")
	assert(not game.initial_commander_choice and game.modal=="")
	if "--visual-test" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/commander-table.png")
		game.open_commanders()
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/commander-chooser.png")
	print("PASS: five portraits, 500 opponent picks exclude self and reach all rivals, saved selection, invalid/legacy fallback, next-match identity, first-choice flow, independent combat RNG")
	game.queue_free()
	await process_frame
	quit()
