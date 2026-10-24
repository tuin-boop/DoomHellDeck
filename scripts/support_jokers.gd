extends RefCounted
# Stable IDs also name optional assets/jokers/<id>.png illustrations.
const DATA := [
	["joker_imp","JOKER IMP","+5 points on every scoring play."],
	["vampire_imp","VAMPIRE IMP","After scoring, drain one played monster species' enhancement for your side this round. Gain +3 on future plays per drain, for this match."],
	["cowboy_doomguy","COWBOY DOOMGUY","+4 per Bullet monster you play."],
	["lucky_imp","LUCKY IMP","25% chance of +20 on each scoring play."],
	["greedy_pinky","GREEDY JOKER","+6 extra per Gilded monster you play."],
	["professor_revenant","PROFESSOR REVENANT","Every third March you play upgrades your March bonus by +5 for this match."],
	["magician_arch_vile","MAGICIAN ARCH-VILE","+15 when you play John Romero in a valid combination."],
	["pirate_cacodemon","PIRATE CACODEMON","Add cards to a centre combo originally started by your opponent to earn +12 extra points. Automatic; no activation needed."],
	["sleepy_mancubus","SLEEPY MANCUBUS","Each draw/pass stores +4, up to +16. Your next scoring play collects it."],
	["king_cyberdemon","KING CYBERDEMON","+10 if a Cyberdemon remains in your hand after playing. Once per play."],
	["disco_revenant","DISCO REVENANT","Repeat the leftmost played card's enhancement: Gilded +4, or Charged +8 on extension."],
	["chef_mancubus","CHEF MANCUBUS","Each Fire monster played adds +1 to future Fire-play bonuses, up to +20, for this match."],
	["mime_spectre","MIME DOOMGUY","Copy the previous slot's fixed scoring bonus. Cannot copy Mime, chance, stored growth, multipliers or extra actions. Swap your slots by clicking them."],
	["boxer_pinky","BOXER PINKY","+12 when you add exactly two cards in a valid play."],
	["general_baron","GENERAL BARON","+15 when you play or extend a named team."],
	["astronaut_lost_soul","ASTRONAUT LOST SOUL","+20 when you play or extend Apocalypse."],
	["electric_arachnotron","ELECTRIC ARACHNOTRON","+5 per Charged monster played, including when starting a combination."],
	["berserker_doomguy","BERSERKER DOOMGUY","Multiply your tenth-turn scoring play by 1.5, rounding down. Draw/pass gets no bonus."],
	["clown_pain_elemental","CLOWN PAIN ELEMENTAL","Your first draw/pass each round draws two monsters instead of one, if available."],
	["rockstar_imp","ROCKSTAR IMP","+10 when your combo family differs from your previous scoring play this round. No bonus on your first play."],
	["uac_coffee", "UAC COFFEE", "Your first scoring play each round gains +10."],
	["blue_keycard", "BLUE KEYCARD", "+10 when you extend the centre combo by playing exactly one card."],
	["explosive_barrel", "EXPLOSIVE BARREL", "Every third scoring play while held adds +25. Progress lasts this match."],
	["demon_contract", "DEMON CONTRACT", "Pay 20 points each round while held, including the round acquired. Gain +6 per scoring play."],
	["glitch_disk", "GLITCH DISK", "Your first new matching-monster pair each round gains +20: the base-score difference to three of a kind. Does not add a card."],
	["ammo_box", "AMMO BOX", "+2 points for each card you add to a valid combo."],
	["gluttonous_joker", "GLUTTONOUS JOKER", "Playing 4 or more cards grows this Joker by +3 for future scoring plays, up to +24 for the match."],
	["valentine_joker", "VALENTINE JOKER", "+6 for each matching monster pair among the cards you play. Three identical monsters count as one pair, four as two. Romero does not form a pair."],
	["clown_doomguy","CLOWN DOOMGUY","+12 when you play exactly three cards with three different damage types."],
	["business_zombieman","BUSINESS ZOMBIEMAN","+2 per card left in your hand after playing, capped at +10 per scoring play."],
	["banjo_zombieman","BANJO ZOMBIEMAN","+10 when you play or extend a March."],
	["party_mastermind","PARTY MASTERMIND","+12 when you play four or more cards in one valid play."],
	["propeller_ss_soldier","PROPELLER SS SOLDIER","+8 when your combo family matches the most recent scoring play by either player this round. No bonus before the round's first scoring play."],
	["john_carmack","JOHN CARMACK","Optimization: +10 when a scoring play leaves your hand empty."],
	["commander_keen","COMMANDER KEEN","Comeback: +4 on a scoring play if your round score is lower than your opponent's before playing."],
	["bloody_smiley","BLOODY SMILEY","Keep smiling: +6 on a scoring play if you lead the round before playing."],
	["the_two_johns","THE TWO JOHNS","Romero & Carmack: +10 when you play exactly two different monsters in a valid play. The Romero wild card does not count as a monster."],
	["doom_guy_book","DOOM GUY: THE BOOK","New chapter: +6 the first time you score each combo family while holding this Joker each round."],
	["daikatana_romero","DAIKATANA ROMERO","Swordplay: +4 for each Melee monster you play. The Romero wild card does not count."],
	["jester_imp","JESTER IMP","Common: +4 when you start a new combination. No bonus for extensions."],
	["glitch_jester_imp","GLITCH JESTER IMP","+10 every second scoring play while held. Progress resets each round."],
	["screaming_doomguy","SCREAMING DOOMGUY","Last scream: +20 on your tenth-turn scoring play each round. Draw/pass gets no bonus."],
	["bj_blazkowicz","B.J. BLAZKOWICZ","Castle Breakout: +15 when you extend a combo started by your opponent with at least one Bullet or Melee monster."]
]
# Decorative themes only; colours do not encode rarity or scoring rules.
const THEMES := [
	["302044","c791ed","diamonds"], # Jester velvet
	["390f23","ea4966","diamonds"], # Vampire brocade
	["3c291b","e1b46b","stars"], # Cowboy leather
	["143c29","7bdb8c","diamonds"], # Lucky emerald
	["423417","edc957","rings"], # Greedy gold
	["182b48","9fbeeb","grid"], # Professor notebook
	["301943","cf9df0","stars"], # Magician midnight
	["163b40","6fc4c1","waves"], # Pirate sea
	["242b52","a2b9fa","stars"], # Sleepy night sky
	["3b203d","dfb96d","rays"], # Royal purple
	["421b4a","f18bde","grid"], # Disco dance floor
	["3d2925","e6a88f","checks"], # Chef gingham
	["282a30","bfc7d2","stripes"], # Mime monochrome
	["451f21","f08a77","stripes"], # Boxing ring
	["2d3723","c0c788","chevrons"], # General olive
	["16213f","8abde9","stars"], # Astronaut space
	["123b3c","69e5d7","grid"], # Electric circuitry
	["431b16","ef7756","chevrons"], # Berserker fire
	["403019","f4ce7a","diamonds"], # Clown carnival
	["291d3c","c791ec","rays"],
	["3e2f25","e4c69b","waves"], ["142b51","73afff","grid"],
	["293c20","afdf60","chevrons"], ["3d1720","ea9274","diamonds"],
	["291738","ee70e0","grid"], ["293426","a9bc7c","checks"],
	["432c16","f3b45e","rings"], ["481e34","f49abb","hearts"], ["442118","f5ad66","diamonds"], ["172d32","9abca6","stripes"], ["3b2318","e5b875","checks"], ["352045","e5a5ef","stars"], ["182b48","86bdf1","rings"], ["132b3e","68cbed","grid"], ["302043","f0d16f","stars"], ["493719","ffda52","rings"], ["252b34","ced9ee","grid"], ["472217","f2ad52","stripes"], ["252d32","b6d5df","chevrons"], ["183e36","cbdc66","diamonds"], ["271a3d","5ee8ed","grid"], # Glitch circuitry
	["421b18","ff8263","rays"],
	["44241c","e8c18c","chevrons"]
]

