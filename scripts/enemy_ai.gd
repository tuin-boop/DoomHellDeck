extends RefCounted
## Bounded search over affordable combinations using only deployed cards and CPU hand.
const Cards = preload("res://scripts/cards.gd")
const DeckRules = preload("res://scripts/deck_rules.gd")
const Squads = preload("res://scripts/squads.gd")
const DECK := [0,0,0,1,1,2,2,3,3,4,5,5,14,14,15,16,17,18,19,8]

const THEMES := [
	["ScientistFreeze","FrozenImp","Cryocubus"],
	["CyberKnight","TechGunman","CyberMancubus"],
	["AkimboZombie","AkimboCommando","QuadSergeant"],
	["VoidPinky","DarkCaco","GhostRevenant"],
	["Metalfoot","Minigunner","Demolitron"]
]

static func deck_for(encounter: int, seed_value: int = -1, include_weapons := true) -> Array:
	var random := RandomNumberGenerator.new()
	if seed_value<0: random.randomize()
	else: random.seed = seed_value
	var theme: Array = THEMES[random.randi_range(0,THEMES.size()-1)]
	# Keep a complete squad, a cheap opening, and a varied Energy curve.
	var result: Array = []
	for actor in theme: result.append(Cards.by_actor(actor))
	var support: Array = [0,0,1,1,2,3,4,14,15,16,5,17,18,19,8,23,3]
	for slot in support.size():
		var original: int = support[slot]
		var chosen := original
		if slot in [2,4,5,8,11,14] and random.randf()<0.75:
			var pool: Array = []
			for id in range(Cards.LEGACY_SIZE,Cards.CATALOG_SIZE):
				var data: Dictionary = Cards.DATA[id]
				if Cards.base_id(id)==Cards.base_id(original) and absi(data.cost-Cards.DATA[original].cost)<=1 and data.cost<=6+mini(encounter,1):
					pool.append(id)
			if not pool.is_empty(): chosen = pool[random.randi_range(0,pool.size()-1)]
		# Reject upgrades that would consume the budget needed for remaining slots.
		var reserved := (DeckRules.SIZE-result.size()-1)*3
		if not DeckRules.issue(result+[chosen],[],false).is_empty() or DeckRules.cost(result)+DeckRules.points(chosen)+reserved>DeckRules.BUDGET:
			chosen = original
		if DeckRules.issue(result+[chosen],[],false).is_empty(): result.append(chosen)
	result = DeckRules.legalize(result)
	if random.randf()<0.35:
		result = add_support_combo(result,random)
	if include_weapons and random.randf()<0.4:
		for attempt in 2:
			var weapon_ids := [149,150,151,152,153,154]
			var id: int = weapon_ids[random.randi_range(0,weapon_ids.size()-1)]
			var slot := random.randi_range(3,result.size()-1)
			var candidate := result.duplicate()
			candidate[slot] = id
			if DeckRules.issue(candidate).is_empty(): result = candidate
	return result

static func add_support_combo(cards: Array, random: RandomNumberGenerator) -> Array:
	var complete := Squads.active(cards.map(func(id): return Cards.unit(id))).size()
	var options: Array = []
	for combo in Squads.COMBOS:
		var missing: Array = []
		for group in combo.groups:
			if not cards.any(func(id): return Squads.matches(id,group)): missing.append(group)
		if missing.size()!=1: continue
		for id in missing[0]:
			# Preserve the three core theme cards; replace only supporting units.
			for slot in range(3,cards.size()):
				var candidate := cards.duplicate()
				candidate[slot] = id
				if not DeckRules.issue(candidate).is_empty(): continue
				var count := Squads.active(candidate.map(func(card): return Cards.unit(card))).size()
				if count>complete: options.append(candidate)
	return cards if options.is_empty() else options[random.randi_range(0,options.size()-1)]

