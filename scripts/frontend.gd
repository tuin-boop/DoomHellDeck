extends RefCounted

var at_home := false
var started := false
var return_modal := ""

func open(g) -> void:
	if g.busy: return
	g.cancel_drag()
	g.hero_power.armed = false
	g.selected = -1
	if started and not g.ended:
		return_modal = g.modal
		g.modal = "leave_match"
		return
	finish_leaving(g)

func finish_leaving(g) -> void:
	g.ended = true
	g.battle_tools.pending = false
	started = false
	at_home = true
	return_modal = ""
	g.modal = "home"

func choose_match(g) -> void:
	started = false
	at_home = true
	g.modal = "new_match"

func start(g) -> void:
	if not g.commander_selected:
		g.initial_commander_choice = true
		g.open_commanders()
	else:
		g.new_battle()

func handle(g,event: InputEvent) -> bool:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if g.modal in ["options","new_match"]:
			g.modal = "home"
			return true
		if g.modal=="leave_match":
			g.modal = return_modal
			return true
		if g.modal=="home": return true
		if g.modal in ["","reward","defeat","draw","mulligan"]:
			open(g)
			return true
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if g.modal in ["","reward","defeat","draw","mulligan"] and g.MENU_BUTTON.has_point(event.position):
			open(g)
			return true
	return false

func draw(g) -> void:
	g.draw_rect(Rect2(0,0,1440,940),Color(0.01,0.005,0.008,0.62))
	g.button(Rect2(1140,30,230,45),"RADIO / F8")
	g.label_at(Vector2(130,180),"DOOM",92,g.ORANGE)
	g.label_at(Vector2(138,233),"HELL DECK",42,g.INK)
	g.label_at(Vector2(140,272),"BUILD YOUR LEGION. CLAIM THE TABLE.",20,g.MUTED)
	if g.modal=="options":
		g.label_at(Vector2(140,355),"OPTIONS",34,g.ORANGE)
		g.label_at(Vector2(140,425),"MASTER VOLUME   %d%%" % roundi(g.master_volume*100),24,g.INK)
		g.button(Rect2(500,387,65,52),"-")
		g.button(Rect2(580,387,65,52),"+")
		g.button(Rect2(140,465,505,60),"BATTLE VIEW: "+("ON" if g.cinematic_enabled else "OFF"))
		g.button(Rect2(140,545,505,60),"FULLSCREEN: "+("ON" if g.fullscreen else "OFF"))
		g.label_at(Vector2(140,654),"Settings save automatically.",20,g.MUTED)
		g.button(Rect2(140,705,505,60),"BACK")
	elif g.modal=="leave_match":
		g.label_at(Vector2(140,370),"LEAVE THIS MATCH?",30,g.ORANGE)
		g.label_at(Vector2(140,425),"Leaving ends this match. You cannot resume it.",20,g.INK)
		g.label_at(Vector2(140,455),"No victory reward is awarded for leaving.",18,g.MUTED)
		g.button(Rect2(140,500,505,60),"LEAVE / MAIN MENU")
		g.button(Rect2(140,580,505,60),"KEEP PLAYING")
	elif g.modal=="new_match":
		g.label_at(Vector2(140,355),"HELL DECK / BATTLE SETUP",30,g.ORANGE)
		g.button(Rect2(140,410,505,70),"BUILT DECK")
		g.label_at(Vector2(140,510),"Use your selected deck and its planned squads.",18,g.MUTED)
		g.button(Rect2(140,550,505,70),"RANDOM CARDS")
		g.label_at(Vector2(140,650),"Both sides get fresh random 20-card decks.",18,g.MUTED)
		g.button(Rect2(140,685,505,45),"DECK BUILDER")
		g.button(Rect2(140,745,505,45),"CHOOSE HERO")
		g.button(Rect2(140,805,505,45),"BACK TO MAIN MENU")
	else:
		g.label_at(Vector2(140,330),"CHOOSE YOUR GAME",25,g.INK)
		g.draw_rect(Rect2(140,365,550,350),Color(0.04,0.08,0.075,0.94))
		g.draw_rect(Rect2(750,365,550,350),Color(0.04,0.08,0.075,0.94))
		g.button(Rect2(165,395,500,80),"HELL DECK")
		g.label_at(Vector2(170,525),"TACTICAL CARD BATTLES",23,g.ORANGE)
		g.label_at(Vector2(170,570),"Heroes, weapons and monster squads.",18,g.INK)
		g.label_at(Vector2(170,605),"Built decks or fully random decks.",18,g.MUTED)
		g.label_at(Vector2(170,670),"Choose your deck and hero next.",17,g.MUTED)
		g.button(Rect2(775,395,500,80),"HELL MELD")
		g.label_at(Vector2(780,525),"MONSTER COMBINATIONS",23,g.ORANGE)
		g.label_at(Vector2(780,570),"Spot patterns. Raise the centre combo.",18,g.INK)
		g.label_at(Vector2(780,605),"Empty your hand first. Five rounds.",18,g.MUTED)
		g.label_at(Vector2(780,670),"Jump straight in. Illustrated guide inside.",17,g.MUTED)
		g.button(Rect2(140,765,260,55),"OPTIONS")
		g.button(Rect2(430,765,260,55),"QUIT")
	if g.modal=="new_match":
		g.draw_commander_portrait(Rect2(870,310,320,320),g.chosen_commander,g.ORANGE)
		g.label_at(Vector2(870,675),g.Commanders.entry(g.chosen_commander).name,26,g.INK)
		g.label_at(Vector2(870,725),"BUILT DECK",18,g.ORANGE)
		g.label_at(Vector2(870,760),str(g.deck_book.entries[g.deck_book.active].name).left(24) if g.deck_book.active>=0 else "UAC Starter",24,g.INK)
	g.label_at(Vector2(140,875),"TWO WAYS TO CLAIM THE TABLE. NO CAMPAIGN. JUST PLAY.",18,g.MUTED)