func draw_card_background(g, m, id: int, bounds: Rect2, active: bool) -> void:
	var theme: Array = THEMES[id]
	var accent := Color(theme[1])
	var style: StyleBoxFlat = m.card_style(active)
	style.bg_color = Color(theme[0]).lightened(0.08 if active else 0.0)
	if not active: style.border_color = accent.darkened(0.2)
	g.draw_style_box(style,bounds)
	# Keep every motif inside the frame and away from the title/footer.
	var area := Rect2(bounds.position+Vector2(20,49),bounds.size-Vector2(40,80))
	var ink := Color(accent,0.14)
	for row in 7:
		for col in 5:
			var point := area.position+Vector2((col+0.5)*area.size.x/5,(row+0.5)*area.size.y/7)
			var r := minf(area.size.x/13,area.size.y/20)
			match theme[2]:
				"hearts":
					g.draw_circle(point+Vector2(-r*0.4,-r*0.3),r*0.55,ink)
					g.draw_circle(point+Vector2(r*0.4,-r*0.3),r*0.55,ink)
					g.draw_colored_polygon(PackedVector2Array([point+Vector2(-r*0.9,0),point+Vector2(r*0.9,0),point+Vector2(0,r)]),ink)
				"diamonds": g.draw_colored_polygon(PackedVector2Array([point+Vector2(0,-r),point+Vector2(r,0),point+Vector2(0,r),point+Vector2(-r,0)]),ink)
				"stars":
					g.draw_line(point-Vector2(r,0),point+Vector2(r,0),ink,1)
					g.draw_line(point-Vector2(0,r),point+Vector2(0,r),ink,1)
				"rings": g.draw_arc(point,r,0,TAU,12,ink,1)
				"checks":
					if (row+col)%2==0: g.draw_rect(Rect2(point-Vector2.ONE*r,Vector2.ONE*r*2),ink)
				"chevrons": g.draw_polyline(PackedVector2Array([point+Vector2(-r,-r/2),point+Vector2(0,r/2),point+Vector2(r,-r/2)]),ink,1)
				"waves": g.draw_arc(point,r,0,PI,8,ink,1)
				"grid": g.draw_rect(Rect2(point-Vector2.ONE*r,Vector2.ONE*r*2),ink,false,1)
				"stripes": g.draw_line(point-Vector2(r,r),point+Vector2(r,r),ink,2)
				"rays":
					var direction := (point-area.get_center()).normalized()
					g.draw_line(point-direction*r,point+direction*r,ink,1)

