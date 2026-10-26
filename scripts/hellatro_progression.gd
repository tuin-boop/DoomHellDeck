extends RefCounted
const Editions = preload("res://scripts/joker_editions.gd")
var enabled := false
var active := false
var credits := [0,0]
var funded_round := 0
var offers: Array = []
var rerolls := 0
var packs_bought: Array = []
var pack_kind := -1
var preview_pack := -1
var preview_tier := 0
var pack_tier := 0
const TIER_NAMES := ["STANDARD","RARE","LEGENDARY"]
const TIER_COLORS := [Color("ea9655"),Color("bd85ff"),Color("ffdc65")]
func pack_cost(kind: int, tier: int) -> int:
	return [[4,7,10],[3,5,7],[3,5,8]][kind][tier]
func pack_box(i: int) -> Rect2:
	return Rect2(165+(i%4)*280,215+int(i/4)*155,250,140) if pack_choices.size()>3 else Rect2(210+i*350,215,280,300)
func reveal_at(i: int) -> float: return 1.5+i*0.25
var pack_choices: Array = []
var pack_age := 0.0
var apply_edition := -1
var message := ""
var recap_open := false
var recorded := false
var earned_backs: Array = []
var new_record := false
var recap := {"best":[{},{}],"families":[{},{}],"jokers":[{},{}],"plays":[0,0],"draws":[0,0],"extensions":[0,0],"routes":[]}
func reset() -> void:
	active = false
	preview_pack = -1
	credits = [0,0]
	funded_round = 0
	recap_open = false
	recorded = false
	earned_backs.clear()
	new_record = false
	recap = {"best":[{},{}],"families":[{},{}],"jokers":[{},{}],"plays":[0,0],"draws":[0,0],"extensions":[0,0],"routes":[]}
func price(m, id: int, edition: int) -> int:
	return (9 if id in m.support.RARE else (7 if id in m.support.UNCOMMON else 5))+(2 if edition>0 else 0)
func sale_price(m, id: int, owner: int) -> int:
	return (4 if id in m.support.RARE else (3 if id in m.support.UNCOMMON else 2))+(1 if m.support.edition_of(owner,id)>0 else 0)
func make_offers(m, owner: int) -> Array:
	var result: Array = []
	for id in m.support.draft_offers(m,owner):
		var edition := Editions.roll(m.random)
		result.append({"id":id,"edition":edition,"price":price(m,id,edition),"sold":false})
	return result
func open_shop(m) -> void:
	if not enabled:
		m.start_round_intro()
		return
	active = true
	if funded_round<m.round_number:
		for owner in 2: credits[owner] += 8
		funded_round = m.round_number
	rerolls = 0
	preview_pack = -1
	packs_bought.clear()
	pack_kind = -1
	apply_edition = -1
	message = "Both players receive 8 credits per round. Saved credits carry over."
	offers = make_offers(m,0)
	cpu_shop(m)
func sell(m, owner: int, slot: int) -> bool:
	if slot<0 or slot>=m.support.slots[owner].size(): return false
	var id: int = m.support.slots[owner][slot]
	credits[owner] += sale_price(m,id,owner)
	m.support.slots[owner].remove_at(slot)
	m.support.editions[owner].erase(id)
	# Selling a growing Joker loses its progress, preventing free buy-back growth.
	var keys := {1:["vampire"],5:["marches"],8:["sleep"],11:["chef"],20:["coffee_used"],22:["barrel"],24:["glitch_used"],26:["gluttonous"],37:["book_families"],40:["glitch_plays"],44:["campfire_ready"]}
	for key in keys.get(id,[]): m.support.stats[owner].erase(key)
	return true
