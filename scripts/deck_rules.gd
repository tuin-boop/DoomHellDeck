extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const SIZE := 20
const BUDGET := 120
const PREMIUM_LIMIT := 6
const MYTHIC_LIMIT := 2

static func points(id: int) -> int:
	var card: Dictionary = Cards.DATA[id]
	return 2 + int(card.cost) + [0,3,5,6,6,9][card.rarity]

static func copies(id: int) -> int:
	return 3 if Cards.DATA[id].rarity == 0 else (2 if Cards.DATA[id].rarity == 1 else 1)

static func cost(cards: Array) -> int:
	var total := 0
	for id in cards:
		total += points(id)
	return total

static func issue(cards: Array, owned: Array = [], complete := true, check_budget := true) -> String:
	if cards.size()>SIZE:
		return "Maximum 20 cards."
	var counts := {}
	var premium := 0
	var mythic := 0
	for value in cards:
		if not (value is int or value is float) or value != int(value) or value<0 or value>=Cards.CATALOG_SIZE:
			return "Only collection cards can be included."
		var id := int(value)
		counts[id] = counts.get(id,0)+1
		if counts[id]>copies(id):
			return "%s: maximum %d copies." % [Cards.DATA[id].name,copies(id)]
		if not owned.is_empty() and (id>=owned.size() or counts[id]>owned[id]):
			return "You do not own enough copies."
		premium += int(Cards.DATA[id].rarity>=2)
		mythic += int(Cards.DATA[id].rarity==5)
	if check_budget and cost(cards)>BUDGET:
		return "Over budget: %d / %d points." % [cost(cards),BUDGET]
	if premium>PREMIUM_LIMIT:
		return "Maximum 6 Epic / Legendary / Elite / Mythic cards combined."
	if mythic>MYTHIC_LIMIT:
		return "Maximum 2 Mythic cards."
	if complete and cards.size()!=SIZE:
		return "Add %d more cards." % (SIZE-cards.size())
	return ""

static func cheapest_fill(cards: Array, owned: Array = [], enforce_budget := true, units_only := false) -> Array:
	var result := cards.duplicate()
	var pool: Array = range(Cards.CATALOG_SIZE).filter(func(id): return not units_only or Cards.DATA[id].hp>0)
	pool.sort_custom(func(a,b): return points(a)<points(b) or (points(a)==points(b) and a<b))
	for id in pool:
		while result.size()<SIZE and issue(result+[id],owned,false,enforce_budget).is_empty():
			result.append(id)
	return result

static func completion_message(cards: Array, owned: Array = []) -> String:
	var problem := issue(cards,owned,false)
	if not problem.is_empty(): return problem
	if cards.size()==SIZE: return "READY: 20 cards within budget"
	var full := cheapest_fill(cards,owned,false)
	if full.size()<SIZE: return "Not enough eligible owned cards to fill this deck."
	var extra := cost(full)-BUDGET
	if extra>0: return "DRAFT: free at least %d points to reach 20 cards." % extra
	return "%d slots left / cheapest finish needs %d points" % [SIZE-cards.size(),cost(full)-cost(cards)]

static func legalize(cards: Array) -> Array:
	# Generated decks may replace expensive choices; player drafts are never passed here.
	var result: Array = []
	for id in cards:
		if issue(result+[id],[],false).is_empty(): result.append(id)
	while true:
		var full := cheapest_fill(result,[],true,true)
		if full.size()==SIZE: return full
		assert(not result.is_empty())
		# Retain CPU core squad when possible, removing expensive support first.
		var index := 3 if result.size()>3 else 0
		for i in range(index,result.size()):
			if points(result[i])>points(result[index]): index = i
		result.remove_at(index)
	return []