func click(g,pos: Vector2) -> void:
	if Rect2(1140,30,230,45).has_point(pos):
		g.radio.open(g)
		return
	if g.modal=="options":
		if Rect2(500,387,65,52).has_point(pos): g.master_volume = maxf(0,g.master_volume-0.1)
		elif Rect2(580,387,65,52).has_point(pos): g.master_volume = minf(1,g.master_volume+0.1)
		elif Rect2(140,465,505,60).has_point(pos): g.cinematic_enabled = not g.cinematic_enabled
		elif Rect2(140,545,505,60).has_point(pos): g.fullscreen = not g.fullscreen
		elif Rect2(140,705,505,60).has_point(pos): g.modal = "home"
		else: return
		g.apply_options()
		g.save_view_setting()
		g.audio.play("DSSWTCHN",-20)
		return
	if g.modal=="leave_match":
		if Rect2(140,500,505,60).has_point(pos): finish_leaving(g)
		elif Rect2(140,580,505,60).has_point(pos): g.modal = return_modal
		return
	if g.modal=="new_match":
		if Rect2(140,410,505,70).has_point(pos):
			g.next_random_mode = false
			start(g)
		elif Rect2(140,550,505,70).has_point(pos):
			g.next_random_mode = true
			start(g)
		elif Rect2(140,685,505,45).has_point(pos):
			g.modal = "decks"
			g.deleting_deck = -1
			g.deck_message = ""
		elif Rect2(140,745,505,45).has_point(pos): g.open_commanders()
		elif Rect2(140,805,505,45).has_point(pos): g.modal = "home"
		return
	if Rect2(165,395,500,80).has_point(pos): choose_match(g)
	elif Rect2(775,395,500,80).has_point(pos): g.hell_meld.start(g)
	elif Rect2(140,765,260,55).has_point(pos): g.modal = "options"
	elif Rect2(430,765,260,55).has_point(pos): g.get_tree().quit()
