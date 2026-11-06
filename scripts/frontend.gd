extends RefCounted

var scores_open := false
var restart_confirm := false
var leaderboard = preload("res://scripts/high_scores.gd").new()
var cursors_open := false
var at_home := false
var started := false
var return_modal := ""
var tutorial_mode := 0
var tutorial_page := 0
var tutorial_disabled := false
var tutorial_launch := true
var tutorial_started_at := 0.0
var cursor_textures := {"baron":preload("res://assets/cursors/baron.png"),"imp":preload("res://assets/cursors/imp.png")}

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
	g.hell_meld.run.save_run(g.hell_meld)
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
	if scores_open:
		leaderboard.handle(g,event)
		return true
	if restart_confirm and event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		restart_confirm = false
		return true
	if g.hell_meld.profile.open:
		g.hell_meld.profile.handle(event)
		return true
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if g.modal=="mode_tutorial":
			g.modal = "home"
			return true
		if g.modal=="options" and cursors_open:
			cursors_open = false
			return true
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
	if scores_open:
		leaderboard.draw(g)
		return
	if restart_confirm:
		g.draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.8))
		g.menu_frame(Rect2(300,270,840,370))
		g.label_at(Vector2(345,335),"START A NEW RUN?",32,g.ORANGE)
		g.label_at(Vector2(345,395),"Your saved run will be replaced. Unlocks and high scores stay.",19,g.INK)
		g.button(Rect2(345,490,340,65),"START NEW RUN")
		g.button(Rect2(715,490,340,65),"KEEP SAVED RUN")
		return
	if g.hell_meld.profile.open:
		g.hell_meld.profile.draw(g)
		return
	g.draw_rect(Rect2(0,0,1440,940),Color(0.01,0.005,0.008,0.62))
	g.button(Rect2(1140,30,230,45),"RADIO / F8")
	g.label_at(Vector2(130,180),"DOOM",92,g.ORANGE)
	g.label_at(Vector2(138,233),"HELL DECK",42,g.INK)
	g.label_at(Vector2(140,272),"BUILD YOUR LEGION. CLAIM THE TABLE.",20,g.MUTED)
	if g.modal=="mode_tutorial":
		draw_tutorial(g)
		return
	if g.modal=="options" and cursors_open:
		draw_cursors(g)
		return
	if g.modal=="options":
		g.label_at(Vector2(140,355),"OPTIONS",34,g.ORANGE)
		g.label_at(Vector2(140,425),"MASTER VOLUME   %d%%" % roundi(g.master_volume*100),24,g.INK)
		g.button(Rect2(500,387,65,52),"-")
		g.button(Rect2(580,387,65,52),"+")
		g.label_at(Vector2(700,425),"SOUNDTRACK   %d%%" % roundi(g.radio.volume*100),22,g.INK)
		g.button(Rect2(1060,387,65,52),"-")
		g.button(Rect2(1140,387,65,52),"+")
		g.button(Rect2(140,465,505,60),"BATTLE VIEW: "+("ON" if g.cinematic_enabled else "OFF"))
		g.button(Rect2(140,545,505,60),"FULLSCREEN: "+("ON" if g.fullscreen else "OFF"))
		g.button(Rect2(140,625,505,55),"JOKER REMINDERS: "+("ON" if g.joker_reminders else "OFF"))
		g.button(Rect2(700,465,505,60),"SCREEN SHAKE: "+("ON" if g.screen_shake else "OFF"))
		g.button(Rect2(700,545,505,60),"FLYING GIBS: "+("ON" if g.gibs_enabled else "OFF"))
		g.button(Rect2(700,625,505,55),"MODE TUTORIALS: "+("ON" if g.mode_tutorials else "OFF"))
		g.label_at(Vector2(140,699),"Settings save automatically.",16,g.MUTED)
		g.button(Rect2(140,705,505,60),"BACK")
		g.button(Rect2(700,705,505,60),"HELLATRO CARD BACKS")
		g.button(Rect2(700,785,505,55),"CURSOR COLLECTION")
	elif g.modal=="leave_match":
		g.label_at(Vector2(140,370),"LEAVE THIS MATCH?",30,g.ORANGE)
		g.label_at(Vector2(140,425),"Your Hellatro run will be saved. Resume it from the menu." if return_modal=="hell_meld" and g.hell_meld.run.enabled else "Leaving ends this match. You cannot resume it.",20,g.INK)
		g.label_at(Vector2(140,455),"Your cards, credits, shop choices and current turn are kept." if return_modal=="hell_meld" and g.hell_meld.run.enabled else "No victory reward is awarded for leaving.",18,g.MUTED)
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
		for side in 2:
			var x: float = 140+side*610
			g.menu_frame(Rect2(x,365,550,405))
			g.draw_rect(Rect2(x+8,373,534,210),Color("1b2423"))
			for spark in 12:
				var pos := Vector2(x+20+fposmod(spark*47.0,510),575-fposmod(g.clock*22+spark*29.0,185))
				g.draw_rect(Rect2(pos,Vector2(2,4)),Color(1,0.35,0.05,0.35))
		g.draw_commander_portrait(Rect2(310,375,190,190),g.chosen_commander,g.ORANGE)
		draw_monster(g,"CYBR",Rect2(175,390,120,180))
		draw_monster(g,"BOSS",Rect2(520,390,120,180))
		for i in 3:
			g.hell_meld.support.card(g,g.hell_meld,[43,41,44][i],Rect2(840+i*125,390+abs(i-1)*18,120,170),-1,false)
		g.label_at(Vector2(170,615),"TACTICAL CARD BATTLES",23,g.ORANGE)
		g.label_at(Vector2(170,649),"Build a deck. Command four lanes.",18,g.INK)
		g.button(Rect2(165,680,320,60),"PLAY HELL DECK")
		g.button(Rect2(500,680,165,60),"HOW TO PLAY")
		g.label_at(Vector2(780,615),"HELLATRO / COMBO CHAOS",23,g.ORANGE)
		g.label_at(Vector2(780,649),"Win best-of-five stages. Keep going until defeated.",18,g.INK)
		g.button(Rect2(775,680,320,60),"RESUME HELLATRO" if g.hell_meld.run.available() else "PLAY HELLATRO")
		g.hell_meld.profile.ensure_loaded()
		g.label_at(Vector2(780,765),"BEST RUN %d / FURTHEST STAGE %d" % [g.hell_meld.profile.best_run,g.hell_meld.profile.highest_stage],15,g.ORANGE)
		g.button(Rect2(775,795,235,55),"NEW RUN")
		g.button(Rect2(1025,795,250,55),"HIGH SCORES")
		g.button(Rect2(1110,680,165,60),"HOW TO PLAY")
		g.button(Rect2(140,800,260,55),"OPTIONS")
		g.button(Rect2(430,800,260,55),"QUIT")
	if g.modal=="new_match":
		g.draw_commander_portrait(Rect2(870,310,320,320),g.chosen_commander,g.ORANGE)
		g.label_at(Vector2(870,675),g.Commanders.entry(g.chosen_commander).name,26,g.INK)
		g.label_at(Vector2(870,725),"BUILT DECK",18,g.ORANGE)
		g.label_at(Vector2(870,760),str(g.deck_book.entries[g.deck_book.active].name).left(24) if g.deck_book.active>=0 else "UAC Starter",24,g.INK)
	if g.modal!="options": g.label_at(Vector2(140,875),"TACTICAL BATTLES OR AN ENDLESS DESCENT. CLAIM THE TABLE.",18,g.MUTED)

