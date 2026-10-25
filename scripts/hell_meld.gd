extends RefCounted
const Cards = preload("res://scripts/cards.gd")
var effects = preload("res://scripts/meld_effects.gd").new()
var round_award_owner := -1
var round_history: Array = []
var round_start_scores := [0,0]
var finale_sound_step := -1
var finale = preload("res://scripts/match_finale.gd").new()
var support = preload("res://scripts/support_jokers.gd").new()
const CARD_BACK = preload("res://assets/cards/hellatro-back.png")
# One identity per classic monster. No rarity variants, weapons or hero cards.
const POOL := [0,1,2,3,4,5,6,7,8,14,15,16,17,18,19,20,21]
const JOKER := -1
const GUIDE_PAGES := 18
const TEAMS := [
	{"name":"BOSS ALLIANCE","ids":[8,21,6]},
	{"name":"HELL ROYALTY","ids":[6,16,7]},
	{"name":"SKY TERROR","ids":[4,5,20]},
	{"name":"IRON PATROL","ids":[1,15,17]},
	{"name":"FURNACE GUARD","ids":[0,6,18]},
	{"name":"SOUL COVEN","ids":[7,4,20]},
	{"name":"HEAVY METAL","ids":[19,21,8]}
]
const MODIFIERS := [
	{"name":"FIRESTORM","rule":"+5 per FIRE card you play"},
	{"name":"ESCALATION","rule":"+8 when you extend the centre"},
	{"name":"WAR BANDS","rule":"+10 when you play a named team"}
]
const RELICS := [
	{"name":"BERSERK","rule":"First extension: +15"},
	{"name":"SOUL SPHERE","rule":"First play of 3+ cards: +12"},
	{"name":"LUCKY SHELL","rule":"Draw, then your next play: +10"}
]
const FAMILIES := ["set","pairs","type","run","rainbow","team"]
const FAMILY_NAMES := {"set":"IDENTICAL MONSTERS","pairs":"PAIRS / ARMIES","type":"TYPE GATHERINGS","run":"MARCHES","rainbow":"APOCALYPSE","team":"NAMED TEAMS"}
const FAMILY_HELP := {
	"set":"2 or more copies of the same monster, such as two Imps.",
	"pairs":"Two or more different monster pairs, including larger armies.",
	"type":"3 or more different monsters sharing a damage type, such as Imp, Arch-Vile and Mancubus (Fire).",
	"run":"3 or more consecutive ranks, such as ranks 1, 2 and 3.",
	"rainbow":"Equal numbers of all five damage types: Bullet, Fire, Energy, Rocket and Melee.",
	"team":"A named team from the field guide, such as Hell Royalty."
}
const PASSIVE_JOKERS := [
	{"name":"FIRE AFFINITY","rule":"+4 per Fire card played"},
	{"name":"CHAIN REACTION","rule":"+8 on every extension"},
	{"name":"TEAM SPIRIT","rule":"+10 on each named team"}
]
var match_powers := false
var upgrades := [{},{}]
var family_plays := [{},{}]
var passive_joker := [-1,-1]
var enhancements := {}
var power_panel := false
var upgrade_offers: Array = []
var upgrade_pending := false
var modifier := -1
var relic := -1
var relic_used := [false,false]
var drew_this_round := [false,false]
var random := RandomNumberGenerator.new()
var hands := [[],[]]
var stock: Array = []
var melds: Array = []
var scores := [0,0]
var rounds := [0,0]
var turns := [0,0]
var round_number := 1
var side := 0
var selected: Array = []
const HINT_CHEAT := "johnromerogod"
var cheat_buffer := ""
var cheat_hints := false
var hint_signature := ""
var hint_cards: Array = []
var hint_combos: Dictionary = {}
var target := -1
var discarded: Array = []
var clearing: Array = []
var dragging := false
var pressed_card := -1
var press_position := Vector2.ZERO
var drag_position := Vector2.ZERO
var drag_cards: Array = []
const CENTER := Rect2(160,235,1120,300)
var guide := false
var guide_page := 0
var discovered := {}
var announcement := {}
const REVEAL_TIME := 3.2
const JOKER_BEAT := 1.4

func reveal_duration() -> float:
	return maxf(REVEAL_TIME,1.7+announcement.get("support_events",[]).size()*JOKER_BEAT+0.65)

const DRAW_PILE := Vector2(80,410)
var draw_flights: Array = []
var sound_cues: Array = []
var round_over := false
var result_winner := -1
var result_variant := 0
var result_counts := [0,0]
var result_age := 0.0
var result_art := {}
var result_sprite: Sprite2D
var finished := false
var message := ""
var round_message := ""
var age := 0.0
var final_turn_seen := [false,false]
var final_turn_owner := -1
var final_turn_age := 99.0
var round_intro := false
var round_intro_age := 0.0
var round_intro_beat := -1
const ROUND_INTRO_TIME := 11.8
var cpu_wait := 0.0
var flights: Array = []
var banner := ""
var banner_age := 99.0
var round_scores := [0,0]
var lifts: Array = []

func start(g) -> void:
	round_history.clear()
	support.reset()
	cheat_hints = false
	cheat_buffer = ""
	hint_signature = ""
	hint_cards.clear()
	random.randomize()
	match_powers = true
	upgrades = [{},{}]
	family_plays = [{},{}]
	var passive := random.randi_range(0,PASSIVE_JOKERS.size()-1)
	passive_joker = [passive,passive]
	power_panel = false
	upgrade_pending = false
	scores = [0,0]
	rounds = [0,0]
	round_number = 1
	finished = false
	discovered.clear()
	guide = false
	g.frontend.at_home = false
	g.frontend.started = true
	g.ended = false
	g.busy = false
	g.modal = "hell_meld"
	g.hero_power.armed = false
	g.cancel_drag()
	next_round()
	support.offer(self)

func next_round() -> void:
	round_start_scores = scores.duplicate()
	round_intro = false
	round_award_owner = -1
	support.begin_round()
	enhancements.clear()
	if match_powers:
		var gilded: int = POOL[random.randi_range(0,POOL.size()-1)]
		var charged: int = POOL[random.randi_range(0,POOL.size()-1)]
		while charged==gilded: charged = POOL[random.randi_range(0,POOL.size()-1)]
		enhancements[gilded] = "GILDED"
		enhancements[charged] = "CHARGED"
	modifier = random.randi_range(0,MODIFIERS.size()-1)
	relic = random.randi_range(0,RELICS.size()-1)
	relic_used = [false,false]
	drew_this_round = [false,false]
	draw_flights.clear()
	sound_cues.clear()
	stock.clear()
	for id in POOL:
		for copy in 4: stock.append(id)
	stock.append(JOKER)
	for i in range(stock.size()-1,0,-1):
		var j := random.randi_range(0,i)
		var temp = stock[i]
		stock[i] = stock[j]
		stock[j] = temp
	hands = [[],[]]
	for i in 5:
		for owner in 2:
			hands[owner].append(stock.pop_back())
			draw_flights.append({"owner":owner,"slot":i,"id":hands[owner][-1],"age":-(i*2+owner)*0.11})
	cue("DSSGCOCK",0,-22)
	cue("DSITEMUP",1.6,-20)
	melds.clear()
	selected.clear()
	flights.clear()
	target = -1
	discarded.clear()
	clearing.clear()
	cancel_drag()
	turns = [0,0]
	round_scores = [0,0]
	support.apply_contract(self)
	side = (round_number-1)%2
	cpu_wait = 2.0
	age = 0
	banner_age = 99
	lifts.clear()
	round_over = false
	final_turn_seen = [false,false]
	final_turn_owner = -1
	final_turn_age = 99.0
	result_winner = -1
	result_age = 0.0
	message = "Drag a combination into the centre, or draw a card to pass."

static func card_data(id: int) -> Dictionary:
	if id==JOKER: return {"name":"JOHN ROMERO", "art":"ROMERO", "cost":0,"type":"WILD"}
	return Cards.DATA[id]

static func pattern(ids: Array, required_kind := "") -> Dictionary:
	if not ids.has(JOKER):
		var result := plain_pattern(ids)
		return result if required_kind=="" or result.get("kind", "")==required_kind else {}
	# One Joker in the deck. Its identity locks when played, so the centre stays readable.
	var best := {}
	for replacement in POOL:
		var resolved := ids.duplicate()
		resolved[resolved.find(JOKER)] = replacement
		var candidate := pattern(resolved,required_kind)
		if not candidate.is_empty() and candidate.points>best.get("points",-1):
			best = candidate
			best.resolved_ids = resolved
	return best

