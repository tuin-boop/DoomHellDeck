extends RefCounted
## Identical per-side draw rules. Only selects cards that exist in that side's pile.
const Cards = preload("res://scripts/cards.gd")
const WINDOW := 5
const POWER_LIMIT := 2
var history: Array[int] = []
var random := RandomNumberGenerator.new()
var level_history: Array[int] = []
var prism_drawn := false

func reset(draw_seed: int) -> void:
	history.clear()
	level_history.clear()
	prism_drawn = false
	random.seed = draw_seed

static func powerful(id: int) -> bool:
	var data: Dictionary = Cards.DATA[id]
	return data.rarity >= 2 or data.cost >= 4 or data.atk*int(data.get("strikes",1)) >= 4 or data.hp >= 8

func take(pile: Array, hand: Array, opening := false, round_number := 1, health_gap := 0) -> int:
	if pile.is_empty():
		return -1
	# A recycled copy gets a fresh round-based roll, never compounded upgrades.
	for i in pile.size():
		pile[i] = Cards.DATA[pile[i]].source_id
	var candidates: Array = []
	for i in pile.size():
		candidates.append(i)
	# Give either side a usable opening when its deck contains a cheap unit.
	if opening and not hand.any(func(id): return Cards.DATA[id].hp>0 and Cards.DATA[id].cost<=3 and Cards.DATA[id].get("soul_cost",0)==0):
		var cheap := candidates.filter(func(i): return Cards.DATA[pile[i]].hp>0 and Cards.DATA[pile[i]].cost<=3 and Cards.DATA[pile[i]].get("soul_cost",0)==0)
		if not cheap.is_empty():
			candidates = cheap
	var recent := history.slice(maxi(0,history.size()-(WINDOW-1)))
	var power_count := recent.filter(func(id): return powerful(id)).size()
	var hand_power := hand.filter(func(id): return powerful(id)).size()
	if power_count >= POWER_LIMIT or hand_power >= 2:
		var ordinary := candidates.filter(func(i): return not powerful(pile[i]))
		if not ordinary.is_empty():
			candidates = ordinary
	if not history.is_empty() and Cards.DATA[history.back()].rarity==5:
		var non_mythic := candidates.filter(func(i): return Cards.DATA[pile[i]].rarity!=5)
		if not non_mythic.is_empty():
			candidates = non_mythic
	var weights: Array[float] = []
	var total := 0.0
	for index in candidates:
		var id: int = pile[index]
		var weight := 1.0
		# Soft cooldown after a strong draw, and gentle drought relief after four ordinary draws.
		if powerful(id):
			weight = 2.0 if recent.size()==4 and power_count==0 else (0.45 if power_count>0 else 1.0)
		if not history.is_empty() and history.back()==id:
			weight *= 0.4
		weights.append(weight)
		total += weight
	var roll := random.randf()*total
	var chosen: int = candidates.back()
	for i in candidates.size():
		roll -= weights[i]
		if roll <= 0:
			chosen = candidates[i]
			break
	var drawn: int = pile[chosen]
	pile.remove_at(chosen)
	drawn = Cards.leveled_id(drawn,roll_level(round_number,health_gap)) if Cards.DATA[drawn].hp>0 else drawn
	history.append(drawn)
	if history.size()>WINDOW:
		history.pop_front()
	return drawn

func roll_level(round_number: int, health_gap: int) -> int:
	var level := 1
	if round_number > 1:
		if round_number < 5:
			level = 2 if random.randf()<0.25 else 1
		elif round_number < 9:
			level = random.randi_range(2,5)
		elif round_number < 15:
			level = random.randi_range(3,7)
		else:
			level = random.randi_range(5,9)
		# Small comeback nudge, not a guaranteed answer or a hidden stat change.
		if round_number>=5 and health_gap>=8 and random.randf()<0.25:
			level = mini(9,level+1)
		var top_count := level_history.filter(func(n): return n>=8).size()
		if top_count>=2:
			level = mini(7,level)
		# 0.3% per eligible unit draw, once per side per match, no comeback multiplier.
		if round_number>=12 and not prism_drawn and top_count<2 and random.randf()<0.003:
			level = 10
			prism_drawn = true
	level_history.append(level)
	if level_history.size()>4:
		level_history.pop_front()
	return level