func click(g,pos: Vector2) -> void:
	if restart_confirm:
		if Rect2(345,490,340,65).has_point(pos):
			restart_confirm = false
			g.hell_meld.start(g)
			g.hell_meld.run.save_run(g.hell_meld)
		elif Rect2(715,490,340,65).has_point(pos): restart_confirm = false
		return
	if g.modal=="options" and cursors_open:
		if Rect2(140,790,330,60).has_point(pos): cursors_open = false
		for i in 4:
			if Rect2(120+i*305,350,285,380).has_point(pos):
				g.hell_meld.profile.equip_cursor(["default","baron","imp","doomguy"][i])
		return
	if g.hell_meld.profile.open: return
	if g.modal=="mode_tutorial":
		tutorial_click(g,pos)
		return
	if Rect2(1140,30,230,45).has_point(pos):
		g.radio.open(g)
		return
	if g.modal=="options":
		if Rect2(500,387,65,52).has_point(pos): g.master_volume = maxf(0,g.master_volume-0.1)
		elif Rect2(580,387,65,52).has_point(pos): g.master_volume = minf(1,g.master_volume+0.1)
		elif Rect2(1060,387,65,52).has_point(pos): g.radio.set_volume(g.radio.volume-0.05)
		elif Rect2(1140,387,65,52).has_point(pos): g.radio.set_volume(g.radio.volume+0.05)
		elif Rect2(140,465,505,60).has_point(pos): g.cinematic_enabled = not g.cinematic_enabled
		elif Rect2(140,545,505,60).has_point(pos): g.fullscreen = not g.fullscreen
		elif Rect2(140,625,505,55).has_point(pos): g.joker_reminders = not g.joker_reminders
		elif Rect2(700,465,505,60).has_point(pos): g.screen_shake = not g.screen_shake
		elif Rect2(700,545,505,60).has_point(pos): g.gibs_enabled = not g.gibs_enabled
		elif Rect2(700,625,505,55).has_point(pos): g.mode_tutorials = not g.mode_tutorials
		elif Rect2(700,705,505,60).has_point(pos): g.hell_meld.profile.open = true
		elif Rect2(140,705,505,60).has_point(pos): g.modal = "home"
		elif Rect2(700,785,505,55).has_point(pos): cursors_open = true
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
	if Rect2(775,795,235,55).has_point(pos):
		if g.hell_meld.run.available(): restart_confirm = true
		else: g.hell_meld.start(g)
	elif Rect2(1025,795,250,55).has_point(pos): show_scores(g)
	elif Rect2(165,680,320,60).has_point(pos): select_mode(g,0)
	elif Rect2(775,680,320,60).has_point(pos): select_mode(g,1)
	elif Rect2(500,680,165,60).has_point(pos): open_tutorial(g,0,false)
	elif Rect2(1110,680,165,60).has_point(pos): open_tutorial(g,1,false)
	elif Rect2(140,800,260,55).has_point(pos): g.modal = "options"
	elif Rect2(430,800,260,55).has_point(pos):
		g.hell_meld.run.save_run(g.hell_meld)
		g.get_tree().quit()