static func plain_pattern(ids: Array) -> Dictionary:
	if ids.size()<2: return {}
	var counts := {}
	var types := {}
	var costs: Array = []
	for id in ids:
		counts[id] = counts.get(id,0)+1
		types[Cards.DATA[id].type] = types.get(Cards.DATA[id].type,0)+1
		costs.append(Cards.DATA[id].cost)
	for team in TEAMS:
		if counts.size()==3 and team.ids.all(func(id): return counts.has(id)):
			return {"kind":"team","name":team.name+(" REINFORCED" if ids.size()>3 else ""),"points":35+15*(ids.size()-3)}
	if counts.size()==1:
		var n := ids.size()
		var name: String = Cards.DATA[ids[0]].name+" "+("DUO" if n==2 else ("PACK" if n==3 else "HORDE"))
		if ids[0]==0: name = "IMP MISCHIEF" if n==2 else ("IMP PACK" if n==3 else "IMP INFERNO")
		return {"kind":"set","name":name,"points":5*n*(n-1)}
	if counts.size()==2:
		var groups: Array = counts.values()
		groups.sort()
		if groups[0]>=2:
			var title := "DOUBLE TROUBLE"
			if groups[1]>=3: title = "HELL HOUSE"
			if groups[0]>=3: title = "TWIN LEGIONS"
			if groups[1]>=4: title = "WAR COUNCIL"
			return {"kind":"pairs","name":title,"points":25+20*(ids.size()-4)}
	if types.size()==5 and types.values().all(func(n): return n==ids.size()/5):
		var sets := ids.size()/5
		return {"kind":"rainbow","name":"APOCALYPSE" if sets==1 else ("DOUBLE APOCALYPSE" if sets==2 else "APOCALYPSE x%d" % sets),"points":65+85*(sets-1)}
	if counts.size()>=3 and counts.values().all(func(n): return n>=2):
		return {"kind":"pairs","name":"TRIPLE THREAT" if counts.size()==3 else "LEGION COUNCIL","points":25+20*(ids.size()-4)}
	var ranks := {}
	for cost in costs: ranks[cost] = ranks.get(cost,0)+1
	var ordered: Array = ranks.keys()
	ordered.sort()
	if ordered.size()>=3 and ranks.values().all(func(n): return n==2):
		var sequence := true
		for i in range(1,ordered.size()):
			if ordered[i]!=ordered[i-1]+1: sequence = false
		if sequence: return {"kind":"run","name":"DOUBLE MARCH","points":70+30*(ordered.size()-3)}
	if ids.size()>=3 and counts.size()==ids.size():
		if types.size()==1:
			var title: String = {"FIRE":"HELLFIRE","ENERGY":"PLASMA","BULLET":"GUNNER","ROCKET":"ROCKET","MELEE":"FANG"}[types.keys()[0]]
			return {"kind":"type","name":title+(" GATHERING" if ids.size()==3 else (" UPRISING" if ids.size()==4 else " DOMINION")),"points":20+20*(ids.size()-3)}
		costs.sort()
		var consecutive := true
		for i in range(1,costs.size()):
			if costs[i]!=costs[i-1]+1: consecutive = false
		if consecutive: return {"kind":"run","name":"DEMON MARCH" if ids.size()==3 else ("HELL PARADE" if ids.size()==4 else "DOOM PROCESSION"),"points":20+20*(ids.size()-3)}
	return {}

func evaluate(owner: int, indices: Array, destination := -1) -> Dictionary:
	if indices.is_empty(): return {}
	destination = -1 if melds.is_empty() else 0
	var ids: Array = []
	for index in indices: ids.append(hands[owner][index])
	if destination>=0:
		var old: Dictionary = melds[destination]
		var upgraded := pattern(old.get("resolved_ids",old.ids)+ids,old.kind)
		if upgraded.is_empty() and old.kind=="set": upgraded = pattern(old.get("resolved_ids",old.ids)+ids,"pairs")
		if upgraded.is_empty(): return {}
		if upgraded.kind!=old.kind and not (old.kind=="set" and upgraded.kind=="pairs"): return {}
		if upgraded.points<=old.points: return {}
		if old.has("resolved_ids") and not upgraded.has("resolved_ids"): upgraded.resolved_ids = old.resolved_ids+ids
		upgraded["gain"] = upgraded.points-old.points
		return score_play(owner,ids,upgraded,true)
	var result := pattern(ids)
	if not result.is_empty(): result["gain"] = result.points
	return score_play(owner,ids,result,false) if not result.is_empty() else {}

func best_move(owner: int) -> Dictionary:
	var best := {"indices":[],"target":-1,"value":-1.0,"legal":[],"hints":{}}
	# Search up to five cards, including the rare five-type Apocalypse.
	search(owner,[],0,best)
	return best

func search(owner: int, indices: Array, first: int, best: Dictionary) -> void:
	if not indices.is_empty():
		for destination in ([-1] if melds.is_empty() else [0]):
			var combo := evaluate(owner,indices,destination)
			if combo.is_empty(): continue
			for index in indices:
				if not best.legal.has(index): best.legal.append(index)
				if cheat_hints and owner==0:
					var names: Array[String] = []
					for member in indices: names.append(card_data(hands[owner][member]).name)
					var explanation: String = combo.name+" / "+("EXTEND" if destination>=0 else "NEW")+" / "+", ".join(names)
					if not best.hints.has(index): best.hints[index] = []
					if not best.hints[index].has(explanation): best.hints[index].append(explanation)
			# Score comes first; preserve cards when two plays earn the same points.
			var value: float = combo.gain*100-indices.size()
			if value>best.value:
				best.indices = indices.duplicate()
				best.target = destination
				best.value = value
	if indices.size()==6: return
	for i in range(first,hands[owner].size()): search(owner,indices+[i],i+1,best)

func play(owner: int, indices: Array, destination: int) -> bool:
	if support.pending or round_over or owner!=side: return false
	destination = -1 if melds.is_empty() else 0
	var combo := evaluate(owner,indices,destination)
	if combo.is_empty(): return false
	var ids: Array = []
	var landing_meld: int = melds.size() if destination<0 else destination
	var previous_name: String = "" if destination<0 else melds[destination].name
	var previous_points: int = 0 if destination<0 else melds[destination].points
	var previous_count: int = 0 if destination<0 else melds[destination].ids.size()
	var landing_count := previous_count+indices.size()
	var played_ids: Array = []
	for index in indices: played_ids.append(hands[owner][index])
	combo.gain -= combo.get("support_bonus",0)
	var support_result: Dictionary = support.score(self,owner,played_ids,combo,previous_count>0,true)
	combo.gain = support_result.gain
	combo.support_events = support_result.events
	combo.support_bonus = support_result.bonus
	combo.starter = owner if destination<0 else melds[destination].get("starter",1-owner)
	for index in indices:
		var id: int = hands[owner][index]
		ids.append(id)
		var slot := previous_count+ids.size()-1
		flights.append({"id":id,"meld":landing_meld,"slot":slot,"from":(drag_position+Vector2((ids.size()-1)*28,0) if dragging else hand_center(index,hands[0].size())) if owner==0 else Vector2(720,145),"to":center_card(slot,landing_count),"age":-ids.size()*0.05})
	var sorted := indices.duplicate()
	sorted.sort()
	sorted.reverse()
	for index in sorted: hands[owner].remove_at(index)
	if destination<0:
		combo.ids = ids
		melds.append(combo)
		destination = melds.size()-1
	else:
		combo.ids = melds[destination].ids+ids
		melds[destination] = combo
	family_plays[owner][combo.kind] = family_plays[owner].get(combo.kind,0)+1
	if combo.relic_bonus>0: relic_used[owner] = true
	# Existing centre cards slide apart to make room for the new arrivals.
	var overtake: bool = round_scores[owner]<=round_scores[1-owner] and round_scores[owner]+combo.gain>round_scores[1-owner]
	scores[owner] += combo.gain
	round_scores[owner] += combo.gain
	banner = combo.name
	announcement = {"kind":combo.kind,"joker":ids.has(JOKER),"ids":combo.ids.duplicate(),"owner":owner,"gain":combo.gain,"upgrade":previous_count>0,"before":previous_name,"old_points":previous_points,"points":combo.points,"new":not discovered.has(combo.name),"base":combo.base_gain,"round_bonus":combo.round_bonus,"relic_bonus":combo.relic_bonus,"power_bonus":combo.power_bonus}
	announcement.overtake = overtake
	announcement.gibs = (combo.gain>=65 or combo.kind=="team") and (turns[owner]+round_number)%3==0
	announcement.support_events = combo.support_events
	announcement.support_bonus = combo.support_bonus
	discovered[combo.name] = true
	banner_age = 0
	cue("DSSGCOCK",0.12,-18)
	if combo.kind in ["rainbow","team","type"]: cue("DSPLASMA" if combo.kind=="rainbow" else "DSFIRSHT",1.05,-20)
	cue("DSBAREXP" if previous_count>0 or combo.gain>=65 else "DSPUNCH",0.72,-10 if combo.gain>=65 else -17)
	cue("DSGETPOW" if previous_count>0 else "DSITEMUP",1.45,-17)
	message = ("YOU" if owner==0 else "CPU")+" played "+combo.name+"."
	selected.clear()
	target = -1
	end_action(owner)
	return true

func draw_one(owner: int) -> bool:
	if support.pending or round_over or side!=owner: return false
	var draw_count: int = support.on_draw(owner)
	drew_this_round[owner] = true
	if draw_count==2 and stock.size()>1:
		hands[owner].append(stock.pop_back())
		draw_flights.append({"owner":owner,"slot":hands[owner].size()-1,"id":hands[owner][-1],"age":-0.15})
	if not stock.is_empty():
		hands[owner].append(stock.pop_back())
		draw_flights.append({"owner":owner,"slot":hands[owner].size()-1,"id":hands[owner][-1],"age":0.0})
		cue("DSSGCOCK",0,-22)
		cue("DSITEMUP",0.7,-22)
		message = "You drew a monster and passed." if owner==0 else "CPU drew a monster and passed."
		if draw_count==2: message = "Clown Pain Elemental: drew up to two monsters and passed."
	else: message = "Stock empty. Turn passed."
	if not melds.is_empty():
		var ids: Array = melds[0].ids
		for i in ids.size(): clearing.append({"id":ids[i],"from":center_card(i,ids.size()),"age":-i*0.04})
		discarded.append_array(ids)
		melds.clear()
		flights.clear()
		message += " Centre cleared. Opponent leads a new combination."
		target = -1
	selected.clear()
	end_action(owner)
	return true

func end_action(owner: int) -> void:
	turns[owner] += 1
	if turns[0]>=10 and turns[1]>=10:
		var winner := -1
		if round_scores[0]!=round_scores[1]: winner = 0 if round_scores[0]>round_scores[1] else 1
		finish_round(winner,"won on round points (%d : %d)" % [round_scores[0],round_scores[1]])
		return
	side = 1-owner
	if turns[side]>=10: side = owner
	cpu_wait = 1.35

func match_winner() -> int:
	if scores[0]==scores[1]: return -1
	return 0 if scores[0]>scores[1] else 1