func buy(m, index: int) -> bool:
	if not active or pack_kind>=0 or index<0 or index>=offers.size(): return false
	var item: Dictionary = offers[index]
	if item.sold or m.support.has(0,item.id): return false
	if m.support.slots[0].size()>=m.slot_limit():
		message = "Slots full. Sell a Joker below before buying its replacement."
		return false
	if credits[0]<item.price:
		message = "Not enough credits. Save, sell, or continue to the round."
		return false
	credits[0] -= item.price
	m.support.slots[0].append(item.id)
	m.support.editions[0][item.id] = item.edition
	item.sold = true
	message = "Bought "+m.support.DATA[item.id][1]+"."
	return true
func reroll(m) -> bool:
	var cost := 2+rerolls
	if not active or pack_kind>=0: return false
	if credits[0]<cost:
		message = "Need %d credits to reroll." % cost
		return false
	credits[0] -= cost
	rerolls += 1
	offers = make_offers(m,0)
	message = "New offers. The next reroll costs %d credits." % (2+rerolls)
	return true
func open_pack(m, kind: int, tier := 0) -> bool:
	if not active or pack_kind>=0 or kind in packs_bought or kind<0 or kind>2: return false
	if tier<0 or tier>2: return false
	if m.run.enabled and pack_reason(m,kind,tier)!="": return false
	var cost := pack_cost(kind,tier)
	if credits[0]<cost:
		message = "Need %d credits for this pack." % cost
		return false
	if kind==0 and m.support.slots[0].size()>=m.slot_limit():
		message = "Sell a Joker to make room before opening a Joker pack."
		return false
	if kind==1 and m.support.slots[0].is_empty(): return false
	credits[0] -= cost
	packs_bought.append(kind)
	pack_kind = kind
	pack_tier = tier
	pack_age = 0
	pack_choices.clear()
	if kind==0:
		var ids: Array = m.support.draft_offers(m,0)
		if tier>0:
			var pool: Array = []
			for id in m.support.DATA.size():
				if not m.support.has(0,id) and (id in m.support.RARE or (tier==1 and id in m.support.UNCOMMON)): pool.append(id)
			ids.clear()
			for i in mini(3,pool.size()): ids.append(pool.pop_at(m.random.randi_range(0,pool.size()-1)))
		for id in ids: pack_choices.append({"id":id,"edition":Editions.roll(m.random)})
	elif kind==1:
		var pool: Array = range(1,Editions.DATA.size())
		for i in [3,5,8][tier]: pack_choices.append(pool.pop_at(m.random.randi_range(0,pool.size()-1)))
	else:
		var pool: Array = m.FAMILIES.duplicate()
		for i in 3: pack_choices.append(pool.pop_at(m.random.randi_range(0,pool.size()-1)))
	return true
func choose_pack(m, index: int) -> bool:
	if pack_kind<0 or apply_edition>=0 or index<0 or index>=pack_choices.size() or pack_age<reveal_at(index): return false
	if pack_kind==0:
		var item: Dictionary = pack_choices[index]
		if m.support.has(0,item.id) or m.support.slots[0].size()>=m.slot_limit(): return false
		m.support.slots[0].append(item.id)
		m.support.editions[0][item.id] = item.edition
	elif pack_kind==1:
		apply_edition = int(pack_choices[index])
		message = "Choose one of your Jokers below. Its existing edition will be replaced."
		return true
	else:
		var family: String = pack_choices[index]
		m.upgrades[0][family] = int(m.upgrades[0].get(family,0))+[1,2,3][pack_tier]
	pack_kind = -1
	message = "Pack reward claimed."
	return true
func finish(m) -> void:
	if not active or pack_kind>=0: return
	active = false
	m.support.apply_contract(m)
	m.hint_signature = ""
	m.start_round_intro()