func select_mode(g, mode: int) -> void:
	if mode==1 and g.hell_meld.run.available() and g.hell_meld.run.resume(g,g.hell_meld): return
	if g.mode_tutorials: open_tutorial(g,mode,true)
	elif mode==0: choose_match(g)
	else: g.hell_meld.start(g)

func open_tutorial(g, mode: int, launch: bool) -> void:
	tutorial_started_at = g.clock
	tutorial_mode = mode
	tutorial_page = 0
	tutorial_disabled = not g.mode_tutorials
	tutorial_launch = launch
	g.modal = "mode_tutorial"

const LESSONS := [
	[
		["BUILD YOUR LEGION", "Choose a built deck or random cards, then your hero.", "Monsters, weapons and hero powers work together.", "Hover cards to inspect their costs and abilities."],
		["COMMAND FOUR LANES", "Drag a card from your hand into a lane to deploy it.", "Spend Souls on cards and watch the enemy lanes.", "Use damage types, resistances and squads to your advantage."],
		["BREAK THE ENEMY", "Press Space to end your turn and resolve combat.", "Defeat the enemy commander to win the battle.", "Hover controls for help; Escape opens the menu."]
	],
	[
		["MAKE A COMBINATION", "Select matching monsters, a March, or a named team.", "Drag your selection into the table to score points.", "The Field Guide shows every legal combination."],
		["EXTEND OR DRAW", "Add compatible cards to the combo on the table to score again.", "Draw / Pass takes a card, clears the table and ends your turn.", "Each player has ten turns per round. Plan your last play!"],
		["BUILD YOUR JOKER CREW", "Pick a free Joker each round while you have room. Maximum: five.", "Hold Space to inspect your Jokers. Their bonuses trigger automatically.", "Example: Tennis Pinky adds +10 for a one-card reply to an opponent-started combo."],
        ["WIN ROUNDS, THEN STAGES", "After both players take ten turns, the higher round score wins.", "Win three rounds to clear a stage. Round wins decide; points break ties.", "A round win adds 30 run-score points. Emptying your hand does not end the round."],
        ["CHOOSE YOUR ROUTE", "Your chosen combo family gains +5 on future plays for the rest of the run.", "Mutation and relic affect BOTH players for the next round only.", "Route control alternates. You and CPU always choose your own combo upgrades."],
        ["FACE THE BOSS", "Boss rounds are rounds 3 and 5 at EVERY stage, including stage 3 onward.", "Read the boss rule in the intro or hover its banner. It affects both players.", "The penalty applies before Joker bonuses. Choose combos that avoid it."],
        ["SHOP AND OPEN PACKS", "Both players earn 8 credits each round. Credits carry over; points cannot buy items.", "Joker Pack: new Joker. Joker Upgrade: improve one you own. Combo Upgrade: boost a family.", "Preview tiers before paying. Choose one reward; skipping an opened pack gives no refund."],
        ["VARIANTS AND UPGRADES", "Hidden variants: Rare stage 2, Epic 3, Legendary 4, Mythic 6.", "Each base Joker has four variants. Find more as you go deeper; editions still apply.", "Edition bonuses need the Joker to activate. Replacing an edition removes its old effect."],
        ["KEEP YOUR RUN GOING", "Win a stage to continue with your Jokers, credits and upgrades. Losing ends the run.", "Quit and resume your saved run from the menu. Your high score is kept after losing.", "Later stages unlock packs and combos and increase CPU pressure. Check the Field Guide."]
	]
]

