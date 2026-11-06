extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	var m = Meld.new()
	m.cheat_hints = true
	m.side = 0
	m.round_number = 5
	m.turns = [9,9]
	var checked := 0
	for table in [[0,0],[1,3,15],[19,21,8],[0,2,5],[1,8,14,16,7],[0,7,18],[21,19],[15,2]]:
		var combo = Meld.pattern(table)
		combo.ids = table
		m.melds = [combo]
		for other in m.POOL:
			m.hands[0] = [other,Meld.JOKER]
			var moves = m.best_move(0)
			for indices in [[1],[0,1]]:
				var legal = m.evaluate(0,indices)
				if legal.is_empty(): continue
				assert(moves.legal.has(1))
				assert(moves.hints[1].any(func(option): return option.indices==indices))
				assert(moves.hints[1].any(func(option): return "JOHN ROMERO AS " in option.names))
				checked += 1
	assert(checked>0)
	print("PASS Romero two-card final-round extensions: ",checked)
	quit()