func finish_round(winner: int, reason: String) -> void:
	if round_over: return
	round_over = true
	round_award_owner = winner
	result_winner = winner
	result_age = 0.0
	if winner>=0:
		cue("DSGETPOW",reveal_duration() if banner_age<reveal_duration() else 0.8,-14)
		rounds[winner] += 1
		scores[winner] += 30
		round_message = ("YOU" if winner==0 else "CPU")+" "+reason+". +30 round-win points!"
	else: round_message = "Tied round. No round bonus."
	round_history.append({"points":[scores[0]-round_start_scores[0],scores[1]-round_start_scores[1]],"winner":winner})
	finale_sound_step = -1
	finished = round_number==5
	upgrade_pending = not finished
	upgrade_offers = FAMILIES.duplicate()
	for i in range(upgrade_offers.size()-1,0,-1):
		var j := random.randi_range(0,i)
		var temp = upgrade_offers[i]
		upgrade_offers[i] = upgrade_offers[j]
		upgrade_offers[j] = temp
	upgrade_offers = upgrade_offers.slice(0,3)
	if finished:
		result_winner = match_winner()
		finale.choose_picture(result_winner)
		var winner_name := "YOU WIN" if result_winner==0 else ("CPU WINS" if result_winner==1 else "DRAW")
		round_message = winner_name+" / ROUNDS %d : %d / POINTS %d : %d" % [rounds[0],rounds[1],scores[0],scores[1]]

	if result_winner>=0:
		result_variant = result_counts[result_winner]%2
		result_counts[result_winner] += 1

func tick(g, delta: float) -> void:
	if is_instance_valid(result_sprite): result_sprite.visible = false
	if g.modal!="hell_meld" or guide or power_panel or support.pending or support.library or round_intro:
		support.set_player_drawer(g,false)
	support.update_drawers(g.get_global_mouse_position(),delta,g.modal=="hell_meld" and not support.pending and not support.library and not guide and not power_panel and not dragging)
	if support.pending:
		var before: float = support.draft_age
		support.draft_age += delta
		for i in support.offers.size():
			if before<i*0.65+1 and support.draft_age>=i*0.65+1: g.audio.play("DSBDOPN" if support.offers[i] not in support.RARE else "DSGETPOW",-18)
		return
	if support.library: return
	if g.modal!="hell_meld": return
	if guide or power_panel: return
	if round_intro:
		round_intro_age += delta
		var beat := mini(4,int(round_intro_age/2.2))
		if beat!=round_intro_beat:
			round_intro_beat = beat
			g.audio.play("DSGETPOW",-18)
		if round_intro_age>=ROUND_INTRO_TIME: round_intro = false
		return
	var signature := str([hands[0],melds,side,round_over,cheat_hints])
	if signature!=hint_signature:
		hint_signature = signature
		hint_cards = []
		hint_combos = {}
		if cheat_hints and side==0 and not round_over:
			var moves := best_move(0)
			hint_cards = moves.legal
			hint_combos = moves.hints
	if draw_flights.is_empty() and not round_over:
		support.reminder_age = minf(support.REMINDER_TIME,support.reminder_age+delta)
	age += delta
	for sound in sound_cues:
		sound.delay -= delta
		if sound.delay<=0: g.audio.play(sound.key,sound.volume)
	sound_cues = sound_cues.filter(func(c): return c.delay>0)
	for card in draw_flights: card.age += delta
	draw_flights = draw_flights.filter(func(c): return c.age<0.85)
	for card in clearing: card.age += delta
	clearing = clearing.filter(func(c): return c.age<0.75)
	while lifts.size()<hands[0].size(): lifts.append(0.0)
	for i in hands[0].size(): lifts[i] = lerpf(float(lifts[i]),32.0 if selected.has(i) else 0.0,1-exp(-delta*15))
	banner_age += delta
	if round_over and banner_age>=reveal_duration():
		result_age += delta
		if finished:
			var step := mini(round_history.size(),int(maxf(0,result_age-0.5)/2.0))
			if step!=finale_sound_step:
				finale_sound_step = step
				g.audio.play("DSBAREXP" if step<round_history.size() else "DSGETPOW",-18)
	final_turn_age += delta
	if not round_over and turns[side]==9 and not final_turn_seen[side] and banner_age>=reveal_duration() and draw_flights.is_empty():
		final_turn_seen[side] = true
		final_turn_owner = side
		final_turn_age = 0.0
		g.audio.play("DSGETPOW",-16)
		if side==1: cpu_wait = maxf(cpu_wait,2.5)
	for flight in flights: flight.age += delta
	flights = flights.filter(func(f): return f.age<0.8)
	if side==1 and not round_over and not guide and banner_age>=reveal_duration() and draw_flights.is_empty():
		cpu_wait -= delta
		if cpu_wait<=0:
			var move := best_move(1)
			if move.indices.is_empty(): draw_one(1)
			else: play(1,move.indices,move.target)
	if finished: g.ended = true

func hand_center(index: int, count: int) -> Vector2:
	var step := minf(135,1010.0/maxi(1,count-1))
	var x: float = (index-(count-1)/2.0)*step
	return Vector2(720+x,770+pow(absf(x)/600,2)*28)

func center_card(index: int, count: int) -> Vector2:
	return Vector2(720+(index-(count-1)/2.0)*minf(145,880.0/maxi(1,count-1)),400)

func cancel_drag() -> void:
	dragging = false
	pressed_card = -1
	drag_cards.clear()

func hand_hit(pos: Vector2) -> int:
	for i in range(hands[0].size()-1,-1,-1):
		var center := hand_center(i,hands[0].size())-Vector2(0,float(lifts[i]) if i<lifts.size() else 0.0)
		if Rect2(center-Vector2(77,105),Vector2(155,210)).has_point(pos): return i
	return -1