func cpu_shop(m, owner := 1) -> void:
	# Same income, prices, sale values and one-per-shop packs as the player.
	var stock: Array = make_offers(m,owner)
	var ids: Array = []
	for item in stock: ids.append(item.id)
	var chosen: int = m.support.auto_pick(m,owner,ids)
	for item in stock:
		if item.id!=chosen: continue
		if m.support.slots[owner].size()<m.slot_limit() and credits[owner]>=item.price:
			credits[owner] -= item.price
			m.support.slots[owner].append(item.id)
			m.support.editions[owner][item.id] = item.edition
		elif credits[owner]>=item.price and m.random.randf()<0.3:
			var slot: int = m.random.randi_range(0,m.support.slots[owner].size()-1)
			sell(m,owner,slot)
			credits[owner] -= item.price
			m.support.slots[owner].append(item.id)
			m.support.editions[owner][item.id] = item.edition
	if credits[owner]>=3:
		# Buy one upgrade pack, choosing from three just like the player.
		credits[owner] -= 3
		var pool: Array = m.FAMILIES.duplicate()
		var choices: Array = []
		for i in 3: choices.append(pool.pop_at(m.random.randi_range(0,pool.size()-1)))
		var best: String = choices[0]
		for family in choices:
			if m.family_plays[owner].get(family,0)>m.family_plays[owner].get(best,0): best = family
		m.upgrades[owner][best] = int(m.upgrades[owner].get(best,0))+1
	if credits[owner]>=3:
		for id in m.support.slots[owner]:
			if m.support.edition_of(owner,id)==0:
				credits[owner] -= 3
				m.support.editions[owner][id] = m.random.randi_range(1,Editions.DATA.size()-1)
				break
func record_play(owner: int, combo: Dictionary, extension := false) -> void:
	if extension: recap.extensions[owner] += 1
	recap.plays[owner] += 1
	recap.families[owner][combo.kind] = int(recap.families[owner].get(combo.kind,0))+1
	if combo.gain>recap.best[owner].get("gain",-1): recap.best[owner] = {"name":combo.name,"gain":combo.gain}
	for event in combo.get("support_events",[]):
		var id: int = event.id
		recap.jokers[owner][id] = int(recap.jokers[owner].get(id,0))+int(event.get("amount",0))
func finalize(m) -> void:
	if not enabled or recorded: return
	recorded = true
	m.profile.ensure_loaded()
	new_record = m.scores[0]>m.profile.best_total
	earned_backs = m.profile.finish(m,recap)
func draw_recap(g,m) -> void:
	g.ui_help.reset()
	g.draw_rect(Rect2(0,0,1440,940),Color("080e12"))
	g.menu_frame(Rect2(100,75,1240,790))
	g.label_at(Vector2(145,135),"RUN RECAP"+(" / STAGE %d" % m.run.stage if m.run.enabled else "")+(" / NEW SCORE RECORD!" if new_record else ""),30,g.ORANGE)
	for owner in 2:
		var x := 150+owner*600
		g.label_at(Vector2(x,210),"YOU" if owner==0 else "CPU",28,g.INK)
		g.label_at(Vector2(x,255),"TOTAL: %d / PLAYS: %d / DRAWS: %d" % [m.scores[owner],recap.plays[owner],recap.draws[owner]],17,g.INK)
		g.label_at(Vector2(x,310),"BEST PLAY",19,g.ORANGE)
		g.label_at(Vector2(x,345),str(recap.best[owner].get("name","NO SCORING PLAY")),18,g.INK)
		g.label_at(Vector2(x,380),"+%d POINTS" % recap.best[owner].get("gain",0),22,g.INK)
		var best := -1
		for id in recap.jokers[owner]:
			if best<0 or recap.jokers[owner][id]>recap.jokers[owner][best]: best = id
		g.label_at(Vector2(x,440),"TOP JOKER / DIRECT POINTS",18,g.ORANGE)
		if best>=0 and recap.jokers[owner][best]>0:
			g.label_at(Vector2(x,475),m.support.DATA[best][1]+" / +%d" % recap.jokers[owner][best],18,g.INK)
			m.support.card(g,m,best,Rect2(x+390,300,120,175),owner,false)
		else: g.label_at(Vector2(x,475),"NO DIRECT JOKER BONUS",17,g.MUTED)
		g.label_at(Vector2(x,520),"FAMILIES PLAYED: %d / 6" % recap.families[owner].size(),18,g.INK)
		var row := 0
		for family in recap.families[owner]:
			g.label_at(Vector2(x,550+row*24),m.FAMILY_NAMES[family]+" / %d" % recap.families[owner][family],14,g.MUTED)
			row += 1
	g.label_at(Vector2(150,725),"NEW BACKS: "+(", ".join(earned_backs) if not earned_backs.is_empty() else "None this run. See Card Backs for challenges."),16,g.ORANGE)
	g.button(Rect2(350,780,300,50),"CARD BACKS")
	g.button(Rect2(790,780,300,50),"BACK TO RESULTS")