var last_table_family := ""
var slots := [[],[]]
var stats := [{},{}]
var drained := [{},{}]
var reminder_age := 0.0
const REMINDER_TIME := 4.5
var player_drawer_open := false
var pending := false
var offers: Array = []
var chosen := -1
var swap_slot := -1
var guide_links: Array = []
var library := false
var page := 0
var art := {}
var pulses := [{},{}]
var drawer := [0.0,0.0]
var drawer_grace := [0.0,0.0]

func reset() -> void:
	player_drawer_open = false
	last_table_family = ""
	slots = [[],[]]
	stats = [{},{}]
	drained = [{},{}]
	pulses = [{},{}]
	drawer = [0.0,0.0]
	drawer_grace = [0.0,0.0]
	library = false
	pending = false
	swap_slot = -1

func has(owner: int, id: int) -> bool:
	return slots[owner].has(id)

func begin_round() -> void:
	reminder_age = 0.0
	last_table_family = ""
	drained = [{},{}]
	for s in stats:
		s.sleep = 0
		s.drawn = false
		s.last = ""
		s.coffee_used = false
		s.glitch_used = false
		s.contract_paid = false
		s.book_families = []
		s.glitch_plays = 0

var draft_age := 0.0
const RARE := [6,12,15,17,18,24,36,40]
const UNCOMMON := [1,5,7,9,10,11,14,16,19,21,22,23,26,27,28,31,32,33,41,42]
func rarity(id: int) -> String:
	return "RARE" if id in RARE else ("UNCOMMON" if id in UNCOMMON else "COMMON")
func rarity_weight(id: int) -> int:
	return 1 if id in RARE else (4 if id in UNCOMMON else 8)
func rarity_color(id: int) -> Color:
	return Color("e99aff") if id in RARE else (Color("72d8ff") if id in UNCOMMON else Color("d0c5a8"))
const MAX_SLOTS := 5
const STARTER_POOL := [0,2,3,8,13,20,25,29,30,37,38,39]

func draft_offers(m, owner: int) -> Array:
	var candidates: Array = []
	for id in DATA.size():
		if not slots[owner].has(id) and (not slots[owner].is_empty() or id in STARTER_POOL): candidates.append(id)
	var choices: Array = []
	for i in 3:
		var total := 0
		for id in candidates: total += rarity_weight(id)
		var roll: int = m.random.randi_range(1,total)
		for index in candidates.size():
			roll -= rarity_weight(candidates[index])
			if roll<=0:
				choices.append(candidates.pop_at(index))
				break
	return choices

func auto_pick(m, owner: int, choices: Array) -> int:
	var best: int = choices[0]
	var value := -1.0
	for id in choices:
		var weight: float = m.random.randf()*4+5
		if id in [2,11,38]:
			for card in m.hands[owner]:
				if m.card_data(card).type==({2:"BULLET",11:"FIRE",38:"MELEE"}[id]): weight += 2
		if id==12 and slots[owner].is_empty(): weight = 0
		if weight>value: best = id; value = weight
	return best

func offer(m) -> void:
	if slots[0].size()>=mini(MAX_SLOTS,m.round_number): return
	draft_age = 0.0
	offers = draft_offers(m,0)
	chosen = -1
	pending = true
	swap_slot = -1

func finish_pick(m) -> void:
	if not pending or not offers.has(chosen) or slots[0].size()>=mini(MAX_SLOTS,m.round_number): return
	slots[0].append(chosen)
	if slots[1].size()<mini(MAX_SLOTS,m.round_number):
		slots[1].append(auto_pick(m,1,draft_offers(m,1)))
	pending = false
	chosen = -1
	apply_contract(m)
	m.hint_signature = ""
	m.start_round_intro()

func apply_contract(m) -> void:
	for owner in 2:
		if has(owner,23) and not stats[owner].get("contract_paid",false):
			m.round_scores[owner] -= 20
			stats[owner].contract_paid = true

func enhancement(m, owner: int, id: int) -> String:
	return "" if drained[owner].has(id) else str(m.enhancements.get(id,""))