static func plan(board: Array, opponent: Array, hand: Array, energy: int, health: int, opponent_health: int, souls := 0) -> Array:
	var initial := {"board":board.duplicate(true),"hand":hand.duplicate(),"energy":energy,"souls":souls,"moves":[]}
	var beam: Array = [initial]
	var best: Array = []
	var best_score := evaluate(board,opponent,health,opponent_health)+Squads.potential(board,hand)
	for depth in 4:
		var candidates: Array = []
		for state in beam:
			var seen := {}
			for id in state.hand:
				if Cards.DATA[id].hp<=0 or seen.has(id) or Cards.DATA[id].cost > state.energy or Cards.DATA[id].get("soul_cost",0) > state.souls:
					continue
				seen[id] = true
				for lane in 4:
					if not state.board[lane].is_empty() and not Squads.can_reinforce(state.board[lane],id):
						continue
					var child: Dictionary = state.duplicate(true)
					child.hand.erase(id)
					child.energy -= Cards.DATA[id].cost
					child.souls -= Cards.DATA[id].get("soul_cost",0)
					if child.board[lane].is_empty():
						child.board[lane] = Cards.unit(id,true)
					else:
						Squads.reinforce(child.board[lane],id)
					child.moves.append({"id":id,"lane":lane})
					child.score = evaluate(child.board,opponent,health,opponent_health)-0.15*(energy-child.energy)+Squads.potential(child.board,child.hand)
					candidates.append(child)
					if child.score > best_score:
						best_score = child.score
						best = child.moves
		if candidates.is_empty():
			break
		candidates.sort_custom(func(a,b): return a.score > b.score)
		beam = candidates.slice(0,16)
	return best

static func evaluate(board: Array, opponent: Array, health: int, opponent_health: int) -> float:
	var rows: Array = [board.duplicate(true),opponent.duplicate(true)]
	for unit in rows[1]:
		if not unit.is_empty() and unit.get("waited",false):
			unit.ready = true
	var hp := [health,opponent_health]
	# CPU attacks now, player attacks next, then surviving CPU units get their turn.
	Squads.lock_combat(rows[0])
	Squads.lock_combat(rows[1])
	for side in [0,1,0]:
		if side==1:
			# The preceding CPU phase ends that turn; the next player phase starts fresh.
			for row in rows:
				Squads.clear_combat(row)
				Squads.lock_combat(row)
		for lane in 4:
			if rows[side][lane].is_empty():
				continue
			var unit: Dictionary = rows[side][lane]
			if not unit.get("ready",true):
				unit.ready = true
				continue
			var id: int = unit.id
			var data: Dictionary = Cards.DATA[id]
			for shot in int(data.get("strikes",1)):
				if rows[side][lane].is_empty() or not rows[side][lane].get("ready",true): break
				var counter_damage := 0
				var target := lane
				if data.get("seeking",false) and rows[1-side][target].is_empty():
					var distance := 5
					for i in 4:
						if not rows[1-side][i].is_empty() and absi(i-lane)<distance:
							distance = absi(i-lane)
							target = i
				if rows[1-side][target].is_empty():
					hp[1-side] -= Squads.attack_value(rows[side],lane)
					hp[side] = mini(maxi(30,health if side==0 else opponent_health),hp[side]+int(data.get("lifesteal",0)))
				else:
					counter_damage = Squads.retaliation(rows[1-side],target)
					var landed: bool = not rows[1-side][target].shield
					damage(rows[1-side],target,Squads.damage(rows[side],lane,rows[1-side][target].id))
					if landed:
						hp[side] = mini(maxi(30,health if side==0 else opponent_health),hp[side]+int(data.get("lifesteal",0)))
						if data.get("chill",false) and not rows[1-side][target].is_empty():
							rows[1-side][target].chilled = true
				var splash: int = data.get("splash",2 if Cards.base_id(id)==8 else (1 if Cards.base_id(id)==3 else 0))
				if splash > 0:
					for adjacent in [target-1,target+1]:
						if adjacent>=0 and adjacent<4:
							damage(rows[1-side],adjacent,splash)
				if counter_damage>0:
					damage(rows[side],lane,counter_damage,true)
				if hp[0]<=0 or hp[1]<=0:
					return 10000.0 if hp[1]<=0 else -10000.0
			unit.erase("chilled")
	var value: float = (hp[0]-health)*2.0+(opponent_health-hp[1])*2.0
	for side in 2:
		for unit in rows[side]:
			if not unit.is_empty():
				var data: Dictionary = Cards.DATA[unit.id]
				value += (1.0 if side==0 else -1.0)*(unit.hp*0.65+data.atk*data.get("strikes",1)*1.7+2.0+(2.0 if unit.shield else 0.0))
	return value

static func damage(row: Array, lane: int, amount: int, counter := false) -> void:
	if row[lane].is_empty():
		return
	if row[lane].shield:
		row[lane].shield = false
		if not counter or amount<=1: return
		amount -= 1
	Cards.receive_damage(row[lane],amount,counter)
	if row[lane].hp<=0:
		var data: Dictionary = Cards.DATA[row[lane].id]
		row[lane] = Cards.unit(data.death_spawn,true) if data.has("death_spawn") else {}
		if not row[lane].is_empty():
			row[lane].combat_attack = 0
			row[lane].combat_breach = 0
