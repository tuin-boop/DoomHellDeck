extends RefCounted
const BOSSES := [
	{"name":"THE TAX COLLECTOR","rule":"Repeat your last scoring family: -8 points (minimum 1)."},
	{"name":"THE GATEKEEPER","rule":"New combinations lose 6 points. Extensions are untouched."},
	{"name":"THE GLUTTON","rule":"Plays of only one or two cards lose 7 points (minimum 1)."}
]
static func boss_loss(boss: int, gain: int, count: int, extension: bool, repeated: bool) -> int:
	var penalty := 0
	if boss==0 and repeated: penalty = 8
	if boss==1 and not extension: penalty = 6
	if boss==2 and count<=2: penalty = 7
	return mini(maxi(0,gain-1),penalty)

static func special_pattern(m, owner: int, ids: Array, required_kind: String) -> Dictionary:
	var best: Dictionary = m.pattern(ids,required_kind)
	if not (m.support.has(owner,47) or m.support.has(owner,48) or m.support.has(owner,49) or (m.run.enabled and m.run.stage>=2)): return best
	# Resolve Romero once and retain the choice, just like normal combinations.
	if ids.has(-1):
		for replacement in m.POOL:
			var resolved := ids.duplicate()
			resolved[resolved.find(-1)] = replacement
			var candidate := special_pattern(m,owner,resolved,required_kind)
			if not candidate.is_empty() and candidate.points>best.get("points",-1):
				best = candidate
				best.resolved_ids = resolved
		return best
	if ids.size()<3: return best
	var copies := {}
	var counts := {}
	var types := {}
	var ranks: Array = []
	for id in ids:
		copies[id] = int(copies.get(id,0))+1
		counts[id] = true
		var card: Dictionary = m.card_data(id)
		types[card.type] = int(types.get(card.type,0))+1
		ranks.append(card.cost)
	var candidates: Array = []
	if m.run.enabled:
		if m.run.stage>=2 and ids.size()==4 and counts.size()==4 and types.size()==2 and types.values().min()==2:
			candidates.append({"name":"CROSSFIRE","kind":"type","points":45})
		if m.run.stage>=3 and ids.size()==6 and copies.size()==2 and copies.values().min()==3:
			candidates.append({"name":"TWIN TRINITY","kind":"pairs","points":90})
		if m.run.stage>=4 and ids.size()>=4 and counts.size()==ids.size():
			var ordered := ranks.duplicate()
			ordered.sort()
			var skips := 0
			var valid_chaos := true
			for i in range(1,ordered.size()):
				var gap: int = ordered[i]-ordered[i-1]
				if gap==2: skips += 1
				elif gap!=1: valid_chaos = false
			if valid_chaos and skips==1: candidates.append({"name":"CHAOS MARCH","kind":"run","points":55+20*(ids.size()-4)})
	if m.support.has(owner,47) and counts.size()==ids.size():
		ranks.sort()
		var gaps := 0
		var valid := true
		for i in range(1,ranks.size()):
			var gap: int = ranks[i]-ranks[i-1]
			if gap==2: gaps += 1
			elif gap!=1: valid = false
		if valid and gaps==1: candidates.append({"rule_joker":47,"name":"RIFT MARCH","kind":"run","points":20+20*(ids.size()-3)})
	if m.support.has(owner,48) and counts.has(0):
		for team in m.TEAMS:
			if team.ids.has(0): continue
			var present := 0
			for id in team.ids:
				if counts.has(id): present += 1
			if present==2 and counts.size()==3:
				candidates.append({"rule_joker":48,"name":team.name+" / RECRUITED","kind":"team","points":35+15*(ids.size()-3)})
	if m.support.has(owner,49) and counts.size()==ids.size() and types.size()==2:
		if types.values().max()==ids.size()-1:
			candidates.append({"rule_joker":49,"name":"PRISM GATHERING","kind":"type","points":20+20*(ids.size()-3)})
	for candidate in candidates:
		if required_kind!="" and candidate.kind!=required_kind: continue
		if candidate.points>best.get("points",-1): best = candidate
	return best