func fixed_bonus(id: int, c: Dictionary) -> int:
	match id:
		42: return 15 if c.get("rival",false) and (c.get("bullet",0)>0 or c.get("melee",0)>0) else 0
		41: return 20 if c.get("final_turn",false) else 0
		0: return 5
		6: return 15 if c.get("romero",false) else 0
		21: return 10 if c.get("extension",false) and c.count==1 else 0
		2: return c.bullet*4
		4: return c.gilded*6
		7: return 12 if c.rival else 0
		9: return 10 if c.king else 0
		10: return c.echo
		13: return 12 if c.count==2 else 0
		14: return 15 if c.kind=="team" else 0
		15: return 20 if c.kind=="rainbow" else 0
		16: return c.charged*5
		19: return 10 if c.changed else 0
		23: return 6
		25: return c.count*2
		39: return 0 if c.get("extension",false) else 4
		38: return c.get("melee",0)*4
		36: return 10 if c.count==2 and c.get("distinct",0)==2 else 0
		35: return 6 if c.get("ahead",false) else 0
		34: return 4 if c.get("behind",false) else 0
		33: return 10 if c.get("remaining",-1)==0 else 0
		32: return 8 if c.get("repeated",false) else 0
		30: return 10 if c.kind=="run" else 0
		31: return 12 if c.count>=4 else 0
		29: return mini(10,c.get("remaining",0)*2)
		28: return 12 if c.count==3 and c.get("types",0)==3 else 0
		27: return c.get("pairs",0)*6
	return 0

func score(m, owner: int, ids: Array, combo: Dictionary, extension: bool, commit := false) -> Dictionary:
	var s: Dictionary = stats[owner]
	var context := {"bullet":0,"fire":0,"gilded":0,"charged":0,"echo":0,"count":ids.size(),"kind":combo.kind,"rival":extension and not m.melds.is_empty() and m.melds[0].get("starter",owner)!=owner,"king":m.hands[owner].count(8)>ids.count(8),"changed":s.get("last","")!="" and s.get("last","")!=combo.kind}
	context.final_turn = m.turns[owner]==9
	context.ahead = m.round_scores[owner]>m.round_scores[1-owner]
	context.behind = m.round_scores[owner]<m.round_scores[1-owner]
	context.repeated = last_table_family!="" and last_table_family==combo.kind
	context.remaining = maxi(0,m.hands[owner].size()-ids.size())
	context.romero = ids.has(-1)
	context.extension = extension
	context.pairs = 0
	var pair_counts := {}
	for monster in ids:
		if monster>=0: pair_counts[monster] = int(pair_counts.get(monster,0))+1
	context.melee = 0
	for monster in ids:
		if monster>=0 and m.card_data(monster).type=="MELEE": context.melee += 1
	context.distinct = pair_counts.size()
	for count in pair_counts.values(): context.pairs += int(count/2)
	var played_types := {}
	for monster in ids: played_types[m.card_data(monster).type] = true
	context.types = played_types.size()
	var drain_id := -1
	for i in ids.size():
		var id: int = ids[i]
		var type: String = m.card_data(id).type
		if type=="BULLET": context.bullet += 1
		if type=="FIRE": context.fire += 1
		var e := enhancement(m,owner,id)
		if e=="GILDED": context.gilded += 1
		if e=="CHARGED": context.charged += 1
		if e!="" and drain_id<0: drain_id = id
		if i==0: context.echo = 4 if e=="GILDED" else (8 if e=="CHARGED" and extension else 0)
	var total: int = combo.gain
	var events: Array = []
	for slot in slots[owner].size():
		var id: int = slots[owner][slot]
		var bonus := fixed_bonus(id,context)
		if id==40: bonus = 10 if (int(s.get("glitch_plays",0))+1)%2==0 else 0
		if id==37: bonus = 0 if combo.kind in s.get("book_families",[]) else 6
		if id==26: bonus = s.get("gluttonous",0)
		if id==20: bonus = 0 if s.get("coffee_used",false) else 10
		if id==22: bonus = 25 if (int(s.get("barrel",0))+1)%3==0 else 0
		if id==24: bonus = 20 if not s.get("glitch_used",false) and not extension and combo.kind=="set" and ids.size()==2 else 0
		if id==1: bonus = s.get("vampire",0)
		if id==3: bonus = (20 if m.random.randf()<0.25 else 0) if commit else 5
		if id==8: bonus = s.get("sleep",0)
		if id==11 and context.fire>0: bonus = s.get("chef",0)
		if id==12 and slot>0: bonus = fixed_bonus(slots[owner][slot-1],context)
		if bonus>0: total += bonus; events.append({"id":id,"text":"+%d" % bonus,"amount":bonus,"total":total})
	# Multipliers resolve after all additions, independent of slot order.
	if has(owner,17) and m.turns[owner]==9:
		var before := total
		total = int(floor(total*1.5)); events.append({"id":17,"text":"x1.5 / +%d" % (total-before),"amount":total-before,"total":total})
	if commit:
		if has(owner,40): s.glitch_plays = int(s.get("glitch_plays",0))+1
		if has(owner,37):
			if not s.has("book_families"): s.book_families = []
			if not combo.kind in s.book_families: s.book_families.append(combo.kind)
		if has(owner,26) and ids.size()>=4:
			s.gluttonous = mini(24,int(s.get("gluttonous",0))+3)
			events.append({"id":26,"text":"FUTURE BONUS +%d" % s.gluttonous,"total":total,"amount":0})
		if has(owner,20): s.coffee_used = true
		if has(owner,22): s.barrel = int(s.get("barrel",0))+1
		if has(owner,24) and not extension and combo.kind=="set" and ids.size()==2: s.glitch_used = true
		if has(owner,1) and drain_id>=0:
			drained[owner][drain_id] = true
			s.vampire = s.get("vampire",0)+3
			events.append({"id":1,"text":"FUTURE BONUS GROWS +3","total":total,"amount":0})
		if has(owner,11) and context.fire>0:
			s.chef = mini(20,s.get("chef",0)+context.fire)
			events.append({"id":11,"text":"FUTURE FIRE BONUS +%d" % s.chef,"total":total,"amount":0})
		if has(owner,5) and combo.kind=="run":
			s.marches = s.get("marches",0)+1
			if s.marches%3==0:
				m.upgrades[owner]["run"] = m.upgrades[owner].get("run",0)+1
				events.append({"id":5,"text":"FUTURE MARCHES +5","total":total,"amount":0})
		if has(owner,8): s.sleep = 0
		s.last = combo.kind
		last_table_family = combo.kind
		for event in events: pulses[owner][event.id] = m.age
	return {"gain":total,"events":events,"bonus":total-int(combo.gain)}

