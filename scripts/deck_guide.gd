extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const Squads = preload("res://scripts/squads.gd")

static func seed_squads(selected: Array, owned: Array) -> Array:
	var deck: Array = []
	for index in selected:
		var used: Array = []
		for group in Squads.COMBOS[index].groups:
			var found := false
			for slot in deck.size():
				if slot not in used and Squads.matches(deck[slot],group):
					used.append(slot)
					found = true
					break
			if found: continue
			var pool: Array = range(Cards.CATALOG_SIZE).filter(func(id): return Squads.matches(id,group) and Rules.issue(deck+[id],owned,false).is_empty())
			pool.sort_custom(func(a,b): return Rules.points(a)<Rules.points(b) or (Rules.points(a)==Rules.points(b) and a<b))
			if not pool.is_empty():
				used.append(deck.size())
				deck.append(pool[0])
	return deck

static func missing_piece(id: int, deck: Array, selected: Array) -> bool:
	for index in selected:
		for group in Squads.COMBOS[index].groups:
			if Squads.matches(id,group) and not deck.any(func(other): return Squads.matches(other,group)):
				return true
	return false

static func reason(id: int, deck: Array, selected: Array) -> String:
	if missing_piece(id,deck,selected): return "Fills a missing squad role"
	var data: Dictionary = Cards.DATA[id]
	if data.hp==0: return "Support / one of your tools"
	if data.cost<=2: return "Cheap blocker / early pressure"
	if data.cost>=5: return "Late-game threat"
	return "Mid-cost fighter"

static func score(id: int, deck: Array, selected: Array) -> float:
	var data: Dictionary = Cards.DATA[id]
	var cheap := deck.filter(func(other): return Cards.DATA[other].hp>0 and Cards.DATA[other].cost<=2).size()
	var heavies := deck.filter(func(other): return Cards.DATA[other].cost>=5).size()
	var middle := deck.filter(func(other): return Cards.DATA[other].hp>0 and Cards.DATA[other].cost in [3,4]).size()
	var support := deck.filter(func(other): return Cards.DATA[other].hp==0).size()
	var value := 10.0-float(Rules.points(id))*0.5-float(deck.count(id))*2.0
	if missing_piece(id,deck,selected): value += 50
	if data.hp>0 and data.cost<=2 and cheap<8: value += 20
	if data.hp>0 and data.cost in [3,4] and middle<6: value += 15
	if data.cost>=5 and heavies<2 and deck.size()>=10: value += 15
	if data.hp==0 and support<1 and deck.size()>=12: value += 23
	if deck.count(id)<2 and selected.any(func(index): return Squads.COMBOS[index].groups.any(func(group): return Squads.matches(id,group))): value += 5
	if data.cost>=5 and heavies>=3: value -= 20
	if data.hp==0: value -= 8
	if data.get("soul_cost",0)>0: value -= 4
	return value

static func suggestions(deck: Array, selected: Array, owned: Array, rarity := -1) -> Array:
	var pool: Array = range(Cards.CATALOG_SIZE).filter(func(id): return (rarity<0 or Cards.DATA[id].rarity==rarity) and Rules.issue(deck+[id],owned,false).is_empty())
	var scores := {}
	for id in pool: scores[id] = score(id,deck,selected)
	pool.sort_custom(func(a,b):
		var left: float = scores[a]
		var right: float = scores[b]
		return left>right or (is_equal_approx(left,right) and a<b))
	return pool

static func fill(deck: Array, selected: Array, owned: Array) -> Array:
	var result := deck.duplicate()
	while result.size()<Rules.SIZE:
		var pool := suggestions(result,selected,owned)
		var choice := -1
		for id in pool:
			if Rules.cheapest_fill(result+[id],owned).size()==Rules.SIZE:
				choice = id
				break
		if choice<0: return Rules.cheapest_fill(result,owned)
		result.append(choice)
	return result

static func complete(deck: Array, index: int) -> bool:
	return not Squads.members(deck.map(func(id): return Cards.unit(id)),Squads.COMBOS[index]).is_empty()

# Suggest cuts without touching the player's draft; prefer keeping completed squads.
static func repair(deck: Array, selected: Array, owned: Array) -> Dictionary:
	var kept := deck.duplicate()
	var cuts: Array = []
	while Rules.cheapest_fill(kept,owned).size()<Rules.SIZE or not Rules.issue(kept,owned,false).is_empty():
		if kept.is_empty(): break
		var best_slot := -1
		var best_score := -1e9
		for slot in kept.size():
			var candidate := kept.duplicate()
			candidate.remove_at(slot)
			var score_value: float = Rules.points(kept[slot])*10
			for index in Squads.COMBOS.size():
				if complete(kept,index) and not complete(candidate,index): score_value -= 200 if index in selected else 100
			if Cards.DATA[kept[slot]].cost<=2: score_value -= 15
			if score_value>best_score:
				best_score = score_value
				best_slot = slot
		cuts.append(kept[best_slot])
		kept.remove_at(best_slot)
	var full := fill(kept,selected,owned)
	return {"cuts":cuts,"kept":kept,"possible":Rules.issue(full,owned).is_empty(),"full":full}