func tick(g, delta: float) -> void:
	if pack_kind<0: return
	var previous := pack_age
	pack_age += delta
	if previous<1.0 and pack_age>=1.0: g.audio.play("DSBAREXP",-23)
	for i in pack_choices.size():
		if previous<reveal_at(i) and pack_age>=reveal_at(i): g.audio.play("DSGETPOW" if pack_tier==2 else "DSITEMUP",-20)
func draw_pack_opening(g,m) -> void:
	var t := pack_age
	var color: Color = TIER_COLORS[pack_tier]
	var center := Vector2(720,365)
	if t<1.5:
		var split := maxf(0,t-1.0)*420
		var shake := sin(t*65)*minf(t*9,8) if t<1.0 else 0.0
		for half in 2:
			var direction := -1 if half==0 else 1
			var rect := Rect2(center+Vector2(direction*(60+split)-60+shake,-135+split*0.12),Vector2(120,270))
			g.draw_rect(rect,Color("291b24"))
			g.draw_rect(rect,color,false,4)
			for stripe in 6: g.draw_line(rect.position+Vector2(8,20+stripe*44),rect.position+Vector2(112,8+stripe*44),Color(color,0.3),3)
		if t<1.0:
			g.draw_circle(center,52,color)
			m.centered_at(g,["J","E","+5"][pack_kind],center+Vector2(0,14),40,Color("241523"))
			m.centered_at(g,TIER_NAMES[pack_tier]+" PACK",center+Vector2(0,180),22,color)
	if t>=1.0:
		var age := t-1.0
		for spark in 36+pack_tier*20:
			var direction := Vector2.from_angle(spark*2.39996)
			var pos := center+direction*(60+age*(100+spark%7*25))+Vector2(0,age*age*45)
			g.draw_rect(Rect2(pos,Vector2(3+spark%3,3+spark%3)),Color(color,maxf(0,1-age/2.5)))
		if age<0.5: g.draw_arc(center,30+age*370,0,TAU,60,Color(color,1-age*2),4)

func pack_reason(m, kind: int, tier := 0) -> String:
	m.profile.ensure_loaded()
	if m.run.enabled and tier>0 and m.profile.highest_stage<[1,2,4][tier]: return "Reach stage %d to permanently unlock %s packs." % [[1,2,4][tier],TIER_NAMES[tier]]
	if kind in packs_bought: return "Already purchased here. Available again in the next round's shop."
	if kind==0 and m.support.slots[0].size()>=m.slot_limit(): return "No free Joker slot. Sell one of your Jokers first."
	if kind==1 and m.support.slots[0].is_empty(): return "You need an owned Joker to receive an edition."
	var cost := pack_cost(kind,tier)
	if credits[0]<cost: return "Need %d credits; you have %d." % [cost,credits[0]]
	return ""
func pack_description(kind: int) -> String:
	return ["Reveal three random Jokers and keep ONE. Requires a free slot. The others are discarded. Your pick stays for this match.","Reveal three random editions and choose ONE. Then select an owned Joker to receive its extra scoring effect and animated look. Replaces its old edition; keeps its normal ability. No new Joker or slot.","Reveal three combo families and choose ONE. Every play or extension of that family earns +5 for the rest of this match. Stacks with your other family upgrades."][kind]+" One purchase per pack type per shop. Skipping an opened pack gives no refund."
