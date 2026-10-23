extends RefCounted
const Cards = preload("res://scripts/cards.gd")
var pending := false
var replaced: Dictionary = {}
var events: Array = []
var page := 0
var selected := -1
var return_modal := ""
var curve_cards: Array = []
const HISTORY_BUTTON := Rect2(1190,800,208,40)
const CURVE_BUTTON := Rect2(720,40,210,48)

func reset(interactive: bool) -> void:
	pending = interactive
	replaced.clear()
	events.clear()
	page = 0
	selected = -1

func record(round_number: int, title: String, detail := "") -> void:
	events.push_front({"round":round_number,"title":title,"detail":detail if detail!="" else title})
	if events.size()>2000: events.pop_back()
	selected = -1

func exchange(hand: Array, deck: Array, indices: Array, director, random_mode := false) -> void:
	var returned: Array = []
	var kept: Array = []
	for i in hand.size():
		if i in indices: returned.append(Cards.DATA[hand[i]].source_id)
		else: kept.append(hand[i])
	# Rejected copies stay out of the draw pile until every replacement is dealt.
	director.history.assign(kept)
	for i in returned.size():
		if not deck.is_empty(): kept.append(deck.pop_back() if random_mode else director.take(deck,kept,true,1,0))
		else: kept.append(returned.pop_back())
	hand.assign(kept)
	deck.append_array(returned)
	deck.shuffle()

func confirm(game) -> void:
	if not pending: return
	exchange(game.hand,game.deck,replaced.keys(),game.player_director,game.random_mode)
	var cpu_reject: Array = []
	for i in game.enemy_hand.size():
		var card: Dictionary = Cards.DATA[game.enemy_hand[i]]
		if card.cost>3 or card.get("soul_cost",0)>0: cpu_reject.append(i)
	exchange(game.enemy_hand,game.enemy_deck,cpu_reject,game.cpu_director,game.random_mode)
	pending = false
	replaced.clear()
	game.modal = ""
	game.log_line("Opening hands ready. Your turn.")
	game.battle_voice.reset(game.enemy_commander)
	if not ("--balance-test" in OS.get_cmdline_user_args() or "--smoke-test" in OS.get_cmdline_user_args()): game.match_flair.start_intro(game)

func open_history(game) -> void:
	return_modal = game.modal
	page = 0
	selected = -1
	game.cancel_drag()
	game.modal = "history"

func open_curve(game, cards: Array) -> void:
	return_modal = game.modal
	curve_cards = cards.duplicate()
	game.modal = "energy_curve"

func counts(cards: Array) -> Array:
	var bins := [0,0,0,0,0,0,0,0,0]
	for id in cards: bins[clampi(Cards.DATA[id].cost,0,8)] += 1
	return bins

func draw(game) -> void:
	if game.modal=="mulligan":
		game.label_at(Vector2(100,100),"CHOOSE YOUR OPENING HAND",32)
		game.label_at(Vector2(100,145),"Click cards to replace. One redraw for each side. Rejected copies return to your deck afterwards.",18)
		for i in game.hand.size():
			var rect := Rect2(145+i*232,245,205,260)
			game.card(rect,game.hand[i])
			game.label_at(rect.position+Vector2(20,300),"REPLACE" if replaced.has(i) else "KEEP",22,Color("ff6068") if replaced.has(i) else Color("9df6b7"))
			if replaced.has(i): game.draw_rect(rect.grow(5),Color("ff6068"),false,4)
		game.label_at(Vector2(145,640),"Keep affordable units and useful squad pieces. No Souls or Energy are spent.",19)
		game.button(Rect2(500,740,440,64),"REPLACE %d / START BATTLE" % replaced.size() if not replaced.is_empty() else "KEEP HAND / START BATTLE")
	elif game.modal=="history":
		game.label_at(Vector2(70,80),"COMBAT HISTORY",32)
		game.label_at(Vector2(70,119),"Newest first. Click an event for details. Only revealed actions are recorded.",18)
		for slot in 12:
			var index := page*12+slot
			if index>=events.size(): break
			var event: Dictionary = events[index]
			var rect := Rect2(65,150+slot*49,820,44)
			game.panel(rect,Color("152027") if selected==index else Color("0c1216"))
			var title: String = "R%02d / %s" % [event.round,event.title]
			var size := 17
			while game.text_width(title,size)>790 and size>11: size -= 1
			game.label_at(rect.position+Vector2(12,28),title,size)
		game.panel(Rect2(920,150,450,580),Color("101719"))
		game.paragraph(Vector2(945,200),events[selected].detail if selected>=0 and selected<events.size() else "Select an event to inspect damage, counters, summons or other battle actions.",395,22,Color("e5e0cf"))
		game.button(Rect2(70,810,190,50),"< NEWER",page>0)
		game.button(Rect2(280,810,190,50),"OLDER >",(page+1)*12<events.size())
		game.button(Rect2(1100,810,260,50),"BACK")
	elif game.modal=="energy_curve":
		game.label_at(Vector2(100,95),"DECK ENERGY CURVE",32)
		game.label_at(Vector2(100,140),"Battle Energy costs, not deck points. Each copy counts once.",20)
		var bins := counts(curve_cards)
		var peak: int = maxi(1,bins.max())
		for i in 9:
			var height: float = 320.0*bins[i]/peak
			game.draw_rect(Rect2(130+i*132,560-height,90,height),Color("c36aff") if i>=5 else Color("ff8e42"))
			game.label_at(Vector2(155+i*132,540-height),str(bins[i]),22)
			game.label_at(Vector2(151+i*132,600),"8+" if i==8 else str(i),22)
		var total := 0
		for id in curve_cards: total += Cards.DATA[id].cost
		game.label_at(Vector2(100,685),"%d CARDS / AVERAGE %.1f ENERGY / %d COST 0-2 / %d COST 5+" % [curve_cards.size(),float(total)/maxi(1,curve_cards.size()),bins[0]+bins[1]+bins[2],bins[5]+bins[6]+bins[7]+bins[8]],22)
		game.label_at(Vector2(100,735),"Aim for plays in the opening rounds as well as late-game threats. Soul costs are separate.",18)
		game.button(Rect2(1050,810,300,55),"BACK TO BUILDING")

func click(game, pos: Vector2) -> void:
	if game.modal=="mulligan":
		for i in game.hand.size():
			if Rect2(145+i*232,245,205,310).has_point(pos):
				if replaced.has(i): replaced.erase(i)
				else: replaced[i] = true
		if Rect2(500,740,440,64).has_point(pos): confirm(game)
	elif game.modal=="history":
		for slot in 12:
			if Rect2(65,150+slot*49,820,44).has_point(pos) and page*12+slot<events.size(): selected = page*12+slot
		if Rect2(70,810,190,50).has_point(pos): page = maxi(0,page-1)
		if Rect2(280,810,190,50).has_point(pos) and (page+1)*12<events.size(): page += 1
		if Rect2(1100,810,260,50).has_point(pos): game.modal = return_modal
	elif game.modal=="energy_curve" and Rect2(1050,810,300,55).has_point(pos): game.modal = return_modal
