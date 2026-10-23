extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const AI = preload("res://scripts/enemy_ai.gd")
const Squads = preload("res://scripts/squads.gd")
var game
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	Engine.time_scale = 80
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	var old: Array = []
	old.resize(145)
	old.fill(3)
	assert(game.apply_saved_progress({"version":2,"wins":4,"credits":123,"collection":old,"deck":Cards.SQUAD_STARTER.duplicate()}))
	assert(game.collection.size()==Cards.CATALOG_SIZE and game.decklist==Cards.SQUAD_STARTER and game.wins==4 and game.credits==123)
	var mech := Cards.by_actor("MechaHitler")
	assert(mech==145 and Cards.by_actor("Schabbs")==146 and Cards.by_actor("Hans")==147)
	for id in range(145,148):
		var data: Dictionary = Cards.DATA[id]
		for bank in [game.art.textures,game.art.attack_textures,game.art.side_textures,game.art.side_attack_textures]:
			assert(bank[data.art].size()>=2)
		for event in ["summon","attack","death"]:
			var path: String = game.art.monster_sounds[data.art][event][0]
			assert(game.art.sounds[path].get_length()>0)
		for cinema in [false,true]:
			game.new_battle()
			game.cinematic_enabled = cinema
			game.hand = [id]
			game.selected = 0
			game.energy = 8
			await game.play_card(0)
			assert(game.friendly[0].id==id and not game.friendly[0].ready)
			game.friendly[0].ready = true
			game.enemy = [Cards.unit(1),{},{},{}]
			game.enemy[0].hp = 100
			await game.attack(0,0)
			assert(game.enemy[0].hp<100)
			if id==146: assert(game.enemy[0].get("chilled",false))
		var prism := Cards.leveled_id(id,10)
		assert(Cards.DATA[prism].actor==data.actor and Cards.DATA[prism].level==10)
	assert(game.art.effect_textures["MMM_SHOT_Schabbs"].size()==4)
	assert(game.art.side_effect_textures["MMM_SHOT_Schabbs"].size()==4)
	for level in [1,10]:
		for counter in [false,true]:
			for side in [0,1]:
				game.new_battle()
				var id := Cards.leveled_id(mech,level)
				var row: Array = game.friendly if side==0 else game.enemy
				row[0] = Cards.unit(id)
				var predicted := row.duplicate(true)
				AI.damage(predicted,0,999,counter)
				game.hit(side,0,999,"ROCKET",counter)
				assert(row[0].hp==ceili(Cards.DATA[id].hp/2.0) and row[0].suit_broken)
				assert(predicted[0]==row[0],"AI and actual suit break must agree")
				assert(Cards.armor(row[0])==0 and Cards.art_key(id,row[0])=="MMM_UnarmoredHitler")
				Squads.reinforce(row[0],id)
				assert(row[0].suit_broken and Cards.armor(row[0])==0,"Reinforcement never restores suit")
				game.hit(side,0,999,"BULLET",counter)
				assert(row[0].is_empty(),"Unarmored form can die normally")
	var shielded := Cards.unit(mech)
	shielded.shield = true
	var shield_row: Array = [shielded,{},{},{}]
	AI.damage(shield_row,0,999)
	assert(not shielded.get("suit_broken",false) and shielded.hp==Cards.DATA[mech].hp)
	if "--visual-test" in OS.get_cmdline_user_args():
		Engine.time_scale = 1
		game.new_battle()
		game.friendly = [Cards.unit(145),Cards.unit(145),Cards.unit(146),Cards.unit(147)]
		Cards.receive_damage(game.friendly[1],999)
		game.hand = [145,146,147]
		game.particles.clear()
		game.numbers.clear()
		await create_timer(0.3).timeout
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/wolf-bosses-board.png")
	print("PASS: 3 Wolf cards, 4 animation banks, sounds, needle, deployment/attacks, Prism levels, old saves, suit overflow protection/one-use/AI parity on both sides")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	game.queue_free()
	await process_frame
	quit()
