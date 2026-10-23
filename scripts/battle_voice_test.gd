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
	var voice = game.battle_voice
	assert(voice.glyphs.size()>=58,"Original WAD alphabet loaded")
	for character in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!?":
		assert(voice.glyphs.has(character))
	var state: int = game.rng.state
	for commander in Commanders.ROSTER:
		voice.reset(commander.id)
		var opening: String = voice.speech
		voice.react("losing")
		assert(voice.speech==opening,"Cooldown prevents spam")
		voice.cooldown = 0
		voice.react("losing")
		assert(voice.speech!=opening)
		var losing: String = voice.speech
		voice.cooldown = 0
		voice.react("winning")
		voice.react("losing")
		assert(voice.speech!=losing,"Each swing reaction plays once per battle")
		voice.react("defeat",true)
		assert(voice.speech==voice.LINES[commander.id][4])
	assert(game.rng.state==state)
	assert(voice.speaking_portrait_rect(0).is_equal_approx(Rect2(444,16,88,88)))
	assert(voice.speaking_portrait_rect(1).get_center().is_equal_approx(voice.speech_center))
	assert(voice.speech_center.x>=635 and voice.speech_center.x<=805)
	assert(absf(voice.speech_tilt)<=deg_to_rad(7))
	assert(voice.speaking_portrait_rect(1).size.x==224)
	assert(voice.speaking_portrait_rect(5.5).is_equal_approx(Rect2(444,16,88,88)),"Portrait returns exactly home")
	game.modal = "commanders"
	game._process(0)
	assert(not voice.visible and not voice.is_processing(),"Menus hide and pause dialogue")
	game.modal = ""
	game._process(0)
	assert(voice.visible and voice.is_processing())
	game.enemy_hp = 0
	game.player_hp = 10
	assert(game.check_end())
	assert(voice.headline=="VICTORY" and voice.outcome)
	game.new_battle()
	game.player_hp = 0
	assert(game.check_end())
	assert(voice.headline=="DEFEAT" and voice.speech==voice.LINES[game.enemy_commander][3])
	game.new_battle()
	assert(not voice.outcome and voice.seen.size()==1)
	if "--visual-test" in OS.get_cmdline_user_args():
		game.enemy_commander = "oculus"
		voice.reset("oculus")
		voice.react("losing",true)
		voice.announce("ENEMY ATTACK")
		await create_timer(0.95).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/doom-lettering-dialogue.png")
		game.enemy_hp = 0
		game.check_end()
		await create_timer(0.95).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/doom-lettering-victory.png")
	print("PASS: WAD glyph coverage, five distinct voices, cooldown, one-shot reactions, forced results, reset, combat RNG unchanged")
	game.queue_free()
	await process_frame
	quit()