func on_draw(owner: int) -> int:
	var s: Dictionary = stats[owner]
	var count := 2 if has(owner,18) and not s.get("drawn",false) else 1
	s.drawn = true
	if has(owner,8): s.sleep = mini(16,s.get("sleep",0)+4)
	return count

func progress(owner: int, id: int) -> String:
	if id==39: return "COMMON"
	if id==40: return "%d / 2 PLAYS" % (int(stats[owner].get("glitch_plays",0))%2)
	var s: Dictionary = stats[owner]
	match id:
		26: return "APPETITE +%d" % s.get("gluttonous",0)
		20: return "USED" if s.get("coffee_used",false) else "FIRST +10"
		22: return "CHARGE %d/3" % (int(s.get("barrel",0))%3)
		24: return "USED" if s.get("glitch_used",false) else "PAIR +20"
		1: return "GROWTH +%d" % s.get("vampire",0)
		5: return "MARCHES %d/3" % (s.get("marches",0)%3)
		8: return "STORED +%d" % s.get("sleep",0)
		11: return "HEAT +%d" % s.get("chef",0)
		18: return "DRAW USED" if s.get("drawn",false) else "DOUBLE DRAW"
	return "PASSIVE"

func portrait_pose(id: int, time: float, width: float) -> Transform2D:
	if id!=41: return Transform2D.IDENTITY
	var offset := Vector2(sin(time*57.0)+sin(time*83.0)*0.45,cos(time*67.0)*0.65)*width*0.018
	return Transform2D(sin(time*49.0)*0.045,offset)

