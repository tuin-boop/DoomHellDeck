extends SceneTree
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
func _initialize() -> void:
	var row: Array = [Cards.unit(1),{},{},{}]
	var hand: Array = [3,15]
	var price: int = Cards.DATA[3].cost+Cards.DATA[15].cost
	assert(Squads.playable_marks(row,hand,{0:true,1:true},price,0).size()==2,"One on table plus two marked cards")
	assert(Squads.playable_marks(row,hand,{0:true,1:true},price-1,0).is_empty(),"Combined Energy required")
	assert(Squads.playable_marks(row,hand,{1:true},price,0)=={1:true},"Only right-clicked copies wiggle")
	assert(Squads.playable_marks([Cards.unit(1),Cards.unit(2),Cards.unit(5),{}],hand,{0:true,1:true},20,20).is_empty(),"Need two free lanes")
	assert(Squads.playable_marks([Cards.unit(1),Cards.unit(3),{},{}],[15],{0:true},20,20).size()==1,"Last squad piece")
	assert(Squads.playable_marks([{},{},{},{}],[0,18],{0:true,1:true},20,20).size()==2,"Whole squad from hand")
	assert(Squads.playable_marks(row,[3,3],{0:true,1:true},20,20).is_empty(),"Wrong species cannot complete squad")
	var mythic := -1
	for id in Cards.CATALOG_SIZE:
		if Cards.base_id(id)==15 and Cards.DATA[id].get("soul_cost",0)>0: mythic = id
	assert(mythic>=0)
	assert(Squads.playable_marks([Cards.unit(1),Cards.unit(3),{},{}],[mythic],{0:true},30,0).is_empty(),"Soul cost required")
	assert(Squads.playable_marks([Cards.unit(1),Cards.unit(3),{},{}],[mythic],{0:true},30,20).size()==1,"Mythic variant eligible with Souls")
	print("PASS: saved squad availability, partial board, combined Energy/Souls, free lanes, species, marked copies")
	quit()
