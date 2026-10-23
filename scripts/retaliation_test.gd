extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
var game

func _initialize() -> void:
	if not "--balance-test" in OS.get_cmdline_user_args():
		quit(1)
		return
	run.call_deferred()

func setup(attacker: int, defender: int, side := 0) -> void:
	game.new_battle()
	game.friendly = [Cards.unit(attacker if side==0 else defender),{},{},{}]
	game.enemy = [Cards.unit(defender if side==0 else attacker),{},{},{}]

func run() -> void:
	Engine.time_scale = 80
	game = Game.new()
	root.add_child(game)
	AudioServer.set_bus_mute(0,true)
	for cinematic in [false,true]:
		game.cinematic_enabled = cinematic
		for side in 2:
			setup(0,2,side)
			var attackers: Array = game.friendly if side==0 else game.enemy
			var defenders: Array = game.enemy if side==0 else game.friendly
			defenders[0].hp = 1
			await game.attack(side,0)
			assert(defenders[0].is_empty() and attackers[0].hp==1,"Lethal hit still returns ceil(3/2)=2")
		setup(0,2)
		game.friendly[0].hp = 2
		game.enemy[0].hp = 1
		await game.attack(0,0)
		assert(game.friendly[0].is_empty() and game.enemy[0].is_empty(),"Mutual destruction")
		setup(0,2)
		game.friendly[0].shield = true
		await game.attack(0,0)
		assert(game.friendly[0].hp==2 and not game.friendly[0].shield,"Attacker shield absorbs one retaliation damage")
		setup(22,2)
		await game.attack(0,0)
		assert(game.friendly[0].hp==5,"Retaliation ignores attacker armor")
		setup(3,5)
		await game.attack(0,0)
		assert(game.enemy[0].hp==4 and game.friendly[0].hp==3,"Shielded defender still returns ceil(2/2)=1")
		setup(15,1)
		game.friendly[0].hp = 1
		game.enemy[0].hp = 99
		await game.attack(0,0)
		assert(game.friendly[0].is_empty() and game.enemy[0].hp==97,"Counter kill stops later strikes")
		setup(17,2)
		game.enemy[2] = game.enemy[0]
		game.enemy[0] = {}
		await game.attack(0,0)
		assert(game.friendly[0].hp==2,"Homing target retaliates across lanes")
		setup(8,1)
		game.enemy[1] = Cards.unit(8)
		await game.attack(0,0)
		assert(game.friendly[0].hp==7,"Splash neighbor does not retaliate")
		setup(0,2)
		game.enemy = [{},{},{},{}]
		await game.attack(0,0)
		assert(game.friendly[0].hp==3 and game.enemy_hp==28,"Direct Health damage has no retaliation")
		setup(0,2)
		game.hand = [9]
		game.selected = 0
		game.energy = 8
		await game.play_card(0)
		assert(game.friendly[0].hp==3,"BFG event has no retaliation")
	# AI's three-phase estimate agrees with actual combat, including counter kills.
	game.cinematic_enabled = false
	for pair in [[0,2],[15,1],[8,22],[17,5]]:
		setup(pair[0],pair[1])
		var predicted: float = game.EnemyAI.evaluate(game.friendly,game.enemy,30,30)
		for side in [0,1,0]:
			await game.attack(side,0)
		var actual: float = (game.player_hp-30)*2.0+(30-game.enemy_hp)*2.0
		for side in 2:
			var row: Array = game.friendly if side==0 else game.enemy
			for unit in row:
				if not unit.is_empty():
					var data: Dictionary = Cards.DATA[unit.id]
					actual += (1.0 if side==0 else -1.0)*(unit.hp*0.65+data.atk*data.get("strikes",1)*1.7+2.0+(2.0 if unit.shield else 0.0))
		assert(is_equal_approx(actual,predicted),"AI must predict retaliation and stop dead attackers")
	print("PASS: retaliation on both sides and both visual modes, rounding, lethal trade, shields, armor, multi-strike interruption, homing, no splash/event/Health counters, AI parity")
	for voice in game.audio.voices:
		voice.stop()
		voice.stream = null
	OS.delay_msec(200)
	await process_frame
	quit()