func draw_pack_preview(g,m) -> void:
	g.ui_help.reset()
	g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.8))
	g.menu_frame(Rect2(210,130,1020,680))
	var kind := preview_pack
	var cost := pack_cost(kind,preview_tier)
	var title: String = ["JOKER PACK","EDITION PACK","UPGRADE PACK"][kind]
	g.label_at(Vector2(250,190),title+" / "+TIER_NAMES[preview_tier],28,g.ORANGE)
	var lines: Array = [
		["Pay %d credits to reveal 3 random Jokers." % cost,"Choose ONE to keep for this match.",["Any rarity; common Jokers are more likely.","All offers are Uncommon or Rare.","All offers are Rare Jokers."][preview_tier],"You need a free Joker slot.","Sell an owned Joker first if your slots are full."],
		["Pay %d credits to reveal %d distinct editions." % [cost,[3,5,8][preview_tier]],"Choose ONE, then click an owned Joker to apply it.","That Joker keeps its normal ability.","The edition adds an extra scoring bonus and effects.","Replaces the old edition. Editions never stack."],
		["Pay %d credits to reveal 3 combo families." % cost,"Choose ONE family to upgrade.","Each play or extension of that family gains +%d." % (5*(preview_tier+1)),"Lasts for this match and stacks with upgrades.","Example: a 40-point March becomes %d points." % (40+5*(preview_tier+1))]
	][kind]
	for i in lines.size(): g.label_at(Vector2(250,290+i*35),lines[i],18,g.INK)
	g.label_at(Vector2(250,500),"Buy once per shop. Credits are separate from points.",17,g.MUTED)
	g.label_at(Vector2(250,535),"Skipping after opening loses the pack and its credits.",17,g.MUTED)
	if kind<2:
		var id: int = m.support.slots[0][0] if not m.support.slots[0].is_empty() else 0
		m.support.card(g,m,id,Rect2(940,245,190,270),-1,true,2 if kind==1 else 0)
		g.label_at(Vector2(910,555),"EXAMPLE / NOT A PROMISE",13,g.ORANGE)
		if kind==1: g.label_at(Vector2(910,582),"GOLDEN: +2 per scoring play",13,g.INK)
	else:
		g.draw_circle(Vector2(1030,365),85+sin(g.clock*3)*5,Color("472b1c"))
		m.centered_at(g,"+%d" % (5*(preview_tier+1)),Vector2(1030,380),60,g.ORANGE)
		m.centered_at(g,"MARCH EXAMPLE",Vector2(1030,465),17,g.INK)
	for tier in 3:
		g.button(Rect2(250+tier*210,210,195,45),TIER_NAMES[tier]+(" *" if tier==preview_tier else ""))
		g.ui_help.offer(Rect2(250+tier*210,210,195,45),TIER_NAMES[tier]+" PACK","Preview this tier without spending credits. Price: %d credits. " % pack_cost(kind,tier)+pack_reason(m,kind,tier))
	var reason := pack_reason(m,kind,preview_tier)
	g.label_at(Vector2(250,635),reason if reason!="" else "Ready to open. You choose your reward after the reveal.",17,g.ORANGE)
	g.button(Rect2(250,700,280,60),"BACK TO SHOP")
	g.button(Rect2(860,700,320,60),"BUY & OPEN / %d CR" % cost,reason=="")
	g.ui_help.offer(Rect2(860,700,320,60),title,reason if reason!="" else pack_description(kind))

