extends RefCounted
## Live board bonuses: distinct lanes, any order, variants and levels retain species.
const Cards = preload("res://scripts/cards.gd")
const BASE_COMBOS := [
	{"name":"SIEGE CREW","groups":[[6,16],[15],[18]],"bonus":"breach","rule":"Bruiser + Chaingunner + Mancubus"},
	{"name":"DEAD PATROL","groups":[[1],[3],[15]],"bonus":"attack","rule":"Zombieman + Shotgun Guy + Chaingunner"},
	{"name":"HELLFIRE BATTERY","groups":[[0],[18]],"bonus":"breach","rule":"Imp + Mancubus"},
	{"name":"NIGHT HUNT","groups":[[2],[14]],"bonus":"breach","rule":"Pinky + Spectre"},
	{"name":"SKY SWARM","groups":[[4],[5],[20]],"bonus":"attack","rule":"Lost Soul + Cacodemon + Pain Elemental"},
	{"name":"BLOOD BROTHERS","groups":[[6],[16]],"bonus":"breach","rule":"Baron of Hell + Hell Knight"},
	{"name":"ROCKET CHOIR","groups":[[8],[17]],"bonus":"breach","rule":"Cyberdemon + Revenant"},
	{"name":"PLASMA WEB","groups":[[5],[19]],"bonus":"breach","rule":"Cacodemon + Arachnotron"},
	{"name":"IRON LEGION","groups":[[15],[19],[21]],"bonus":"attack","rule":"Chaingunner + Arachnotron + Spider Mastermind"},
	{"name":"SOUL COVEN","groups":[[7],[13],[20]],"bonus":"attack","rule":"Arch-vile + Romero + Pain Elemental"},
	{"name":"UAC STRIKE TEAM","groups":[[12],[22],[3,23]],"bonus":"attack","rule":"Carmack + Doomguy + Shotgun Guy or SS"},
	{"name":"HELL GATE GUARD","groups":[[24],[0],[6,16]],"bonus":"attack","rule":"Icon of Sin + Imp + Bruiser"}
]
static var COMBOS: Array = build_combos()

static func build_combos() -> Array:
	var result: Array = BASE_COMBOS.duplicate(true)
	var recipes := [
		["CRYOGENIC CELL",["ScientistFreeze","FrozenImp","Cryocubus"],"attack"],
		["CYBER SIEGE",["CyberKnight","TechGunman","CyberMancubus"],"breach"],
		["AKIMBO PATROL",["AkimboZombie","AkimboCommando","QuadSergeant"],"attack"],
		["VOID CHOIR",["VoidPinky","DarkCaco","GhostRevenant"],"breach"],
		["HEAVY METAL",["Metalfoot","Minigunner","Demolitron"],"attack"],
		["CARDINAL COURT",["LesserCardinal","CardinalDemon","HierophantDemon"],"attack"]
	]
	for recipe in recipes:
		var groups: Array = []
		var names: Array[String] = []
		for actor in recipe[1]:
			var id := Cards.by_actor(actor)
			assert(id>=0)
			groups.append([id])
			names.append(Cards.DATA[id].name.capitalize())
		result.append({"name":recipe[0],"groups":groups,"bonus":recipe[2],"rule":" + ".join(names)})
	result.append({"name":"BUNNY GUARD","groups":[[22],[Cards.by_actor("Daisy")]],"bonus":"breach","rule":"Doomguy + Daisy"})
	return result

static func matches(id: int, group: Array) -> bool:
	return Cards.base_id(id) in group or Cards.DATA[id].source_id in group

static func members(row: Array, combo: Dictionary) -> Array:
	var lanes: Array = []
	for group in combo.groups:
		var found := -1
		for lane in row.size():
			if not row[lane].is_empty() and not lanes.has(lane) and matches(row[lane].id,group):
				found = lane
				break
		if found < 0:
			return []
		lanes.append(found)
	return lanes

static func active(row: Array) -> Array:
	return COMBOS.filter(func(combo): return not members(row,combo).is_empty())

static func bonus(row: Array, lane: int, kind: String) -> int:
	if row[lane].has("combat_"+kind):
		return int(row[lane]["combat_"+kind])
	for combo in COMBOS:
		if combo.bonus == kind and lane in members(row,combo):
			return 1 # Same bonus never stacks, even across multiple squads.
	return 0

static func lock_combat(row: Array) -> void:
	# Store on the actual units, so replacement monsters cannot inherit a dead ally's bonus.
	for lane in row.size():
		if row[lane].is_empty(): continue
		for kind in ["attack","breach"]:
			var value := int(row[lane].get("combat_"+kind,0))
			for combo in COMBOS:
				if combo.bonus==kind and lane in members(row,combo): value = 1
			row[lane]["combat_"+kind] = value

static func clear_combat(row: Array) -> void:
	for unit in row:
		unit.erase("combat_attack")
		unit.erase("combat_breach")

static func attack_value(row: Array, lane: int) -> int:
	return maxi(1,Cards.DATA[row[lane].id].atk+int(row[lane].get("reinforced",false))+bonus(row,lane,"attack")-int(row[lane].get("chilled",false)))