func draw_tutorial(g) -> void:
	g.menu_frame(Rect2(140,310,1160,500))
	var lesson: Array = LESSONS[tutorial_mode][tutorial_page]
	g.label_at(Vector2(180,363),("HELL DECK" if tutorial_mode==0 else "HELLATRO")+" / QUICK START",24,g.ORANGE)
	g.label_at(Vector2(180,405),"%d / %d   %s" % [tutorial_page+1,LESSONS[tutorial_mode].size(),lesson[0]],23,g.INK)
	for i in 3:
		var lines: Array[String] = []
		var line := ""
		for word in str(lesson[i+1]).split(" "):
			var candidate: String = line+(" " if line!="" else "")+word
			if g.font.get_string_size(candidate,HORIZONTAL_ALIGNMENT_LEFT,-1,17).x>570:
				lines.append(line)
				line = word
			else: line = candidate
		lines.append(line)
		for row in lines.size(): g.label_at(Vector2(180,455+i*53+row*21),lines[row],17,g.INK if i==0 else g.MUTED)
	draw_tutorial_example(g)
	for i in LESSONS[tutorial_mode].size(): g.draw_circle(Vector2(1060+i*20,360),5,g.ORANGE if i==tutorial_page else g.MUTED)
	g.button(Rect2(180,620,600,48),("[X]" if tutorial_disabled else "[ ]")+" DON'T SHOW TUTORIALS BEFORE PLAYING")
	g.button(Rect2(180,715,200,55),"BACK" if tutorial_page>0 else "MAIN MENU")
	g.button(Rect2(405,715,200,55),"SKIP")
	g.button(Rect2(920,715,330,55),"NEXT" if tutorial_page<LESSONS[tutorial_mode].size()-1 else ("LET'S PLAY" if tutorial_launch else "DONE"))

func finish_tutorial(g) -> void:
	g.mode_tutorials = not tutorial_disabled
	g.save_view_setting()
	if not tutorial_launch: g.modal = "home"
	elif tutorial_mode==0: choose_match(g)
	else: g.hell_meld.start(g)

func tutorial_click(g,pos: Vector2) -> void:
	if Rect2(180,620,600,48).has_point(pos):
		tutorial_disabled = not tutorial_disabled
		g.mode_tutorials = not tutorial_disabled
		g.save_view_setting()
	elif Rect2(180,715,200,55).has_point(pos):
		if tutorial_page>0:
			tutorial_page -= 1
			tutorial_started_at = g.clock
		else: g.modal = "home"
	elif Rect2(405,715,200,55).has_point(pos): finish_tutorial(g)
	elif Rect2(920,715,330,55).has_point(pos):
		if tutorial_page<LESSONS[tutorial_mode].size()-1:
			tutorial_page += 1
			tutorial_started_at = g.clock
		else: finish_tutorial(g)