func card(g, m, id: int, rect: Rect2, owner := -1, interactive := true) -> void:
	var mouse: Vector2 = g.get_global_mouse_position()
	var local: Vector2 = (mouse-rect.get_center())/rect.size
	var hover := interactive and rect.has_point(mouse)
	var pulse := 0.0
	if owner>=0: pulse = maxf(0,1-(m.age-float(pulses[owner].get(id,-99)))/0.8)
	var center := rect.get_center()+Vector2(local.x*7 if hover else 0,0)
	# Signed side lean reverses across the centre; no mouse-height tilt.
	var card_transform := preload("res://scripts/card_tilt.gd").pose(center,local.x,hover)
	g.draw_set_transform_matrix(card_transform)
	var bounds := Rect2(-rect.size/2,rect.size)
	for depth in range(5,0,-1):
		g.draw_style_box(m.card_style(false),Rect2(bounds.position+Vector2(depth*(-signf(local.x) if hover and absf(local.x)>0.05 else 1.0),depth*1.5),bounds.size))
	draw_card_background(g,m,id,bounds,hover or pulse>0)
	var time: float = g.clock
	var tint := Color.from_hsv(fposmod(id*0.137,1.0),0.65,1.0)
	if id==0: tint = Color.from_hsv(fposmod(time*0.12,1),0.7,1)
	elif id==1: tint = Color("fa334f")
	elif id==2: tint = Color("ffbf62")
	elif id==3: tint = Color("64ec68")
	elif id==4: tint = Color("ffd34f")
	var glow_strength: float = 0.055+sin(time*2+id)*0.015+(0.035 if hover else 0)+pulse*0.09
	# Soft halo behind the portrait; no flashing or full-screen lighting.
	for ring in range(5,0,-1):
		g.draw_circle(Vector2.ZERO,rect.size.x*(0.23+ring*0.027),Color(tint,glow_strength/2))
	for spark in 7:
		var angle: float = time*0.5+spark*TAU/7+id
		var point := Vector2(cos(angle)*rect.size.x*0.34,sin(angle)*rect.size.y*0.28)
		var brightness: float = 0.2+0.3*maxf(0,sin(time*2.5+spark))
		g.draw_rect(Rect2(point,Vector2.ONE*(2 if rect.size.x<100 else 3)),Color(tint,brightness))
	var path: String = "res://assets/jokers/"+DATA[id][0]+".png"
	if id==25 and not art.has(id) and not g.art.textures.get("AMMO",[]).is_empty(): art[id] = g.art.textures["AMMO"][0]
	if not art.has(id): art[id] = load(path) if ResourceLoader.exists(path) else null
	if art[id]!=null:
		var tex: Texture2D = art[id]
		var size := tex.get_size()
		size *= minf((rect.size.x*0.76)/size.x,(rect.size.y-48)/size.y)
		g.draw_set_transform_matrix(card_transform*portrait_pose(id,time,rect.size.x))
		g.draw_texture_rect(tex,Rect2(-size/2,size),false)
		g.draw_set_transform_matrix(card_transform)
	else:
		g.draw_circle(Vector2.ZERO,rect.size.x*0.22,Color.from_hsv(id/20.0,0.5,0.45))
		g.label_at(Vector2(-16,8),"%02d" % (id+1),20,g.INK)
		g.label_at(Vector2(-rect.size.x/2+7,27),"ART PENDING",9,g.MUTED)
	if id==4:
		# Coins flip about their vertical axes as they orbit the portrait.
		for coin in 5:
			var phase: float = time*0.9+coin*TAU/5
			var p := Vector2(cos(phase)*rect.size.x*0.28,sin(phase)*rect.size.y*0.23)
			var radius: float = maxf(3,rect.size.x*0.035)
			var width: float = maxf(1,radius*absf(cos(time*3+coin)))
			g.draw_set_transform_matrix(card_transform*Transform2D(0,Vector2(width/radius,1),0,p))
			g.draw_circle(Vector2.ZERO,radius,Color("ad6818"))
			g.draw_circle(Vector2(-0.5,-0.5),radius*0.75,Color("ffd65a"))
			g.draw_line(Vector2(0,-radius*0.45),Vector2(0,radius*0.45),Color("fff2a0"),1)
		g.draw_set_transform_matrix(card_transform)
	elif id==1:
		# Small pixel blood drops descend beside the face, within the card.
		for drop in 6:
			var phase: float = fposmod(time*0.35+drop*0.173,1)
			var p := Vector2((-1 if drop%2==0 else 1)*rect.size.x*(0.19+(drop%3)*0.04),rect.size.y*(-0.05+phase*0.36))
			var radius: float = maxf(1.5,rect.size.x*0.012)
			var blood := Color(0.8,0.025,0.07,sin(phase*PI)*0.9)
			g.draw_rect(Rect2(p-Vector2(radius*0.4,radius*2.5),Vector2(radius*0.8,radius*2.5)),blood)
			g.draw_circle(p,radius,blood)
	var font_size := 20 if rect.size.x>=200 else 13
	var lines: Array[String] = [str(DATA[id][1])]
	if g.font.get_string_size(lines[0],HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.x-18:
		var words := lines[0].split(" ")
		lines = [words[0]," ".join(words.slice(1))]
		while font_size>9 and maxf(g.font.get_string_size(lines[0],HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x,g.font.get_string_size(lines[1],HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)>rect.size.x-18: font_size -= 1
	for row in lines.size():
		g.label_at(bounds.position+Vector2(9,17+row*(font_size+2)),lines[row],font_size,g.INK)
	if owner<0: g.label_at(Vector2(-rect.size.x/2+6,rect.size.y/2-8),rarity(id),9,rarity_color(id))
	if id==40:
		for strip in 3:
			var phase: float = g.clock*2.0+strip*1.7
			var y: float = -rect.size.y*0.3+fposmod(phase*18.0,rect.size.y*0.6)
			var x: float = sin(phase*3.0)*rect.size.x*0.22
			g.draw_rect(Rect2(Vector2(x,y),Vector2(15,2)),Color(0.2,1.0,1.0,0.55))
			g.draw_rect(Rect2(Vector2(x+8,y+3),Vector2(10,2)),Color(1.0,0.1,0.7,0.45))
	if owner>=0: g.label_at(Vector2(-rect.size.x/2+6,rect.size.y/2-8),progress(owner,id),9,g.ORANGE)
	var side_font := maxi(9,roundi(rect.size.x*0.075))
	for opposite in 2:
		g.draw_set_transform_matrix(card_transform*Transform2D(PI if opposite==1 else 0.0,Vector2.ZERO))
		for letter in 5:
			g.label_at(Vector2(-rect.size.x/2+7,-rect.size.y/2+51+letter*(side_font+1)),"JOKER"[letter],side_font,Color("e49d61"))
	g.draw_set_transform_matrix(card_transform)
	# A brief, staggered border shimmer every 18-28 seconds per card.
	var cycle: float = fposmod(time+id*4.73,18.0+id%11)
	if cycle<1.6 or pulse>0:
		var shimmer: float = maxf(pulse,sin(cycle/1.6*PI))
		g.draw_rect(bounds.grow(-3),Color(tint,shimmer*0.65),false,2)
		for sparkle in 4:
			var x: float = -rect.size.x/2+6+fposmod(cycle*100+sparkle*rect.size.x/4,rect.size.x-12)
			g.draw_line(Vector2(x-3,-rect.size.y/2+4),Vector2(x+3,-rect.size.y/2+4),Color(tint,shimmer),2)
	if hover:
		var sheen_x := local.x*rect.size.x*0.7
		g.draw_rect(Rect2(sheen_x-rect.size.x*0.07,-rect.size.y/2+23,rect.size.x*0.14,rect.size.y-46),Color(1,1,1,0.06))
		g.draw_line(bounds.position+Vector2(5,3),bounds.position+Vector2(rect.size.x-5,3),Color(1,1,1,0.8),3)
	g.draw_set_transform(Vector2.ZERO)
	if interactive and "named team" in DATA[id][2].to_lower():
		var link := Rect2(rect.position+Vector2(7,rect.size.y-25),Vector2(rect.size.x-14,22))
		g.draw_rect(link,Color("13272c"))
		g.label_at(link.position+Vector2(4,15),"NAMED TEAMS >",10,Color("ffd482"))
		g.draw_line(link.position+Vector2(4,18),link.position+Vector2(link.size.x-4,18),Color("dca850"),1)
		guide_links.append(link)
	if interactive: g.ui_help.offer(rect,DATA[id][1],DATA[id][2]+(" Current: "+progress(owner,id) if owner>=0 and progress(owner,id)!="PASSIVE" else ""))

func draw(g,m) -> void:
	guide_links.clear()
	if not pending and not library:
		for owner in 2:
			var panel := drawer_rect(owner)
			var tab := drawer_tab(owner)
			if drawer[owner]>0.01: g.draw_style_box(m.card_style(false),panel)
			var title := "YOUR" if owner==0 else "CPU"
			if owner==1:
				g.draw_style_box(m.card_style(drawer[owner]>0.1),tab)
				g.label_at(tab.position+Vector2(12,25),title+" JOKERS / "+str(slots[owner].size()),17,g.ORANGE)
				g.ui_help.offer(tab,"CPU JOKERS","Hover to inspect CPU Jokers.")
			if drawer[owner]>0.01:
				g.label_at(panel.position+Vector2(12,25),title+" / JOKERS",13,g.ORANGE)
				for i in slots[owner].size(): card(g,m,slots[owner][i],slot_rect(owner,i),owner)
				if slots[owner].is_empty(): g.label_at(panel.position+Vector2(12,70),"NO JOKERS",12,g.MUTED)
		if g.joker_reminders and m.banner_age>=m.reveal_duration() and not m.round_intro and not m.round_over and m.draw_flights.is_empty() and reminder_age<REMINDER_TIME: draw_reminder(g,m)
		if swap_slot>=0 and drawer[0]>0.01:
			g.draw_rect(slot_rect(0,swap_slot),g.ORANGE,false,3)
			g.ui_help.offer(slot_rect(0,swap_slot),"SWAP JOKERS","Click another of your Joker slots to swap positions. Mime copies its previous slot (to its left).")
	g.button(Rect2(1140,185,230,35),"JOKER COLLECTION")
	if not pending and not library: return
	g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.94))
	g.ui_help.reset()
	g.menu_frame(Rect2(110,65,1220,820))
	g.label_at(Vector2(155,120),"CHOOSE A SUPPORT JOKER" if pending else "JOKER COLLECTION / %d TYPES" % DATA.size(),28,g.ORANGE)
	g.label_at(Vector2(155,160),"One Joker each round. Build up to five. Effects last this match. Hover for rules.",17,g.INK)
	if pending:
		for i in offers.size():
			if draft_age<i*0.65+1.0:
				var box := Rect2(260+i*335,200,230,335)
				g.draw_rect(box,Color("202c30"))
				g.draw_rect(box,rarity_color(offers[i]),false,3)
				for stripe in 6: g.draw_line(box.position+Vector2(10,30+stripe*52),box.position+Vector2(220,30+stripe*52),Color("586261"),4)
				g.label_at(box.position+Vector2(55,160),"UAC",40,g.INK)
				g.label_at(box.position+Vector2(38,215),rarity(offers[i]),18,rarity_color(offers[i]))
			else:
				card(g,m,offers[i],Rect2(260+i*335,200,230,335))
				var burst := clampf(1-(draft_age-i*0.65-1)/0.6,0,1)
				g.draw_rect(Rect2(260+i*335,200,230,335),Color(rarity_color(offers[i]),burst*0.35))
			if chosen==offers[i]: g.draw_rect(Rect2(260+i*335,200,230,335),g.ORANGE,false,4)
		g.label_at(Vector2(170,580),"ROUND %d / CHOOSE JOKER %d OF 5" % [m.round_number,slots[0].size()+1],17,g.INK)
		for i in slots[0].size(): card(g,m,slots[0][i],Rect2(270+i*180,610,105,150),0)
		g.label_at(Vector2(420,825),"CHOOSE A JOKER TO CONTINUE",20,g.ORANGE)
	else:
		for i in 10:
			var id := page*10+i
			if id>=DATA.size(): break
			card(g,m,id,Rect2(165+(i%5)*230,190+(i/5)*290,185,270))
		g.button(Rect2(180,800,250,50),"PREVIOUS")
		g.button(Rect2(595,800,250,50),"CLOSE")
		g.button(Rect2(1010,800,250,50),"NEXT")

func set_player_drawer(g, opened: bool) -> void:
	if player_drawer_open==opened: return
	player_drawer_open = opened
	if opened: reminder_age = REMINDER_TIME
	g.audio.play("DSBDOPN" if opened else "DSBDCLS",-16)

func handle(g,m,event: InputEvent) -> bool:
	if not pending and not library and event is InputEventKey and not event.echo and event.keycode==KEY_SPACE:
		set_player_drawer(g,event.pressed)
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		for link in guide_links:
			if link.has_point(event.position):
				m.guide_page = 6
				m.guide = true
				g.ui_help.reset()
				return true
	if pending or library:
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
			if library: library = false
			return true
		if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			var p: Vector2 = event.position
			if pending:
				for i in offers.size():
					if draft_age>=i*0.65+1.0 and Rect2(260+i*335,200,230,335).has_point(p):
						chosen = offers[i]
						finish_pick(m)
						return true

			else:
				if Rect2(180,800,250,50).has_point(p): page = posmod(page-1,ceili(DATA.size()/10.0))
				elif Rect2(1010,800,250,50).has_point(p): page = (page+1)%ceili(DATA.size()/10.0)
				elif Rect2(595,800,250,50).has_point(p): library = false
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if Rect2(1140,185,230,35).has_point(event.position): library = true; return true
		for i in slots[0].size():
			if drawer[0]>0.95 and slot_rect(0,i).has_point(event.position):
				if m.side!=0 or m.banner_age<m.reveal_duration(): return true
				if swap_slot<0: swap_slot = i
				else:
					var temp: int = slots[0][i]; slots[0][i] = slots[0][swap_slot]; slots[0][swap_slot] = temp
					swap_slot = -1; m.hint_signature = ""
				return true
	if event is InputEventMouse and not m.dragging:
		for owner in 2:
			if (owner==1 and drawer_tab(owner).has_point(event.position)) or (drawer[owner]>0.01 and drawer_rect(owner).has_point(event.position)):
				return true
	return false

func update_drawers(mouse: Vector2, delta: float, enabled: bool) -> void:
	for owner in 2:
		var inside: bool = enabled and (drawer_tab(owner).grow(5).has_point(mouse) or (drawer[owner]>0.01 and drawer_rect(owner).grow(5).has_point(mouse)))
		if owner==0: inside = enabled and player_drawer_open
		if inside: drawer_grace[owner] = 0.25
		else: drawer_grace[owner] = maxf(0,drawer_grace[owner]-delta)
		var target := 1.0 if enabled and drawer_grace[owner]>0 else 0.0
		if owner==0: target = 1.0 if inside else 0.0
		drawer[owner] = move_toward(drawer[owner],target,delta*5)
	if drawer[0]==0: swap_slot = -1

func drawer_rect(owner: int) -> Rect2:
	if owner==0:
		var width := maxf(230,slots[0].size()*163+12)
		return Rect2(720-width/2,530+410*pow(1-drawer[0],3),width,255)
	return Rect2(310,153+20*(1-drawer[1]),820,255)

func drawer_tab(owner: int) -> Rect2:
	return Rect2(555,805,330,38) if owner==0 else Rect2(800,115,250,38)

func slot_rect(owner: int, slot: int) -> Rect2:
	var panel := drawer_rect(owner)
	var offset: float = (panel.size.x-(slots[owner].size()*163-18))/2 if owner==0 else 15.0
	return Rect2(panel.position+Vector2(offset+slot*163,40),Vector2(145,200))



func draw_reminder(g,m) -> void:
	var enter := smoothstep(0,1,clampf(reminder_age/0.35,0,1))
	var leave := smoothstep(0,1,clampf((reminder_age-3.8)/0.7,0,1))
	var alpha := enter*(1-leave)
	var rect := Rect2(465,603+22*(1-enter)+18*leave,510,62)
	var style = m.card_style(false)
	style.bg_color = Color(0.05,0.10,0.12,alpha)
	style.border_color = Color(1,0.69,0.28,alpha)
	g.draw_style_box(style,rect)
	var key := Rect2(rect.position+Vector2(16,12),Vector2(105,38))
	g.draw_rect(key,Color(0.25,0.19,0.10,alpha))
	g.draw_rect(key,Color(1,0.78,0.40,alpha*(0.7+0.3*sin(reminder_age*5))),false,2)
	g.label_at(key.position+Vector2(17,26),"SPACE",19,Color(1,0.87,0.62,alpha))
	g.label_at(rect.position+Vector2(138,29),"HOLD TO VIEW YOUR JOKERS",18,Color(1,0.76,0.40,alpha))
	g.label_at(rect.position+Vector2(138,49),"RELEASE TO CLOSE",12,Color(0.73,0.79,0.77,alpha))
	g.draw_line(rect.position+Vector2(12,59),rect.position+Vector2(12+486*(1-reminder_age/REMINDER_TIME),59),Color(1,0.65,0.25,alpha),2)
