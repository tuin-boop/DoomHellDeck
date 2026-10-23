extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const STYLES := ["Shield spam","Armour and suit","Shield splash","Multi-strike rush","Weapon burst"]

static func priority(id: int, style: String) -> float:
	var d: Dictionary = Cards.DATA[id]
	var shield: bool = d.get("starting_shield",false) or Cards.base_id(id)==5
	var theme := 0.0
	match style:
		"Shield spam": theme = 15.0 if shield else 0.0
		"Armour and suit": theme = 15.0 if d.get("armor",0)>0 or d.get("breakable_suit",false) else 0.0
		"Shield splash": theme = (10.0 if shield else 0.0)+(12.0 if d.get("splash",0)>0 else 0.0)
		"Multi-strike rush": theme = (15.0 if d.get("strikes",1)>1 else 0.0)+(8.0 if d.get("ambush",false) else 0.0)
		"Weapon burst": theme = 18.0 if d.get("targeted",false) or id==9 else 0.0
	return theme+(d.atk*d.get("strikes",1)+d.hp*0.6)/maxf(1,d.cost)-Rules.points(id)*0.18

static func build(style: String, variant: int) -> Array:
	var deck: Array = []
	var pool: Array = range(Cards.CATALOG_SIZE)
	pool.sort_custom(func(a,b): return priority(a,style)>priority(b,style))
	# Two cost-conscious versions: strongest theme first versus more early pressure.
	if variant==1: deck = [0,0,1,1,3,3]
	for id in pool:
		while deck.size()<20 and Rules.issue(deck+[id],[],false).is_empty():
			if Rules.cheapest_fill(deck+[id],[],true,true).size()!=20: break
			deck.append(id)
	deck = Rules.cheapest_fill(deck,[],true,true)
	assert(Rules.issue(deck).is_empty())
	return deck
