extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	assert(Meld.pattern([0,0,0,2,2]).name=="FULL HOUSE")
	assert(Meld.pattern([0,0,2,2,5,5]).name=="DOUBLE MARCH")
	assert(Meld.pattern([1,3,0,7]).name=="CROSSFIRE")
	assert(Meld.pattern([1,3,0,0]).is_empty())
	assert(Meld.pattern([1,2,5,7]).name=="HELL'S LADDER")
	assert(Meld.pattern([1,2,5,7]).points==55)
	assert(Meld.pattern([1,3,15]).name=="FIRING SQUAD")
	assert(Meld.pattern([7,17,4]).name=="RESURRECTION CREW")
	assert(Meld.pattern([0,2,14]).name=="DEMON PACK")
	assert(Meld.pattern([0,0,2,2,5,5],"pairs").name=="TRIPLE THREAT")
	var m = Meld.new()
	m.hands = [[0],[1,2]]
	assert(m.evaluate(0,[0]).is_empty())
	assert(m.evaluate(1,[0]).is_empty())
	m.melds = [{"kind":"set","ids":[0],"points":5,"starter":1}]
	assert(m.evaluate(0,[0]).points==10)
	m.melds = [{"kind":"run","ids":[1,2,5],"points":20,"starter":1}]
	m.hands[0] = [7]
	assert(m.evaluate(0,[0]).name=="HELL'S LADDER")
	m.melds = []
	m.hands[0] = [0,0,2,2,5,5]
	assert(m.best_move(0).indices.size()==6)
	print("PASS: new combos, named teams, overlap families, single-card opening rejection, extension and CPU six-card search")
	quit()