static func retaliation(row: Array, lane: int) -> int:
	# Snapshot before impact: even a lethal hit receives the defender's last blow.
	return int((attack_value(row,lane)+1)/2)

static func damage(row: Array, lane: int, defender: int) -> int:
	var id: int = row[lane].id
	return maxi(1,Cards.damage(id,defender)+int(row[lane].get("reinforced",false))+bonus(row,lane,"attack")+bonus(row,lane,"breach")+int(Cards.DATA[id].level==10)-int(row[lane].get("chilled",false)))

static func can_reinforce(unit: Dictionary, id: int) -> bool:
	if unit.is_empty() or unit.get("reinforced",false) or unit.get("token",false) or Cards.DATA[id].hp<=0:
		return false
	var a := Cards.base_id(unit.id)
	var b := Cards.base_id(id)
	return a==b or (a in [1,3,23] and b in [1,3,23]) or (a in [2,14] and b in [2,14]) or (a in [6,16] and b in [6,16])

static func reinforce(unit: Dictionary, id: int) -> void:
	assert(can_reinforce(unit,id))
	var old: int = unit.id
	unit.id = Cards.leveled_id(old,maxi(Cards.DATA[old].level,Cards.DATA[id].level))
	unit.hp += Cards.DATA[unit.id].hp-Cards.DATA[old].hp+2
	unit.reinforced = true
	# Readiness, damage already taken, shields and cooldowns are preserved.

static func potential(row: Array, hand: Array) -> float:
	# Small incentive to keep a playable missing piece, never stronger than survival.
	var value := 0.0
	for combo in COMBOS:
		if not members(row,combo).is_empty():
			continue
		var present := 0
		var missing_in_hand := 0
		for group in combo.groups:
			if row.any(func(u): return not u.is_empty() and matches(u.id,group)):
				present += 1
			elif hand.any(func(id): return matches(id,group)):
				missing_in_hand += 1
		if present>0 and present+missing_in_hand==combo.groups.size():
			value += 0.7
	return minf(2.1,value)

# Compatibility for callers requesting only explicitly saved hand copies.
static func playable_marks(row: Array, hand: Array, marks: Dictionary, energy: int, souls: int) -> Dictionary:
	var result := {}
	for index in hand_hints(row,hand,energy,souls).playable:
		if marks.has(index): result[index] = true
	return result

# One shared assessment drives both the guide and automatic hand hints.
static func deployment_plans(groups: Array, row: Array, hand: Array, index := 0, lanes: Array = [], picks: Array = [], energy := 0, souls := 0) -> Array:
	if index==groups.size(): return [{"picks":picks,"energy":energy,"souls":souls}]
	var plans: Array = []
	for lane in row.size():
		if not lanes.has(lane) and not row[lane].is_empty() and matches(row[lane].id,groups[index]):
			plans.append_array(deployment_plans(groups,row,hand,index+1,lanes+[lane],picks,energy,souls))
	for h in hand.size():
		var data: Dictionary = Cards.DATA[hand[h]]
		if not picks.has(h) and data.hp>0 and matches(hand[h],groups[index]):
			plans.append_array(deployment_plans(groups,row,hand,index+1,lanes,picks+[h],energy+data.cost,souls+int(data.get("soul_cost",0))))
	return plans

static func deployment_status(combo: Dictionary, row: Array, hand: Array, energy: int, souls: int) -> Dictionary:
	var result := {"state":"INCOMPLETE","detail":"","available":{},"playable":{}}
	if not members(row,combo).is_empty():
		result.state = "ACTIVE"
		return result
	var spaces: int = row.filter(func(u): return u.is_empty()).size()
	var best_score := 100000
	for plan in deployment_plans(combo.groups,row,hand):
		for h in plan.picks: result.available[h] = true
		var missing_space := maxi(0,plan.picks.size()-spaces)
		var missing_energy := maxi(0,plan.energy-energy)
		var missing_souls := maxi(0,plan.souls-souls)
		var score := missing_space*100+missing_energy+missing_souls
		if score==0:
			for h in plan.picks: result.playable[h] = true
		if score<best_score:
			best_score = score
			var needs: Array[String] = []
			if missing_space>0: needs.append("%d free lanes (%d available)" % [plan.picks.size(),spaces])
			if missing_energy>0: needs.append("%d more Energy" % missing_energy)
			if missing_souls>0: needs.append("%d more Souls" % missing_souls)
			result.detail = "Needs "+", ".join(needs) if not needs.is_empty() else ""
	if not result.available.is_empty(): result.state = "PIECES AVAILABLE"
	if not result.playable.is_empty(): result.state = "PLAYABLE NOW"
	return result

static func hand_hints(row: Array, hand: Array, energy: int, souls: int) -> Dictionary:
	var result := {"available":{},"playable":{}}
	for combo in COMBOS:
		var status := deployment_status(combo,row,hand,energy,souls)
		result.available.merge(status.available)
		result.playable.merge(status.playable)
	return result