func draw_monster(g, key: String, rect: Rect2) -> void:
	var frames: Array = g.art.textures.get(key,[])
	if frames.is_empty(): return
	var texture: Texture2D = frames[int(g.clock*4)%frames.size()]
	var size := texture.get_size()
	size *= minf(rect.size.x/size.x,rect.size.y/size.y)
	g.draw_texture_rect(texture,Rect2(rect.get_center()-size/2,size),false)

# Tutorial vignettes are presentation-only: they never play cards or change scores.
func example_card(g, art_key: String, name: String, center: Vector2, highlighted := false) -> void:
	var box := Rect2(center-Vector2(41,57),Vector2(82,114))
	g.draw_style_box(g.hell_meld.card_style(highlighted),box)
	g.label_at(box.position+Vector2(7,17),name,10,g.INK)
	draw_monster(g,art_key,Rect2(box.position+Vector2(10,23),Vector2(62,80)))

func draw_tutorial_example(g) -> void:
	var box := Rect2(800,420,450,265)
	g.draw_style_box(g.hell_meld.card_style(false),box)
	g.label_at(Vector2(818,444),"LIVE EXAMPLE / LOOPS",11,g.MUTED)
	var t: float = fposmod(g.clock-tutorial_started_at,5.0)
	var move: float = smoothstep(0.5,2.0,t)
	var settle: bool = t>2.0
	var caption := ""
	if tutorial_mode==0:
		match tutorial_page:
			0:
				g.draw_commander_portrait(Rect2(825,470,105,105),g.chosen_commander,g.ORANGE)
				for i in 3:
					var slide: float = smoothstep(i*0.35,1.5+i*0.35,t)
					example_card(g,["TROO","SARG","BOSS"][i],["IMP","PINKY","BARON"][i],Vector2(965+i*93,580-55*slide),settle)
				caption = "HERO + MONSTERS = YOUR DECK"
			1:
				for lane in 4:
					g.draw_rect(Rect2(821+lane*104,467,96,145),Color("284037"),false,2)
					g.label_at(Vector2(840+lane*104,484),"LANE %d" % (lane+1),10,g.MUTED)
				example_card(g,"TROO","IMP",Vector2(865,575).lerp(Vector2(1075,550),move),settle)
				caption = "DRAG A MONSTER INTO A LANE"
			2:
				var attack: float = sin(clampf((t-1.5)/0.7,0,1)*PI)*55
				draw_monster(g,"TROO",Rect2(840+attack,490,90,110))
				g.draw_commander_portrait(Rect2(1110,482,110,110),g.chosen_commander,g.ORANGE)
				if t>1.5 and t<2.4:
					var fire := Vector2(940,535).lerp(Vector2(1150,535),clampf((t-1.5)/0.9,0,1))
					g.draw_circle(fire,9,Color("ff672b"))
				g.draw_rect(Rect2(1105,603,120,9),Color("492222"))
				g.draw_rect(Rect2(1105,603,80 if t>2.4 else 120,9),Color("e1372b"))
				caption = "END TURN > ATTACK > ENEMY HP FALLS"
	else:
		match tutorial_page:
			0:
				example_card(g,"TROO","IMP",Vector2(895,560).lerp(Vector2(980,525),move),settle)
				example_card(g,"TROO","IMP",Vector2(1160,560).lerp(Vector2(1080,525),move),settle)
				caption = "TWO IMPS = MATCHING PAIR" if settle else "BRING MATCHING MONSTERS TOGETHER"
			1:
				if t<3.2:
					example_card(g,"TROO","IMP",Vector2(890,525),true)
					example_card(g,"TROO","IMP",Vector2(985,525),true)
					example_card(g,"TROO","+ IMP",Vector2(1190,575).lerp(Vector2(1080,525),move),settle)
					caption = "ADD AN IMP TO EXTEND THE PAIR"
				else:
					example_card(g,"SARG","DRAW",Vector2(1120,510).lerp(Vector2(950,560),smoothstep(3.2,4.3,t)))
					caption = "OR DRAW / PASS: TABLE CLEARS"
			2:
				g.hell_meld.support.card(g,g.hell_meld,56,Rect2(830,470,115,165),-1,false)
				example_card(g,"TROO","CPU PAIR",Vector2(1000,525),true)
				example_card(g,"TROO","+ IMP",Vector2(1190,590).lerp(Vector2(1120,525),move),settle)
				if settle: g.label_at(Vector2(1040,625),"RETURN SERVE +10",18,g.ORANGE)
				caption = "ONE CARD RETURN > TENNIS PINKY +10"
			3:
				for i in 3:
					var lit: bool = t>0.7+i*0.9
					g.draw_circle(Vector2(900+i*120,535),32,g.ORANGE if lit else Color("344140"))
					g.label_at(Vector2(890+i*120,544),str(i+1),24,g.INK)
				caption = "THREE ROUND WINS > NEXT STAGE"
			4:
				for i in 2:
					var r := Rect2(830+i*205,480,185,140)
					g.draw_rect(r,Color("162a28"))
					g.draw_rect(r,g.ORANGE if (t<2.5)==(i==0) else g.MUTED,false,2)
					g.label_at(r.position+Vector2(12,30),"YOU" if i==0 else "CPU",20,g.INK)
					g.label_at(r.position+Vector2(12,70),"MARCH +5" if i==0 else "PAIR +5",16,g.ORANGE)
					g.label_at(r.position+Vector2(12,108),"OWN UPGRADE",12,g.MUTED)
				caption = "SHARED BATTLEFIELD / SEPARATE UPGRADES"
			5:
				draw_monster(g,"FATT",Rect2(950,465+sin(t*3)*5,150,150))
				for i in 5:
					g.label_at(Vector2(870+i*65,635),str(i+1),22,g.ORANGE if i in [2,4] else g.MUTED)
				caption = "BOSS RULES ON ROUNDS 3 AND 5"
			6:
				for i in 3:
					g.hell_meld.progression.draw_pack_art(g,Rect2(837+i*135,470+sin(t*2+i)*4,105,157),i,0)
				caption = "NEW JOKER / JOKER BONUS / COMBO BONUS"
			7:
				var show_edition: int = 2 if t>2.5 else 0
				g.hell_meld.support.card(g,g.hell_meld,53,Rect2(945,460,140,190),-1,false,show_edition)
				caption = "NAMED VARIANT + OPTIONAL EDITION UPGRADE"
			8:
				for i in 3:
					var y := 590-i*40
					g.draw_rect(Rect2(845+i*125,y,110,45+i*40),Color("293c32"))
					g.label_at(Vector2(855+i*125,y+28),"STAGE "+str(i+1),14,g.INK)
					if t>i: g.draw_rect(Rect2(845+i*125,y,110,3),g.ORANGE)
				caption = "WIN > KEEP YOUR BUILD > CONTINUE"

	g.label_at(Vector2(818,665),caption,12,g.ORANGE)

