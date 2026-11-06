extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	for entry in [[[0,0,18],20],[[0,0,18,18],40],[[0,0,0,18,18],60],[[0,0,0,18,18,18],80]]:
		var combo = Meld.plain_pattern(entry[0],"type")
		assert(combo.points==entry[1] and combo.name.contains("FLUSH"))
	assert(Meld.plain_pattern([0,0,2],"type").is_empty())
	assert(Meld.plain_pattern([0,0],"type").is_empty())
	assert(Meld.plain_pattern([0,0,0]).kind=="set")
	assert(Meld.plain_pattern([0,0,0,0]).points==60)
	var house = Meld.plain_pattern([0,0,0,2,2])
	assert(house.name=="FULL HOUSE" and house.points==45)
	assert(Meld.plain_pattern([0,0,0,18,18]).points==60)
	assert(Meld.plain_pattern([0,0,0,18,18],"pairs").name=="FULL HOUSE")
	assert(Meld.plain_pattern([0,0,2,2]).points==25)
	assert(Meld.plain_pattern([0,0,0,2,2,2]).points==65)
	assert(Meld.pattern([0,18,-1],"type").points==20)
	print("PASS: duplicate flush tiers, exclusions, higher-scoring overlaps, Full House and wildcard")
	quit()