func draw_card(g, id: int, center: Vector2, size: Vector2, tilt := 0.0, chosen := false) -> void:
	var local: Vector2 = (g.get_global_mouse_position()-center)/size
	var hovered: bool = Rect2(center-size/2,size).has_point(g.get_global_mouse_position()) and not support.pending and not support.library and not power_panel
	g.draw_set_transform_matrix(preload("res://scripts/card_tilt.gd").pose(center,local.x,hovered,tilt))
	var rect := Rect2(-size/2,size)
	g.draw_style_box(card_style(chosen),rect)
	var d: Dictionary = card_data(id)
	var explanation: String = "Rank %d, %s damage type. Combine matching monsters, damage types or consecutive ranks; see the field guide for teams." % [d.cost,d.type]
	if id==JOKER: explanation = "Romero is a WILD monster card: replaces one missing monster, then keeps that identity while on the table. Support Jokers occupy separate slots."
	if enhancements.has(id): explanation += " "+enhancements[id]+(": +4 points when played." if enhancements[id]=="GILDED" else ": +8 points when extending the centre.")
	if support.drained[0].has(id): explanation += " Your copies are drained this round: their enhancement is inactive. CPU copies are unaffected."
	g.ui_help.offer(Rect2(center-size/2,size),d.name,explanation)
	var frames: Array = g.art.textures.get(d.art,[])
	if not frames.is_empty():
		var tex: Texture2D = frames[int(age*2)%frames.size()]
		var dimensions: Vector2 = tex.get_size()
		dimensions *= minf(size.x*0.8/dimensions.x,size.y*0.63/dimensions.y)
		var sprite_rect := Rect2(Vector2(-dimensions.x/2,-size.y*0.25),dimensions)
		if id!=JOKER and Cards.base_id(id)==14:
			# Spectre uses Pinky's silhouette, with a spectral shimmer instead of solid flesh.
			for ghost in [-1,1]:
				g.draw_texture_rect(tex,Rect2(sprite_rect.position+Vector2(ghost*(3+sin(age*4)*2),0),dimensions),false,Color(0.12,0.8,1,0.13))
			g.draw_texture_rect(tex,sprite_rect,false,Color(0.12,0.85,1,0.52+sin(age*3)*0.08))
			for row in range(0,int(dimensions.y),7):
				var stripe := Rect2(sprite_rect.position+Vector2(sin(age*7+row)*2,row),Vector2(dimensions.x,minf(2,dimensions.y-row)))
				var source := Rect2(0,row/dimensions.y*tex.get_height(),tex.get_width(),stripe.size.y/dimensions.y*tex.get_height())
				g.draw_texture_rect_region(tex,stripe,source,Color(0.2,0.9,1,0.25))
		else:
			g.draw_texture_rect(tex,sprite_rect,false)
	if enhancements.has(id):
		var enhanced_color := Color("ffd679") if enhancements[id]=="GILDED" else Color("6adfff")
		g.draw_rect(rect.grow(-3),enhanced_color,false,2)
		g.label_at(Vector2(-size.x/2+8,size.y/2-35),enhancements[id],12 if size.x>120 else 8,enhanced_color)
	if id==JOKER or enhancements.has(id):
		var perimeter := 2*(size.x+size.y)
		for spark in 20:
			var distance := fposmod(age*95+spark*perimeter/20,perimeter)
			var point := Vector2.ZERO
			if distance<size.x: point = Vector2(distance,0)
			elif distance<size.x+size.y: point = Vector2(size.x,distance-size.x)
			elif distance<2*size.x+size.y: point = Vector2(2*size.x+size.y-distance,size.y)
			else: point = Vector2(0,perimeter-distance)
			var color := Color.from_hsv(fposmod(age*0.2+spark/20.0,1),0.8,1)
			if id!=JOKER: color = Color("ffdf70") if enhancements[id]=="GILDED" else Color("6aeaff")
			g.draw_rect(Rect2(point-size/2-Vector2(2,2),Vector2(4,4)),color)
	var font_size := 16 if size.x>120 else 10
	while font_size>8 and g.font.get_string_size(d.name,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>size.x-16: font_size -= 1
	g.label_at(rect.position+Vector2(8,23),d.name,font_size,g.INK)
	g.label_at(Vector2(-size.x/2+8,size.y/2-14),("WILD" if id==JOKER else "%d / %s" % [d.cost,d.type]),14 if size.x>120 else 9,g.TYPE_COLORS.get(d.type,Color("ffe594")))
	if hovered: g.draw_line(rect.position+Vector2(5,3),rect.position+Vector2(size.x-5,3),Color(1,1,1,0.65),2)
	g.draw_set_transform(Vector2.ZERO)

func card_style(chosen: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17312e") if chosen else Color("111e20")
	style.border_color = Color("ffd979") if chosen else Color("889c8d")
	style.set_border_width_all(3 if chosen else 2)
	style.set_corner_radius_all(8)
	style.shadow_color = Color(0,0,0,0.6)
	style.shadow_size = 7
	style.shadow_offset = Vector2(3,5)
	return style

func draw(g) -> void:
	g.draw_rect(Rect2(0,0,1440,940),Color(0.015,0.07,0.055,0.89))
	g.label_at(Vector2(65,65),"HELLATRO",36,g.ORANGE)
	g.label_at(Vector2(65,102),"ROUND %d / 5   ROUNDS WON %d : %d" % [round_number,rounds[0],rounds[1]],19,g.INK)
	g.button(Rect2(1140,30,230,45),"MAIN MENU")
	g.button(Rect2(1140,85,230,45),"COMBINATIONS")
	g.button(Rect2(1140,140,230,40),"MATCH POWERS")
	g.button(Rect2(1375,895,55,30),"F8")
	for i in hands[1].size():
		if draw_flights.any(func(c): return c.owner==1 and c.slot==i): continue
		draw_back(g,cpu_card(i),Vector2(56,82))
	for i in 4 if not stock.is_empty() else 0:
		draw_back(g,DRAW_PILE+Vector2(i*3,-i*4),Vector2(100,144))
	g.label_at(Vector2(27,510),"%d LEFT" % stock.size(),16,g.INK)
	g.label_at(Vector2(22,535),"DRAW / PASS",12,g.ORANGE)
	g.label_at(Vector2(535,170),"CPU: %d CARDS / TURN %d OF 10" % [hands[1].size(),mini(10,turns[1]+1)],16,g.MUTED)
	if modifier>=0:
		g.draw_rect(Rect2(174,177,870,24),Color(1.0,0.48,0.16,0.05+sin(age*2)*0.02))
		g.draw_line(Vector2(174,200),Vector2(1044,200),Color(1.0,0.48,0.16,0.25+sin(age*2)*0.1),1)
		g.label_at(Vector2(180,195),"ROUND: "+MODIFIERS[modifier].name+" / "+MODIFIERS[modifier].rule,15,g.ORANGE)
	if relic>=0:
		g.label_at(Vector2(180,220),RELICS[relic].name+" / "+RELICS[relic].rule,14,g.INK)
		for owner in 2: draw_relic_status(g,owner,Rect2(740+owner*155,202,145,26))
	g.draw_rect(CENTER,Color(0.06,0.14,0.11,0.45))
	g.draw_rect(CENTER,Color("b9a777") if dragging else Color("40574b"),false,3 if dragging else 1)
	if melds.is_empty():
		g.label_at(Vector2(460,345),"DROP A COMBINATION HERE",26,g.MUTED)
		g.label_at(Vector2(420,390),"Extend what is left, or draw and pass.",18,g.MUTED)
	else:
		var meld: Dictionary = melds[0]
		animated_combo_title(g,meld.name+" / "+str(meld.points)+" POINTS",Vector2(220,270),23,1.0,false)
		for i in meld.ids.size():
			if flights.any(func(f): return f.slot==i and f.age<0.7): continue
			var impact := clampf((banner_age-0.72)/0.38,0,1)
			var shake := Vector2(sin(banner_age*85),cos(banner_age*69))*(1-impact)*9*float(g.screen_shake) if banner_age>=0.72 else Vector2.ZERO
			var pose := celebration_pose(i,meld.ids.size())
			draw_card(g,meld.ids[i],pose.center+shake,Vector2(145,205)*pose.scale*(1+sin(impact*PI)*0.12),pose.tilt)
	if not melds.is_empty() and melds[0].ids.has(JOKER):
		var slot: int = melds[0].ids.find(JOKER)
		var identity: int = melds[0].get("resolved_ids",melds[0].ids)[slot]
		g.label_at(Vector2(180,558),"ROMERO PLAYS AS: "+card_data(identity).name,14,Color("ffe594"))
	g.label_at(Vector2(1130,565),"DISCARDED: "+str(discarded.size()),14,g.MUTED)
	g.label_at(Vector2(145,580),message.left(98),18,g.INK)
	g.label_at(Vector2(145,610),"YOUR TURN %d / 10 / %d CARDS" % [mini(10,turns[0]+1),hands[0].size()] if side==0 else "CPU IS THINKING...",19,g.ORANGE)
	g.label_at(Vector2(145,640),"Spot a pattern. Select cards and drag to commit. Consult the illustrated field guide.",17,g.INK)
	for i in hands[0].size():
		if dragging and drag_cards.has(i): continue
		if draw_flights.any(func(c): return c.owner==0 and c.slot==i): continue
		var center := hand_center(i,hands[0].size())
		if i<lifts.size(): center.y -= float(lifts[i])
		var hint := hint_cards.has(i) and cheat_hints and side==0 and not round_over and banner_age>=reveal_duration() and draw_flights.is_empty()
		var wiggle := sin(age*11+i*0.7) if hint else 0.0
		center.y += wiggle*5
		draw_card(g,hands[0][i],center,Vector2(155,210),(i-(hands[0].size()-1)/2.0)*0.018+sin(age*2+i)*0.003+wiggle*0.035,selected.has(i) or hint)
	if cheat_hints and side==0 and not round_over and banner_age>=reveal_duration():
		var hovered := hand_hit(g.get_global_mouse_position())
		if hint_combos.has(hovered):
			var descriptions: Array = hint_combos[hovered]
			var text := "These are alternative plays, not one combined selection.\n"
			for option in descriptions.slice(0,8): text += str(option)+"\n"
			if descriptions.size()>8: text += "+%d more combinations" % (descriptions.size()-8)
			g.ui_help.offer(Rect2(hand_center(hovered,hands[0].size())-Vector2(85,135),Vector2(170,250)),"AVAILABLE COMBOS",text)
	g.button(Rect2(65,890,225,40),"PLAY SELECTION",side==0 and not selected.is_empty() and not round_over and banner_age>=reveal_duration())
	g.button(Rect2(310,890,190,40),"DRAW / PASS",side==0 and not round_over and draw_flights.is_empty() and banner_age>=reveal_duration())
	g.button(Rect2(520,890,175,40),"SORT HAND")
	g.button(Rect2(715,890,175,40),"FIELD GUIDE")
	g.button(Rect2(910,890,175,40),"CLEAR SELECTION")
	if cheat_hints: g.label_at(Vector2(1135,610),"GOD HINTS ON",14,Color("ffe594"))
	g.label_at(Vector2(1120,918),"STOCK: "+str(stock.size()),16,g.MUTED)
	for flight in flights:
		if flight.age<0: continue
		var t := smoothstep(0,1,clampf(flight.age/0.7,0,1))
		var center: Vector2 = flight.from.lerp(flight.to,t)+Vector2(0,-sin(t*PI)*100)
		draw_card(g,flight.id,center,Vector2(155,210).lerp(Vector2(145,205),t),sin(t*PI)*0.2,true)
	for card in clearing:
		if card.age<0: continue
		var t := smoothstep(0,1,clampf(card.age/0.7,0,1))
		draw_card(g,card.id,card.from.lerp(Vector2(1550,520),t)+Vector2(0,-sin(t*PI)*65),Vector2(145,205)*(1-t*0.5),t*0.45)
	if dragging:
		for i in drag_cards.size(): draw_card(g,hands[0][drag_cards[i]],drag_position+Vector2(i*28,-sin(age*5)*3),Vector2(155,210),(i-(drag_cards.size()-1)/2.0)*0.05,true)
	for card in draw_flights:
		if card.age<0: continue
		var progress := smoothstep(0,1,clampf(card.age/0.85,0,1))
		var destination := hand_center(card.slot,hands[0].size()) if card.owner==0 else cpu_card(card.slot)
		var center: Vector2 = DRAW_PILE.lerp(destination,progress)+Vector2(0,-sin(progress*PI)*110)
		var size := Vector2(100,144).lerp(Vector2(155,210) if card.owner==0 else Vector2(56,82),progress)
		if card.owner==0 and progress>0.55:
			size.x *= maxf(0.08,(progress-0.55)/0.45)
			draw_card(g,card.id,center,size,-sin(progress*PI)*0.18,true)
		else: draw_back(g,center,size,sin(progress*PI)*0.18)
	effects.draw(g,self)
	if banner_age<reveal_duration():
		draw_combo_projectiles(g)
		draw_announcement(g)
	if not guide and not power_panel and not round_over: draw_final_turn(g)
	if guide: draw_guide(g)
	if finished and round_over and banner_age>=reveal_duration():
		finale.draw(g,self)
		return
	if round_over and banner_age>=reveal_duration() and not guide:
		if not power_panel: draw_result_popup(g)
		draw_result_frame(g,Rect2(550,310,850,270))
		g.label_at(Vector2(585,370),"MATCH COMPLETE" if finished else "ROUND COMPLETE",32,g.ORANGE)
		g.label_at(Vector2(585,420),round_message,16,g.INK)
		effects.draw_tally(g,self)
		g.button(Rect2(590,480,350,60),"PLAY AGAIN" if finished else "CHOOSE UPGRADE")
		g.button(Rect2(980,480,350,60),"MAIN MENU")

	if power_panel: draw_powers(g)
	if not power_panel and not guide: support.draw(g,self)
	if round_intro and not support.pending: draw_round_intro(g)

func draw_final_turn(g) -> void:
	if final_turn_owner<0 or final_turn_owner!=side or turns[side]!=9: return
	var pulse := 0.65+0.35*sin(final_turn_age*7.0)
	var accent := Color("ffd16c") if side==0 else Color("ff8957")
	if final_turn_age<2.3:
		var slide := 24.0*(1.0-clampf(final_turn_age/0.22,0.0,1.0))
		var rect := Rect2(390,195-slide,660,92)
		g.draw_rect(rect,Color("241b10"))
		g.draw_rect(rect,Color(accent,pulse),false,3.0)
		for i in 16:
			g.draw_line(rect.position+Vector2(i*42,0),rect.position+Vector2(i*42+16,10),accent,3)
		g.label_at(rect.position+Vector2(110,39),"YOUR FINAL TURN" if side==0 else "CPU FINAL TURN",28,accent)
		g.label_at(rect.position+Vector2(130,70),"TURN 10 / MAKE THIS PLAY COUNT",16,g.INK)
	else:
		g.label_at(Vector2(520,220),"FINAL TURN / "+("YOU" if side==0 else "CPU"),20,accent)

func draw_result_frame(g, rect: Rect2) -> void:
	var trim := Color("e9a344")
	g.draw_rect(Rect2(rect.position+Vector2(7,9),rect.size),Color(0,0,0,0.65))
	g.draw_rect(rect.grow(6),Color("080c0c"))
	g.draw_rect(rect,Color("303a3a"))
	g.draw_rect(rect.grow(-5),Color("0b1718"))
	g.draw_rect(rect.grow(-1),Color("65716b"),false,2)
	g.draw_rect(rect.grow(-7),trim.darkened(0.4),false,1)
	# Riveted corner plates and bright angular brackets.
	for corner in [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,1)]:
		var point: Vector2 = rect.position+rect.size*corner
		var inward: Vector2 = Vector2.ONE-corner*2
		var plate := Rect2(point+Vector2(-23 if corner.x>0 else 0,-23 if corner.y>0 else 0),Vector2(23,23))
		g.draw_rect(plate,Color("424c47"))
		g.draw_circle(point+inward*12,3,Color("0b1010"))
		g.draw_circle(point+inward*11,1,Color("b4b6a0"))
		g.draw_line(point+Vector2(inward.x*37,0),point,trim,3)
		g.draw_line(point,point+Vector2(0,inward.y*37),trim,3)
	# Short animated energy strip, kept within the top metal rail.
	var travel := fposmod(result_age*100.0,rect.size.x-160.0)
	var start := rect.position+Vector2(45+travel,2)
	g.draw_line(start,start+Vector2(55,0),Color("ffe3a0"),3)
	g.draw_line(rect.position+Vector2(30,95),rect.position+Vector2(rect.size.x-30,95),Color("3c4942"),1)

func draw_result_popup(g) -> void:
	if result_winner<0: return
	var key := "%s-win-%d" % ["player" if result_winner==0 else "cpu",result_variant+1]
	if not result_art.has(key):
		result_art[key] = load("res://assets/results/"+key+".png")
	var texture: Texture2D = result_art[key]
	if texture==null: return
	# Rise from below the viewport, leaving the result text and buttons clear.
	var progress := clampf(result_age/0.8,0.0,1.0)
	var eased := 1.0-pow(1.0-progress,3.0)
	var size := texture.get_size()*(880.0/texture.get_height())
	var top := lerpf(960.0,80.0,eased)
	if not is_instance_valid(result_sprite):
		result_sprite = Sprite2D.new()
		result_sprite.centered = false
		var outline := ShaderMaterial.new()
		outline.shader = load("res://assets/shaders/result_outline.gdshader")
		result_sprite.material = outline
		g.add_child(result_sprite)
	result_sprite.texture = texture
	result_sprite.position = Vector2(20,top)
	result_sprite.scale = Vector2.ONE*(880.0/texture.get_height())
	result_sprite.material.set_shader_parameter("source_pixels_per_screen_pixel",texture.get_height()/880.0)
	result_sprite.visible = true

func handle(g, event: InputEvent) -> void:
	if event is InputEventKey and event.keycode==KEY_SPACE and not event.pressed:
		support.set_player_drawer(g,false)
		return
	if round_intro and not support.pending:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER,KEY_ESCAPE]: round_intro = false
		if event is InputEventMouseButton and event.pressed and Rect2(1120,810,180,45).has_point(event.position): round_intro = false
		return
	if not power_panel and not guide and support.handle(g,self,event): return
	if event is InputEventKey and event.pressed and not event.echo and event.unicode>=32:
		cheat_buffer = (cheat_buffer+String.chr(event.unicode).to_lower()).right(HINT_CHEAT.length())
		if cheat_buffer==HINT_CHEAT:
			cheat_hints = not cheat_hints
			cheat_buffer = ""
			hint_signature = ""
			message = "ROMERO GOD: combo hints "+("ON. Playable cards wiggle." if cheat_hints else "OFF.")
			g.audio.play("DSGETPOW" if cheat_hints else "DSSWTCHN",-16)
			return
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		if pressed_card>=0: cancel_drag()
		elif power_panel:
			power_panel = false
		elif guide: guide = false
		else: g.frontend.open(g)
		return
	if event is InputEventMouseMotion and pressed_card>=0:
		drag_position = event.position
		if not dragging and press_position.distance_to(drag_position)>9:
			dragging = true
			drag_cards = selected.duplicate() if selected.has(pressed_card) else [pressed_card]
		return
	if not (event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT): return
	var pos: Vector2 = event.position
	if not event.pressed:
		if pressed_card>=0:
			if dragging:
				if CENTER.has_point(pos):
					if not play(0,drag_cards.duplicate(),-1): message = "That pattern does not fit the centre. Check the field guide and try again."
			elif selected.has(pressed_card): selected.erase(pressed_card)
			else: selected.append(pressed_card)
			cancel_drag()
		return
	if power_panel:
		if Rect2(600,790,240,50).has_point(pos):
			power_panel = false
		elif round_over and upgrade_pending:
			for i in upgrade_offers.size():
				if Rect2(200+i*350,440,330,100).has_point(pos): choose_upgrade(i)
		return
	if guide:
		if Rect2(190,760,210,50).has_point(pos): guide_page = posmod(guide_page-1,GUIDE_PAGES)
		elif Rect2(1040,760,210,50).has_point(pos): guide_page = (guide_page+1)%GUIDE_PAGES
		elif Rect2(600,760,240,50).has_point(pos): guide = false
		return
	if round_over:
		if banner_age<reveal_duration(): return
		if finished:
			if not finale.done(self):
				if Rect2(1120,820,220,40).has_point(pos): result_age = finale.duration(self)
				return
			if Rect2(550,800,340,55).has_point(pos): start(g)
			elif Rect2(960,800,340,55).has_point(pos): g.frontend.open(g)
			return
		if Rect2(590,480,350,60).has_point(pos):
			if finished: start(g)
			else:
				power_panel = true
		elif Rect2(980,480,350,60).has_point(pos): g.frontend.open(g)
		return
	if Rect2(1140,30,230,45).has_point(pos):
		cancel_drag()
		g.frontend.open(g)
	elif Rect2(1140,85,230,45).has_point(pos): guide = true
	elif Rect2(1140,140,230,40).has_point(pos): power_panel = true
	elif Rect2(1375,895,55,30).has_point(pos): g.radio.open(g)
	elif side==0 and banner_age>=reveal_duration() and draw_flights.is_empty():
		if Rect2(65,890,225,40).has_point(pos):
			if not play(0,selected.duplicate(),-1): message = "No matching pattern. Check the field guide and try again."
		elif Rect2(310,890,190,40).has_point(pos) or Rect2(20,325,120,220).has_point(pos):
			draw_one(0)
		elif Rect2(520,890,175,40).has_point(pos):
			hands[0].sort()
			selected.clear()
		elif Rect2(715,890,175,40).has_point(pos):
			guide = true
		elif Rect2(910,890,175,40).has_point(pos): selected.clear()
		else:
			pressed_card = hand_hit(pos)
			press_position = pos
			drag_position = pos

