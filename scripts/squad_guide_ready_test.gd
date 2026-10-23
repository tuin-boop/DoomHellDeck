extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
func _initialize() -> void:
	var game = Game.new()
	var combo: Dictionary = Squads.COMBOS[1]
	assert(combo.name=="DEAD PATROL")
	game.energy = 20
	game.hand = [1,3,15]
	assert(game.squad_guide_state(combo)=="PLAYABLE NOW")
	assert(Squads.active(game.friendly).is_empty(),"Hand readiness cannot grant combat bonuses")
	game.hand = [3,15]
	game.friendly = [Cards.unit(1),{},{},{}]
	assert(game.squad_guide_state(combo)=="PLAYABLE NOW","Hand and board pieces combine")
	game.hand = [1,1,15]
	assert(game.squad_guide_state(combo)=="INCOMPLETE","Duplicates cannot substitute for a missing member")
	game.friendly = [Cards.unit(1),Cards.unit(3),Cards.unit(15),{}]
	assert(game.squad_guide_state(combo)=="ACTIVE")
	game.table.free()
	game.audio.free()
	game.free()
	print("PASS: held, mixed, missing and deployed squad guide states; combat unchanged")
	quit()