func draw(g,m) -> void:
	m.support.guide_links.clear()
	g.ui_help.reset()
	g.draw_rect(Rect2(0,0,1440,940),Color("0b1012"))
	g.menu_frame(Rect2(65,45,1310,850))
	g.label_at(Vector2(105,105),"DEMON SHOP / "+("STAGE %d / " % m.run.stage if m.run.enabled else "")+"ROUND %d" % m.round_number,31,g.ORANGE)
	g.label_at(Vector2(875,102),"YOU: %d CR / CPU: %d CR" % credits,22,Color("ffda68"))
	g.label_at(Vector2(105,140),message,16,g.INK)
	if pack_kind>=0:
		g.label_at(Vector2(105,185),["JOKER CRATE / CHOOSE ONE","EDITION RITUAL / CHOOSE ONE","UPGRADE CACHE / CHOOSE ONE"][pack_kind],21,g.ORANGE)
		for i in pack_choices.size():
			if pack_age<1.35: continue
			var box := pack_box(i)
			if pack_age<reveal_at(i):
				g.draw_rect(box,Color("302323"))
				m.centered_at(g,"?",box.get_center(),62,g.ORANGE)
				continue
			if pack_kind==0: m.support.card(g,m,pack_choices[i].id,box,-1,true,pack_choices[i].edition)
			else:
				g.button(box,"")
				if pack_kind==1:
					Editions.draw(g,box,int(pack_choices[i]),g.clock)
					m.centered_at(g,Editions.DATA[pack_choices[i]][0],box.get_center(),22,Color(Editions.DATA[pack_choices[i]][2]))
					g.ui_help.offer(box,Editions.DATA[pack_choices[i]][0],Editions.DATA[pack_choices[i]][1])
				else:
					m.centered_at(g,"+%d" % (5*(pack_tier+1)),box.get_center(),46,g.ORANGE)
					m.centered_at(g,m.FAMILY_NAMES[pack_choices[i]],Vector2(box.get_center().x,box.end.y-30),17,g.INK)
					g.ui_help.offer(box,m.FAMILY_NAMES[pack_choices[i]],m.FAMILY_HELP[pack_choices[i]]+" Every play or extension gains +%d for this match. Stacks with earlier upgrades. Choose this OR one of the other two rewards." % (5*(pack_tier+1)))
		if pack_age<3.5: draw_pack_opening(g,m)
		g.button(Rect2(1080,545,230,42),"SKIP PACK")
	else:
		for i in offers.size():
			var item: Dictionary = offers[i]
			var box := Rect2(120+i*305,185,215,305)
			m.support.card(g,m,item.id,box,-1,true,item.edition)
			g.button(Rect2(120+i*305,505,215,42),"SOLD" if item.sold else "BUY / %d CR" % item.price,not item.sold)
			g.ui_help.offer(Rect2(120+i*305,505,215,42),m.support.DATA[item.id][1],("Already bought from this shop." if item.sold else m.support.DATA[item.id][2]+(" Edition: "+Editions.DATA[item.edition][0]+" / "+Editions.DATA[item.edition][1] if item.edition>0 else "")+" Costs %d credits. Requires a free Joker slot. Stays for this match." % item.price))
		g.button(Rect2(1055,190,265,60),"REROLL / %d CR" % (2+rerolls))
		for kind in 3:
			var pack_rect := Rect2(1055,275+kind*80,265,65)
			g.button(pack_rect,["JOKER PACK / 4 CR","EDITION PACK / 3 CR","UPGRADE PACK / 3 CR"][kind] if not kind in packs_bought else "PACK PURCHASED",not kind in packs_bought)
			g.ui_help.offer(pack_rect,["JOKER PACK","EDITION PACK","UPGRADE PACK"][kind],pack_description(kind)+"\n"+pack_reason(m,kind)+"\nClick to preview before spending credits.")
		g.label_at(Vector2(1055,540),"Click a pack to inspect tiers.",15,g.MUTED)
	g.label_at(Vector2(105,590),"YOUR JOKERS / %d OF %d SLOTS" % [m.support.slots[0].size(),m.slot_limit()],18,g.ORANGE)
	for i in m.support.slots[0].size():
		var id: int = m.support.slots[0][i]
		m.support.card(g,m,id,Rect2(110+i*195,610,115,165),0)
		if pack_kind<0 or apply_edition>=0:
			var action_rect := Rect2(105+i*195,782,175,35)
			g.button(action_rect,"APPLY EDITION" if apply_edition>=0 else "SELL / %d CR" % sale_price(m,id,0))
			g.ui_help.offer(action_rect,"APPLY EDITION" if apply_edition>=0 else "SELL JOKER",("Apply "+Editions.DATA[apply_edition][0]+": "+Editions.DATA[apply_edition][1]+" Replaces this Joker's previous edition; keeps its normal ability." if apply_edition>=0 else "Remove "+m.support.DATA[id][1]+" and gain %d credits. Frees a slot. Its edition and accumulated Joker progress are lost." % sale_price(m,id,0)))
	if pack_kind<0: g.button(Rect2(1060,745,265,65),"ENTER ROUND")
	g.button(Rect2(1060,825,265,40),"MAIN MENU")
	g.label_at(Vector2(105,855),"Credits are separate from points. Editions do not stack.",15,g.MUTED)
	g.ui_help.offer(Rect2(1055,190,265,60),"REROLL SHOP OFFERS","Replace the three Joker offers. Does not change owned Jokers or reset purchased packs. Costs %d credits now; the next reroll costs %d." % [2+rerolls,3+rerolls])
	g.ui_help.offer(Rect2(1060,745,265,65),"ENTER ROUND","Leave the shop and start the round. Unspent credits carry over. Shop stock and pack availability refresh next round.")
	g.ui_help.offer(Rect2(1080,545,230,42),"SKIP PACK","Discard this opened pack without taking a reward. Credits are not refunded; this pack type remains purchased until next round.")
	if preview_pack>=0: draw_pack_preview(g,m)