func centered(g, text: String, y: float, size: int, color: Color) -> void:
	g.draw_string_outline(g.font,Vector2(-g.font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/2,y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,3,Color(0,0,0,color.a))
	g.draw_string(g.font,Vector2(-g.font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/2,y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func animated_combo_title(g, text: String, origin: Vector2, size: int, alpha := 1.0, align_center := true) -> void:
	var width: float = g.font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	var x: float = origin.x-width/2.0 if align_center else origin.x
	for i in text.length():
		var letter := text.substr(i,1)
		var phase: float = g.clock*3.0-i*0.38
		var lift := sin(phase)*2.5
		var shine := pow(maxf(0.0,sin(phase*0.7)),8.0)
		var tint := Color("efac4d").lerp(Color("fff6c5"),shine)
		tint.a = alpha
		var point := Vector2(x,origin.y+lift)
		g.draw_string_outline(g.font,point,letter,HORIZONTAL_ALIGNMENT_LEFT,-1,size,4,Color(0,0,0,alpha))
		g.draw_string(g.font,point+Vector2(0,2),letter,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color(0.55,0.12,0.02,alpha*0.7))
		g.draw_string(g.font,point,letter,HORIZONTAL_ALIGNMENT_LEFT,-1,size,tint)
		x += g.font.get_string_size(letter,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x

func draw_announcement(g) -> void:
	if announcement.is_empty(): return
	var t := banner_age-0.72
	if t<0: return
	var upgraded: bool = announcement.upgrade
	var tint := Color("ffb05c") if announcement.owner==1 else Color("8fffe0")
	var fade := clampf((reveal_duration()-banner_age)/0.4,0,1)
	var punch := 1.0+pow(1-clampf(t/0.28,0,1),2)*(0.65 if upgraded else 0.4)
	var force := 1.0 if upgraded else 0.55
	if t<0.16: g.draw_rect(Rect2(0,0,1440,940),Color(tint,(1-t/0.16)*0.22*force))
	for i in 40 if upgraded else 22:
		var angle := i*2.39996
		var distance := 70+t*(160+(i%5)*55)
		var pos := Vector2(720,390)+Vector2(cos(angle)*1.7,sin(angle))*distance
		var alpha := clampf(1-t/1.1,0,1)
		g.draw_rect(Rect2(pos,Vector2(5+i%4,5+i%4)),Color(tint,alpha))
	g.draw_set_transform(Vector2(720+sin(t*74)*maxf(0,1-t/0.3)*minf(14,announcement.gain/7.0)*float(g.screen_shake),220),0,Vector2.ONE*punch)
	g.draw_rect(Rect2(-540,-10,1080,155),Color(0.025,0.045,0.04,0.96*fade))
	g.draw_line(Vector2(-540,-10),Vector2(540,-10),Color(tint,fade),4 if upgraded else 2)
	for i in 16 if upgraded else 8:
		var angle := i*TAU/(16 if upgraded else 8)
		var origin := Vector2(cos(angle)*490,sin(angle)*65+60)
		g.draw_line(origin,origin+Vector2(cos(angle),sin(angle))*minf(t*75,40),Color(tint,fade*(1-clampf(t/1.4,0,1))),3)
	centered(g,("CPU" if announcement.owner==1 else "YOU")+(" / COMBO UPGRADED!" if upgraded else " / COMBO PLAYED!"),16,18,Color(tint,fade))
	var title_size := 44 if upgraded else 36
	while g.font.get_string_size(banner,HORIZONTAL_ALIGNMENT_LEFT,-1,title_size).x>1020: title_size -= 1
	animated_combo_title(g,banner,Vector2(0,58),title_size,fade)
	var support_events: Array = announcement.get("support_events",[])
	var initial_gain: int = announcement.gain-announcement.get("support_bonus",0)
	var gain := int(round(initial_gain*smoothstep(0,1,clampf((t-0.25)/0.65,0,1))))
	var joker_time := banner_age-1.7
	if joker_time>=0:
		for i in support_events.size():
			if joker_time<i*JOKER_BEAT: break
			var previous: int = initial_gain if i==0 else support_events[i-1].get("total",initial_gain)
			var target_score: int = support_events[i].get("total",announcement.gain)
			gain = int(round(lerpf(previous,target_score,smoothstep(0,1,clampf((joker_time-i*JOKER_BEAT)/0.65,0,1)))))
		if joker_time>=support_events.size()*JOKER_BEAT: gain = announcement.gain
	centered(g,"+%d POINTS" % gain,102,38 if upgraded else 32,Color(tint,fade))
	var detail := "%d TOTAL" % announcement.points
	if upgraded: detail = "%d > %d / INCREASE EARNED" % [announcement.old_points,announcement.points]
	if announcement.get("round_bonus",0)>0 or announcement.get("relic_bonus",0)>0 or announcement.get("power_bonus",0)>0:
		detail = "%d BASE + %d ROUND + %d RELIC + %d POWERS" % [announcement.base,announcement.round_bonus,announcement.relic_bonus,announcement.get("power_bonus",0)]
	elif announcement.new: detail += " / FIRST SIGHTING"
	if announcement.get("support_bonus",0)>0: detail += " + %d JOKERS" % announcement.support_bonus
	centered(g,detail,130,14,Color(0.85,0.88,0.8,fade))
	if not support_events.is_empty() and joker_time>=0:
		var event: Dictionary = support_events[mini(support_events.size()-1,int(joker_time/JOKER_BEAT))]
		centered(g,support.DATA[event.id][1]+" / "+event.text,160,19,Color("ffe594")*Color(1,1,1,fade))
	g.draw_set_transform(Vector2.ZERO)
	if not support_events.is_empty() and joker_time>=0 and joker_time<support_events.size()*JOKER_BEAT:
		var span: float = JOKER_BEAT
		var event_index := mini(support_events.size()-1,int(joker_time/span))
		var phase := clampf((joker_time-event_index*span)/span,0,1)
		var event: Dictionary = support_events[event_index]
		var size := Vector2(160,225)*(0.8+0.2*sin(phase*PI))
		var position := Vector2(720,555)+Vector2(sin(phase*TAU)*12,-sin(phase*PI)*30)
		for ray in 12:
			var direction := Vector2.from_angle(ray*TAU/12+t)
			g.draw_line(position+direction*125,position+direction*(135+sin(phase*PI)*35),Color("ffd979"),2)
		support.card(g,self,event.id,Rect2(position-size/2,size),-1,false)
		g.label_at(position+Vector2(-70,145),("CPU " if announcement.owner==1 else "YOU ")+event.text,22,Color("ffe594"))

func draw_guide(g) -> void:
	var pages := [
		{"title":"IDENTICAL MONSTERS", "ids":[0,0,0], "rule":"2+ copies of ONE monster. Add another copy to upgrade.", "path":"IMP MISCHIEF 10 > IMP PACK 30 > IMP INFERNO 60", "tip":"A pair invites your opponent to claim +20 with just one Imp."},
		{"title":"TWO ARMIES", "ids":[0,0,2,2,2], "rule":"Two monster identities, at least TWO copies of each.", "path":"DOUBLE TROUBLE 25 > HELL HOUSE 45 > TWIN LEGIONS 65", "tip":"A pair can become two pairs. Four copies in either army: WAR COUNCIL."},
		{"title":"DAMAGE TYPE GATHERINGS", "ids":[0,7,18], "rule":"3+ DIFFERENT monsters with the SAME damage type.", "path":"GATHERING 20 > UPRISING 40 > DOMINION 60 (+20 per card)", "tip":"Fire, energy, bullet, rocket or melee. Duplicate monsters do not count."},
		{"title":"THE DEMON MARCH", "ids":[0,2,5,17], "rule":"3+ DIFFERENT monsters with consecutive printed costs.", "path":"DEMON MARCH 20 > HELL PARADE 40 > DOOM PROCESSION 60", "tip":"Add a cost at either end. Costs are ranks here, not energy payments."},
		{"title":"APOCALYPSE", "ids":[0,1,2,5,8], "rule":"FIVE cards: one FIRE, BULLET, MELEE, ENERGY and ROCKET.", "path":"APOCALYPSE / 65 POINTS / A COMPLETE FIVE-CARD FINISH", "tip":"Extend with another complete set of five types for DOUBLE APOCALYPSE."},
		{"title":"READ THE TABLE", "ids":[0,0,0,0], "rule":"Lead or extend a pattern, or draw and pass. Score only the increase.", "path":"SELECT > DRAG > REVEAL / NO AUTOMATIC HAND SOLVER", "tip":"Draw whenever you want: take one, clear the centre and pass the turn."}
	]
	for team in TEAMS:
		pages.append({"title":team.name,"ids":team.ids,"rule":"Play all THREE named monsters together: 35 points.","path":"Add copies of these members: +15 base points per extra card.","tip":"Only these three identities belong to this team. No substitutes."})
	pages.append({"title":"ROUND MODIFIERS","ids":[0,7,18],"rule":"One random rule per round, shared by BOTH players.","path":"FIRESTORM: +5 per new Fire card / ESCALATION: +8 per extension", "tip":"WAR BANDS: +10 per named-team play. Bonuses do not inflate centre value."})
	pages.append({"title":"TEMPORARY DOOM RELICS","ids":[],"rule":"Both sides receive the same relic, with ONE use each per round.","path":"BERSERK: first extension +15 / SOUL SPHERE: first 3+ card play +12", "tip":"LUCKY SHELL: draw, then play for +10. Automatic trigger; resets next round."})
	pages.append({"title":"DOUBLE APOCALYPSE","ids":[1,8,14,16,7],"rule":"Add a SECOND complete set: one card of EACH damage type.","path":"APOCALYPSE 65 > DOUBLE APOCALYPSE 150 > x3 235", "tip":"Play all five together. Each complete added set scores +85 base points."})
	pages.append({"title":"TRIPLE THREAT / DOUBLE MARCH","ids":[0,0,2,2,5,5],"rule":"Three pairs: TRIPLE THREAT 65. More pairs: LEGION COUNCIL.","path":"DOUBLE MARCH: two of each consecutive rank, at least three ranks = 70", "tip":"You can double an existing run by adding its missing ranks together."})
	pages.append({"title":"JOHN ROMERO / THE JOKER","ids":[0,JOKER],"rule":"One Romero in the 69-card deck. Wild: fills ONE missing monster.","path":"The highest-scoring legal identity is chosen automatically when played.","tip":"His identity then locks for this pile. Wild cards earn no Firestorm bonus."})
	var page: Dictionary = pages[guide_page]
	g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.7))
	g.ui_help.reset()
	g.menu_frame(Rect2(160,175,1120,650))
	g.draw_set_transform(Vector2(720,215))
	centered(g,"FIELD GUIDE / %d OF 18" % (guide_page+1),0,18,g.ORANGE)
	animated_combo_title(g,page.title,Vector2(0,45),28)
	centered(g,page.rule,90,17,g.INK)
	g.draw_set_transform(Vector2.ZERO)
	if page.title=="TEMPORARY DOOM RELICS":
		for i in RELICS.size():
			var rect := Rect2(205+i*350,350,330,190)
			g.draw_style_box(card_style(false),rect)
			g.draw_circle(rect.position+Vector2(165,45),23,Color("da8b36"))
			g.label_at(rect.position+Vector2(157,51),str(i+1),20,Color("0b1718"))
			g.label_at(rect.position+Vector2(20,105),RELICS[i].name,21,g.ORANGE)
			g.label_at(rect.position+Vector2(20,145),RELICS[i].rule,14,g.INK)
	for i in page.ids.size():
		draw_card(g,page.ids[i],Vector2(720+(i-(page.ids.size()-1)/2.0)*175,445),Vector2(155,210),0)
	g.draw_set_transform(Vector2(720,600))
	centered(g,page.path,0,16,g.ORANGE)
	centered(g,page.tip,42,16,g.INK)
	centered(g,"Examples only: the guide never checks your hand. %d combo names seen this match." % discovered.size(),82,15,g.MUTED)
	centered(g,"10 turns each. Highest round score wins +30. Empty hand? Draw to keep playing.",116,15,g.MUTED)
	g.draw_set_transform(Vector2.ZERO)
	g.button(Rect2(190,760,210,50),"PREVIOUS")
	g.button(Rect2(600,760,240,50),"BACK TO TABLE")
	g.button(Rect2(1040,760,210,50),"NEXT")

func cue(key: String, delay: float, volume: float) -> void:
	sound_cues.append({"key":key,"delay":delay,"volume":volume})

func cpu_card(index: int) -> Vector2:
	return Vector2(563+index*minf(38,480.0/maxi(1,hands[1].size())),96)

func draw_back(g, center: Vector2, size: Vector2, tilt := 0.0) -> void:
	var local: Vector2 = (g.get_global_mouse_position()-center)/size
	var hover := Rect2(center-size/2,size).has_point(g.get_global_mouse_position())
	g.draw_set_transform_matrix(preload("res://scripts/card_tilt.gd").pose(center,local.x,hover,tilt))
	g.draw_style_box(card_style(false),Rect2(-size/2,size))
	# Preserve the complete supplied artwork, fitting it inside the card border.
	var art_size: Vector2 = CARD_BACK.get_size()
	art_size *= minf((size.x-4)/art_size.x,(size.y-4)/art_size.y)
	g.draw_texture_rect(CARD_BACK,Rect2(-art_size/2,art_size),false)
	g.draw_set_transform(Vector2.ZERO)

func score_play(owner: int, ids: Array, combo: Dictionary, extension: bool) -> Dictionary:
	# Bonuses belong to this action, never to the shared centre's base value.
	var bonus := 0
	if modifier==0:
		for id in ids:
			if card_data(id).type=="FIRE": bonus += 5
	elif modifier==1 and extension: bonus = 8
	elif modifier==2 and combo.kind=="team": bonus = 10
	var relic_bonus := 0
	if not relic_used[owner]:
		if relic==0 and extension: relic_bonus = 15
		elif relic==1 and ids.size()>=3: relic_bonus = 12
		elif relic==2 and drew_this_round[owner]: relic_bonus = 10
	var power_bonus := int(upgrades[owner].get(combo.kind,0))*5
	for id in ids:
		if support.enhancement(self,owner,id)=="GILDED": power_bonus += 4
		elif support.enhancement(self,owner,id)=="CHARGED" and extension: power_bonus += 8
	if passive_joker[owner]==0:
		for id in ids:
			if card_data(id).type=="FIRE": power_bonus += 4
	elif passive_joker[owner]==1 and extension: power_bonus += 8
	elif passive_joker[owner]==2 and combo.kind=="team": power_bonus += 10
	combo.power_bonus = power_bonus
	combo.base_gain = combo.gain
	combo.round_bonus = bonus
	combo.relic_bonus = relic_bonus
	combo.gain += bonus+relic_bonus+power_bonus
	var result: Dictionary = support.score(self,owner,ids,combo,extension)
	combo.support_bonus = result.bonus
	combo.gain = result.gain
	return combo

func celebration_pose(index: int, count: int) -> Dictionary:
	var center := center_card(index,count)
	var tilt := sin(index*2.1)*0.025
	var scale := 1.0
	var t := banner_age-0.95
	if t<0 or banner_age>=reveal_duration() or announcement.is_empty():
		return {"center":center,"tilt":tilt,"scale":scale}
	var envelope := sin(clampf(t/(reveal_duration()-0.95),0,1)*PI)
	var phase := t*TAU*1.7+index*0.8
	var kind: String = announcement.get("kind", "")
	if kind=="rainbow":
		var angle := index*TAU/count+t*TAU*0.65
		var orbit := Vector2(720+cos(angle)*430,425+sin(angle)*65)
		center = center.lerp(orbit,envelope)
		tilt += sin(angle)*0.22*envelope
		scale -= 0.2*envelope
	elif kind=="team":
		center += Vector2(sin(phase)*20,-absf(sin(phase))*60)*envelope
		tilt += sin(phase)*0.18*envelope
	elif kind=="run":
		center += Vector2(sin(t*5)*20,sin(phase)*50)*envelope
		tilt += cos(phase)*0.16*envelope
	elif kind=="pairs":
		center += Vector2(sin(phase)*28,-absf(sin(phase))*40)*envelope
		tilt += sin(phase)*0.25*envelope
	else:
		center += Vector2(sin(phase)*12,sin(phase)*35)*envelope
		scale += sin(phase)*0.07*envelope
	if announcement.get("joker",false) and index<announcement.get("ids",[]).size() and announcement.ids[index]==JOKER:
		tilt += TAU*smoothstep(0,1,clampf(t/1.65,0,1))
		center.y -= 35*envelope
	return {"center":center,"tilt":tilt,"scale":scale}

func draw_combo_projectiles(g) -> void:
	var t := banner_age-0.8
	if t<0 or announcement.is_empty(): return
	var kind: String = announcement.get("kind", "")
	var special: bool = kind in ["rainbow","team","type","run","pairs"] or announcement.get("joker",false) or announcement.get("upgrade",false)
	if not special: return
	var fade := minf(clampf(t/0.2,0,1),clampf((reveal_duration()-banner_age)/0.45,0,1))
	var count := 16 if kind=="rainbow" else 8
	for i in count:
		var effect := "PLSS"
		var tint := Color("70dfff")
		if kind=="rainbow" or kind=="team":
			effect = ["BAL1","PLSS","MISL","BAL2"][i%4]
			tint = [Color("ff7b32"),Color("70dfff"),Color("ffcf80"),Color("8aff70")][i%4]
		elif announcement.get("ids",[]).size()>0:
			var type: String = card_data(announcement.ids[0]).type
			effect = {"FIRE":"BAL1","ENERGY":"PLSS","ROCKET":"MISL","BULLET":"PUFF","MELEE":"BAL2","WILD":"PLSS"}.get(type,"PLSS")
			tint = g.TYPE_COLORS.get(type,Color("ffe594"))
		var phase := i*TAU/count+t*3.4
		var position := Vector2(720+cos(phase)*560,410+sin(phase)*145)
		var direction := Vector2(-sin(phase)*560,cos(phase)*145).normalized()
		if kind=="team" or kind=="run":
			var travel := fposmod(t*0.7+i/float(count),1.0)
			position = Vector2(100+travel*1240,360+(i%3)*65+sin(travel*PI)*50)
			direction = Vector2(1,cos(travel*PI)*0.13).normalized()
		for tail in 5:
			var point := position-direction*(tail+1)*13
			g.draw_rect(Rect2(point-Vector2.ONE*3,Vector2.ONE*(6-tail*0.7)),Color(tint,fade*(1-tail/5.0)*0.65))
		var frames: Array = g.art.effect_textures.get(effect,[])
		if not frames.is_empty():
			var tex: Texture2D = frames[0 if effect=="MISL" else int(t*14+i)%mini(2,frames.size())]
			var size: Vector2 = tex.get_size()
			size *= 36.0/maxf(size.x,size.y)
			g.draw_set_transform(position,direction.angle() if effect=="MISL" else 0)
			g.draw_texture_rect(tex,Rect2(-size/2,size),false,Color(1,1,1,fade))
			g.draw_set_transform(Vector2.ZERO)
		else:
			g.draw_circle(position,9,Color(tint,fade*0.3))
			g.draw_rect(Rect2(position-Vector2(3,3),Vector2(6,6)),Color(tint,fade))
	# A final ring bursts outward as the cards return to their places.
	if t>1.5:
		var burst := (t-1.5)/0.8
		for i in 28:
			var angle := i*TAU/28
			var position := Vector2(720,430)+Vector2(cos(angle)*1.8,sin(angle))*(90+burst*220)
			g.draw_rect(Rect2(position,Vector2(5,5)),Color(1,0.65,0.2,fade*(1-clampf(burst,0,1))))


func choose_upgrade(index: int) -> void:
	if not round_over or finished or not upgrade_pending or index<0 or index>=upgrade_offers.size(): return
	var family: String = upgrade_offers[index]
	upgrades[0][family] = upgrades[0].get(family,0)+1
	var cpu_family: String = upgrade_offers[0]
	for candidate in upgrade_offers:
		if family_plays[1].get(candidate,0)>family_plays[1].get(cpu_family,0): cpu_family = candidate
	upgrades[1][cpu_family] = upgrades[1].get(cpu_family,0)+1
	upgrade_pending = false
	power_panel = false
	round_number += 1
	next_round()
	support.offer(self)

func draw_powers(g) -> void:
	g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.88))
	g.ui_help.reset()
	g.menu_frame(Rect2(120,80,1200,780))
	g.label_at(Vector2(160,137),"MATCH POWERS",32,g.ORANGE)
	g.label_at(Vector2(930,132),"ROUND %d / 5" % round_number,18,g.MUTED)
	if round_over and upgrade_pending:
		g.label_at(Vector2(200,310),"CHOOSE ONE HAND UPGRADE",25,g.INK)
		g.label_at(Vector2(200,360),"+5 points whenever you play this family. Stacks until this match ends.",18,g.INK)
		for i in upgrade_offers.size():
			g.button(Rect2(200+i*350,440,330,100),FAMILY_NAMES[upgrade_offers[i]])
		g.label_at(Vector2(200,610),"CPU chooses from the same offers. Card values in the centre stay unchanged.",17,g.MUTED)
	else:
		var bonus_rect := Rect2(160,165,1120,115)
		var bonus_style := card_style(false)
		bonus_style.bg_color = Color("34251a")
		bonus_style.border_color = Color("d38d46")
		g.draw_style_box(bonus_style,bonus_rect)
		var joker: int = passive_joker[0]
		var symbol := "+4" if joker==0 else ("+8" if joker==1 else "+10")
		g.label_at(Vector2(185,237),symbol,44,Color("ffd482"))
		if joker>=0:
			g.label_at(Vector2(325,203),PASSIVE_JOKERS[joker].name,23,g.ORANGE)
			g.label_at(Vector2(325,235),PASSIVE_JOKERS[joker].rule,20,g.INK)
		g.label_at(Vector2(325,260),"BOTH PLAYERS / AUTOMATIC / ALL MATCH",12,g.MUTED)
		g.ui_help.offer(bonus_rect,"SHARED MATCH BONUS","Both players earn the bonus whenever the condition is met. This is separate from your personal support Jokers.")
		for column in 2:
			var panel := Rect2(160+column*575,305,545,445)
			var style := card_style(false)
			style.bg_color = Color("14232b") if column==0 else Color("242139")
			style.border_color = Color("547b8b") if column==0 else Color("8a759e")
			g.draw_style_box(style,panel)
		g.label_at(Vector2(180,342),"ENHANCED THIS ROUND",20,Color("9de5ed"))
		g.label_at(Vector2(180,367),"Both players / every copy of these monsters",12,g.MUTED)
		var row := 0
		for id in enhancements:
			var x := 305+row*250
			var gilded: bool = enhancements[id]=="GILDED"
			var tint := Color("ffdc78") if gilded else Color("8de9fa")
			g.draw_circle(Vector2(x,505),100,Color(tint,0.04+sin(age*2)*0.01))
			draw_card(g,id,Vector2(x,507),Vector2(160,220))
			g.label_at(Vector2(x-90,650),enhancements[id]+(" / +4" if gilded else " / +8"),18,tint)
			g.label_at(Vector2(x-90,676),"WHEN PLAYED" if gilded else "WHEN EXTENDING",13,g.INK)
			g.ui_help.offer(Rect2(x-105,395,210,300),card_data(id).name,enhancements[id]+(": +4 whenever you play this monster." if gilded else ": +8 when you add this monster to the centre combo.")+" Applies to both players. Enhanced species change next round.")
			row += 1
		g.label_at(Vector2(180,726),"New enhanced monsters are chosen next round.",12,g.MUTED)
		g.label_at(Vector2(755,342),"ROUND POWERS",20,Color("d6b3f2"))
		if modifier>=0:
			g.label_at(Vector2(755,380),MODIFIERS[modifier].name+" / ACTIVE",18,g.ORANGE)
			g.label_at(Vector2(755,407),MODIFIERS[modifier].rule,14,g.INK)
		if relic>=0:
			g.label_at(Vector2(755,451),RELICS[relic].name,18,Color("9de5ed"))
			g.label_at(Vector2(755,478),RELICS[relic].rule+" / ONCE EACH PER ROUND",12,g.INK)
			for owner in 2: draw_relic_status(g,owner,Rect2(755+owner*250,492,230,32))
		g.label_at(Vector2(755,560),"YOUR COMBO UPGRADES / ALL MATCH",17,Color("d6b3f2"))
		var upgrade_row := 0
		for family in FAMILY_NAMES:
			var box := Rect2(755,576+upgrade_row*25,505,23)
			var amount := int(upgrades[0].get(family,0))*5
			g.draw_rect(box,Color("39304b") if amount>0 else Color("1c1d2b"))
			g.label_at(box.position+Vector2(10,17),FAMILY_NAMES[family],12,g.INK if amount>0 else g.MUTED)
			g.label_at(box.position+Vector2(440,17),"+%d" % amount,14,g.INK if amount>0 else g.MUTED)
			g.ui_help.offer(box,FAMILY_NAMES[family],FAMILY_HELP[family]+" Upgrade: +%d points." % amount)
			upgrade_row += 1
	g.button(Rect2(600,790,240,50),"BACK TO TABLE")