func draw_cursors(g) -> void:
	var p = g.hell_meld.profile
	g.menu_frame(Rect2(90,280,1270,600))
	g.label_at(Vector2(140,325),"CURSOR COLLECTION",30,g.ORANGE)
	for i in 4:
		var id: String = ["default","baron","imp","doomguy"][i]
		var box := Rect2(120+i*305,350,285,380)
		var unlocked: bool = p.cursor_unlocked(id)
		var selected: bool = p.cursor_selected==id
		g.draw_rect(box,Color("101f22"))
		g.draw_rect(box,g.ORANGE if selected else g.MUTED,false,3)
		g.label_at(box.position+Vector2(24,44),id.to_upper(),24,g.INK)
		if i>0:
			g.draw_texture_rect(p.cursor_texture(id),Rect2(box.position+Vector2(62,70),Vector2(160,160)),false)
		else:
			g.label_at(box.position+Vector2(70,155),"SYSTEM",26,g.MUTED)
		g.label_at(box.position+Vector2(24,270),"EQUIPPED" if selected else "CLICK TO EQUIP" if unlocked else "LOCKED",22,g.ORANGE)
		g.label_at(box.position+Vector2(24,310),"Always available" if i in [0,3] else "Win a Hellatro stage" if i==1 else "Reach Hellatro stage 3",17,g.INK)
		g.label_at(box.position+Vector2(24,344),"Cosmetic / both modes",15,g.MUTED)
	g.button(Rect2(140,790,330,60),"BACK TO OPTIONS")

func show_scores(g) -> void:
	g.hell_meld.profile.ensure_loaded()
	scores_open = true
	at_home = true
	started = false
	g.ended = true
	g.modal = "home"
	leaderboard.name_text = g.hell_meld.profile.score_name
	leaderboard.randomize_portraits(g)