func handle(g,m,event: InputEvent) -> void:
	if preview_pack>=0:
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE: preview_pack = -1
		if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			for tier in 3:
				if Rect2(250+tier*210,210,195,45).has_point(event.position): preview_tier = tier; return
			if Rect2(250,700,280,60).has_point(event.position): preview_pack = -1
			elif Rect2(860,700,320,60).has_point(event.position) and pack_reason(m,preview_pack,preview_tier)=="":
				if open_pack(m,preview_pack,preview_tier):
					preview_pack = -1
					g.audio.play("DSBDOPN",-18)
		return
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		g.frontend.open(g)
		return
	if not (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT): return
	var p: Vector2 = event.position
	if Rect2(1060,825,265,40).has_point(p):
		g.frontend.open(g)
		return
	for link in m.support.guide_links:
		if link.has_point(p):
			m.guide = true
			m.guide_page = 6
			return
	if pack_kind>=0:
		if Rect2(1080,545,230,42).has_point(p): pack_kind = -1; apply_edition = -1; return
		for i in pack_choices.size():
			if pack_box(i).has_point(p):
				if choose_pack(m,i): g.audio.play("DSGETPOW",-18)
		if apply_edition>=0:
			for i in m.support.slots[0].size():
				if Rect2(105+i*195,782,175,35).has_point(p):
					m.support.editions[0][m.support.slots[0][i]] = apply_edition
					apply_edition = -1
					pack_kind = -1
					g.audio.play("DSGETPOW",-18)
		return
	for i in offers.size():
		if Rect2(120+i*305,505,215,42).has_point(p) and buy(m,i): g.audio.play("DSITEMUP",-18)
	if Rect2(1055,190,265,60).has_point(p) and reroll(m): g.audio.play("DSBDOPN",-18)
	for kind in 3:
		if Rect2(1055,275+kind*80,265,65).has_point(p): preview_pack = kind; preview_tier = 0; return
	for i in m.support.slots[0].size():
		if Rect2(105+i*195,782,175,35).has_point(p):
			sell(m,0,i)
			g.audio.play("DSITEMUP",-18)
			break
	if Rect2(1060,745,265,65).has_point(p): finish(m)