func start_round_intro() -> void:
	round_intro = match_powers
	round_intro_age = 0.0
	round_intro_beat = -1
	support.player_drawer_open = false

func draw_round_intro(g) -> void:
	g.ui_help.reset()
	g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.92))
	g.menu_frame(Rect2(100,75,1240,800))
	centered_at(g,"ROUND %d / POWER REVEAL" % round_number,Vector2(720,145),32,g.ORANGE)
	centered_at(g,"SHARED POWERS / BOTH PLAYERS",Vector2(720,184),16,g.MUTED)
	if round_intro_age>=6.6:
		draw_round_power_reveal(g)
		return
	var ids: Array = enhancements.keys()
	for i in 3:
		var elapsed := round_intro_age-i*2.2
		var x := 310+i*410
		if elapsed<0:
			g.draw_rect(Rect2(x-180,245,360,500),Color("111f25"))
			centered_at(g,"?",Vector2(x,495),64,g.MUTED)
			continue
		var enter := 1.0-pow(1.0-clampf(elapsed/0.65,0,1),3)
		var y := 245+(1-enter)*75
		var tint := Color("ffac58") if i==0 else (Color("ffdc78") if i==1 else Color("8de9fa"))
		var box := Rect2(x-180,y,360,500)
		g.draw_rect(box,Color("13232a"))
		g.draw_rect(box,tint,false,2)
		for ray in 12:
			var angle := ray*TAU/12+elapsed*0.15
			g.draw_line(Vector2(x,y+230)+Vector2.from_angle(angle)*80,Vector2(x,y+230)+Vector2.from_angle(angle)*150,Color(tint,0.18*enter),3)
		if i==0:
			var joker: int = passive_joker[0]
			centered_at(g,"MATCH BONUS",Vector2(x,y+45),22,tint)
			if joker>=0:
				centered_at(g,["+4","+8","+10"][joker],Vector2(x,y+245),64,tint)
				centered_at(g,PASSIVE_JOKERS[joker].name,Vector2(x,y+340),20,tint)
				centered_at(g,["PER FIRE CARD PLAYED","WHEN EXTENDING","WHEN PLAYING A NAMED TEAM"][joker],Vector2(x,y+390),14,g.INK)
			centered_at(g,"ACTIVE ALL MATCH",Vector2(x,y+455),14,g.MUTED)
		elif ids.size()>=i:
			var id: int = ids[i-1]
			centered_at(g,enhancements[id],Vector2(x,y+45),22,tint)
			draw_card(g,id,Vector2(x,y+225),Vector2(175,235)*maxf(0.1,enter))
			centered_at(g,"+4 WHEN PLAYED" if i==1 else "+8 WHEN EXTENDING",Vector2(x,y+390),19,tint)
			centered_at(g,"EVERY COPY / THIS ROUND",Vector2(x,y+455),14,g.MUTED)
		var sweep := clampf(elapsed/0.85,0,1)
		if sweep<1: g.draw_line(Vector2(x-175,y+500*sweep),Vector2(x+175,y+500*sweep),Color(tint,1-sweep),4)
	g.button(Rect2(1120,810,180,45),"SKIP / ENTER")
	centered_at(g,"REVEALING THIS ROUND'S POWERS",Vector2(650,820),16,g.MUTED)

func centered_at(g, text: String, position: Vector2, size: int, color: Color) -> void:
	g.label_at(position-Vector2(g.font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/2,0),text,size,color)

func relic_status(owner: int) -> String:
	if relic_used[owner]: return "USED"
	if relic==2 and not drew_this_round[owner]: return "DRAW TO READY"
	return "READY"

func draw_relic_status(g, owner: int, rect: Rect2) -> void:
	var status := relic_status(owner)
	var tint := Color("63706c") if status=="USED" else (Color("ffd482") if status=="DRAW TO READY" else Color("76e9d8"))
	var glow: float = 0.1 if status=="USED" else 0.3+sin(age*3)*0.12
	for ring in 3: g.draw_rect(rect.grow(ring*2),Color(tint,glow/(ring+2)),false,2)
	g.draw_rect(rect,Color("13232a"))
	g.label_at(rect.position+Vector2(7,rect.size.y*0.68),("YOU: " if owner==0 else "CPU: ")+status,11,tint)
	g.ui_help.offer(rect,RELICS[relic].name,RELICS[relic].rule+". Once per player each round. "+status)

func draw_round_power_reveal(g) -> void:
	for i in 2:
		var elapsed: float = round_intro_age-6.6-i*2.2
		var x: float = 410+i*620
		var box := Rect2(x-270,245,540,500)
		var tint := Color("ffb15d") if i==0 else Color("76e9d8")
		g.draw_rect(box,Color("13232a"))
		if elapsed<0:
			centered_at(g,"?",Vector2(x,500),64,g.MUTED)
			continue
		var enter := smoothstep(0,0.65,elapsed)
		g.draw_rect(box,Color(tint,enter),false,3)
		for ring in 4: g.draw_arc(Vector2(x,440),60+ring*18+sin(age*2)*5,age*0.4,age*0.4+TAU*0.8,48,Color(tint,0.15),2)
		centered_at(g,"ROUND MODIFIER" if i==0 else "ROUND RELIC",Vector2(x,295),23,tint)
		var index: int = modifier if i==0 else relic
		if index>=0:
			var data: Dictionary = MODIFIERS[index] if i==0 else RELICS[index]
			centered_at(g,["+5","+8","+10"][index] if i==0 else ["+15","+12","+10"][index],Vector2(x,465),60,tint)
			centered_at(g,data.name,Vector2(x,570),25,tint)
			centered_at(g,data.rule,Vector2(x,610),16,g.INK)
			if i==1:
				for owner in 2: draw_relic_status(g,owner,Rect2(x-245+owner*250,635,235,35))
		centered_at(g,"ACTIVE ALL ROUND" if i==0 else "ONCE PER PLAYER / RESETS NEXT ROUND",Vector2(x,710),14,g.MUTED)
	g.button(Rect2(1120,810,180,45),"SKIP / ENTER")
	centered_at(g,"ROUND BONUS + RELIC / BOTH PLAYERS",Vector2(650,820),16,g.MUTED)
