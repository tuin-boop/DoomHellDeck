extends Node2D
const Weapons = preload("res://scripts/weapons.gd")

const Commanders = preload("res://scripts/commanders.gd")
const COMMANDER_BUTTON := Rect2(53,125,150,160)
var commander_rng := RandomNumberGenerator.new()
var chosen_commander := Commanders.DEFAULT
var player_commander := Commanders.DEFAULT
var enemy_commander := "ashfang"
var commander_draft := Commanders.DEFAULT
var commander_selected := false
var initial_commander_choice := false
var frontend = preload("res://scripts/frontend.gd").new()
var master_volume := 0.8
var fullscreen := false
var joker_reminders := true
var mode_tutorials := true
var screen_shake := true
var gibs_enabled := true

const Cards = preload("res://scripts/cards.gd")
var match_flair = preload("res://scripts/match_flair.gd").new()
var battle_tools = preload("res://scripts/battle_tools.gd").new()
const Squads = preload("res://scripts/squads.gd")
const COMBOS_BUTTON := Rect2(1190,740,208,42)
const WadArt = preload("res://scripts/wad_art.gd")
const Table = preload("res://scripts/table.gd")
const BACKGROUND = preload("res://assets/backgrounds/hellscape.png")
const INK := Color("e5e0cf")
const MUTED := Color("899493")
const ORANGE := Color("ff8e42")
const RARITY := [Color("9da992"), Color("48a9ff"), Color("c36aff"), Color("ffcc65"),Color("ff5268"),Color("76ffe5")]
const RARITY_NAMES := ["COMMON", "RARE", "EPIC", "LEGENDARY","ELITE","MYTHIC"]
const MENU_BUTTON := Rect2(1240,158,154,38)
const ARMORY_BUTTON := Rect2(1240,32,154,42)
const BATTLE_VIEW_BUTTON := Rect2(1190,682,208,44)
const END_BUTTON := Rect2(1190,550,208,64)
const SURGE_BUTTON := Rect2(35,605,196,42)
const REVIVE_BUTTON := Rect2(35,654,196,42)
const PLAY_AREA := Rect2(290,140,840,512)
const TYPE_COLORS := {"ICE":Color("9deaff"),"FIRE":Color("ff8d49"),"ENERGY":Color("6cdeff"),"BULLET":Color("f3d68f"),"ROCKET":Color("f18b79"),"MELEE":Color("c8cbb7"),"EVENT":Color("9dd3a1")}
var font: FontFile = preload("res://assets/fonts/Tiny5.ttf")
var art = WadArt.new()
var table = Table.new()
var friendly: Array = [{},{},{},{}]
var enemy: Array = [{},{},{},{}]
var hand: Array = []
# Per-hand-copy reminders; identical monsters can be marked independently.
var squad_marks: Dictionary = {}
var deck: Array = []
var discard: Array = []
var grave: Array = []
const DeckRules = preload("res://scripts/deck_rules.gd")
const DeckBook = preload("res://scripts/deck_book.gd")
var deck_book = DeckBook.new()
var editing_deck := 0
var deck_message := ""
var deleting_deck := -1
var naming_deck := -1
var name_input: LineEdit
const DECKS_BUTTON := Rect2(1060,28,300,52)
var decklist: Array = Cards.STARTER.duplicate()
var collection: Array = []
var collection_page := 0
var pack_only := false
var deck_only := false
const DECK_FILTER := Rect2(1060,90,300,44)
var combo_page := 0
var armory_combo_filter := -1
const DECK_COMBOS_BUTTON := Rect2(1060,747,300,44)
const PACK_FILTER := Rect2(758,819,160,55)
const COLLECTION_PAGE_SIZE := 12
const PREVIOUS_PAGE := Rect2(940,819,140,55)
const NEXT_PAGE := Rect2(1220,819,140,55)
var selected := -1
var drag_index := -1
var dragging := false
var press_position := Vector2.ZERO
var drag_position := Vector2.ZERO
var toast_time := 0.0
var hovered := -1
var player_hp := 30
var enemy_hp := 30
var energy := 3
var max_energy := 3
var souls := 0
var turn := 1
var wins := 0
var credits := 0
var kills := 0
const EnemyAI = preload("res://scripts/enemy_ai.gd")
var enemy_energy := 3
var enemy_hand: Array = []
var enemy_deck: Array = []
var enemy_discard: Array = []
var enemy_spent := 0
var cpu_support: Dictionary = {}
var cpu_support_progress := 0.0
var enemy_plays := 0
var busy := false
var ended := false
var won := false
var modal := ""
var rewards: Array = []
var reward_claimed := false
var next_random_mode := false
var random_mode := false
var feed: Array[String] = []
var clock := 0.0
var moving_side := -1
var moving_lane := -1
var moving_offset := Vector2.ZERO
var hit_side := -1
var hit_lane := -1
var hit_flash := 0.0
var particles: Array = []
var numbers: Array = []
var projectile := Vector2(-100,-100)
var projectile_type := ""
var projectile_art := ""
var attack_started := 0.0
var minigun_firing := false
var attack_pose_duration := 0.6
var sprite_effects: Array = []
var cinematic_enabled := true
var duel_splash_targets: Array = []
var duel_active := false
var duel_mix := 0.0
var duel_target_lane := -1
var duel_defender := -1
var duel_attacker := -1
var duel_start := Vector2.ZERO
var duel_finish := Vector2.ZERO
var duel_struck := false
var counter_animating := false
var counter_offset := Vector2.ZERO
var counter_pose_started := 0.0
var counter_finished_at := -1.0
var duel_attacker_unit: Dictionary = {}
var duel_defender_unit: Dictionary = {}
var counter_visual_unit: Dictionary = {}
var counter_visual_id := -1
var counter_visual_lane := -1
var counter_visual_active := false
var pending_counter_death: Dictionary = {}
var projectile_side := 0
var retaliation_started := -1.0
var duel_impact_time := 0.0
var duel_attacking := false
var charge := 0.0
var entrance := 0.0
var arrival := 0.0
var arrival_rarity := 0
var arrival_center := Vector2.ZERO
var slam_lane := -1
var slam := 0.0
var audio = preload("res://scripts/doom_audio.gd").new()
var battle_voice = preload("res://scripts/battle_voice.gd").new()
var hero_power = preload("res://scripts/hero_power.gd").new()
var hero_feedback = preload("res://scripts/hero_feedback.gd").new()
var scenery_animation = preload("res://scripts/scenery_animation.gd").new()
var ui_help = preload("res://scripts/ui_help.gd").new()
var radio = preload("res://scripts/radio.gd").new()
var hell_meld = preload("res://scripts/hell_meld.gd").new()
var rng := RandomNumberGenerator.new()
const DrawDirector = preload("res://scripts/draw_director.gd")
var player_director = DrawDirector.new()
var cpu_director = DrawDirector.new()

func _ready() -> void:
	ui_help.game = self
	add_child(ui_help)
	add_child(scenery_animation)
	rng.randomize()
	commander_rng.randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Keep the pixel-shaped glyphs readable at resized window scales and on tilted cards.
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	font.hinting = TextServer.HINTING_NONE
	font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	add_child(table)
	table.hide()
	add_child(audio)
	var wad_path := "C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/doom2/DOOM2.WAD"
	if FileAccess.file_exists("res://assets/runtime/DOOM2.WAD"):
		wad_path = "res://assets/runtime/DOOM2.WAD"
	elif FileAccess.file_exists(OS.get_executable_path().get_base_dir().path_join("DOOM2.WAD")):
		wad_path = OS.get_executable_path().get_base_dir().path_join("DOOM2.WAD")
	if OS.has_environment("DOOM_WAD"):
		wad_path = OS.get_environment("DOOM_WAD")
	if not art.load_wad(wad_path):
		art.load_wad("C:/Program Files (x86)/Steam/steamapps/common/Ultimate Doom/base/DOOM.WAD")
	art.load_selected_pack()
	art.load_selected_pack("res://assets/wolf_bosses/manifest.json")
	art.load_selected_pack("res://assets/daisy/manifest.json")
	audio.monster_sounds = art.monster_sounds
	audio.sounds = art.sounds
	art.textures["CARMACK"] = [preload("res://assets/cards/carmack-head.png")]
	art.textures["ROMERO"] = [preload("res://assets/cards/romero-head.png")]
	for i in Cards.CATALOG_SIZE:
		collection.append(3)
	load_progress()
	load_view_setting()
	add_child(radio)
	battle_voice.glyphs = art.font_glyphs
	battle_voice.fallback = font
	battle_voice.game = self
	add_child(battle_voice)
	hero_power.game = self
	hero_power.z_index = 9
	add_child(hero_power)
	hero_feedback.game = self
	hero_feedback.z_index = 11
	add_child(hero_feedback)
	new_battle()
	if not ("--balance-test" in OS.get_cmdline_user_args() or "--smoke-test" in OS.get_cmdline_user_args() or "--capture" in OS.get_cmdline_user_args()):
		frontend.started = false
		frontend.at_home = true
		modal = "home"
	if "--smoke-test" in OS.get_cmdline_user_args():
		run_smoke_test.call_deferred()
	if "--capture" in OS.get_cmdline_user_args():
		capture.call_deferred()

func new_battle() -> void:
	reward_claimed = false
	random_mode = next_random_mode
	duel_splash_targets.clear()
	match_flair.reset()
	frontend.started = true
	frontend.at_home = false
	battle_tools.reset(not ("--balance-test" in OS.get_cmdline_user_args() or "--smoke-test" in OS.get_cmdline_user_args() or "--capture" in OS.get_cmdline_user_args()))
	hero_feedback.reset()
	hero_power.reset()
	counter_visual_active = false
	pending_counter_death.clear()
	player_commander = chosen_commander
	enemy_commander = Commanders.opponent(player_commander,commander_rng)
	battle_voice.reset(enemy_commander)
	counter_animating = false
	counter_offset = Vector2.ZERO
	cpu_support.clear()
	duel_active = false
	duel_mix = 0.0
	projectile = Vector2(-100,-100)
	sprite_effects.clear()
	player_director.reset(randi())
	cpu_director.reset(randi())
	friendly = [{},{},{},{}]
	enemy = [{}, {}, {}, {}]
	deck = random_match_deck() if random_mode else deck_book.battle_cards()
	deck.shuffle()
	hand.clear()
	squad_marks.clear()
	discard.clear()
	grave.clear()
	feed.clear()
	player_hp = 30
	enemy_hp = 30 if random_mode else 30 + mini(wins,5)*2
	max_energy = 3
	energy = 3
	souls = 0
	turn = 1
	selected = -1
	cancel_drag()
	busy = false
	ended = false
	won = false
	modal = ""
	for i in 5:
		draw_card()
	enemy_energy = 3
	enemy_hand.clear()
	enemy_discard.clear()
	enemy_deck = random_match_deck() if random_mode else EnemyAI.deck_for(wins)
	enemy_deck.shuffle()
	enemy_spent = 0
	enemy_plays = 0
	for i in 5:
		draw_enemy_card()
	log_line("Reduce the enemy's Health to zero.")
	if battle_tools.pending: modal = "mulligan"

func random_match_deck() -> Array:
	var result: Array = []
	for slot in 20: result.append(rng.randi_range(0,Cards.CATALOG_SIZE-1))
	return result

func draw_card() -> void:
	if hand.size() >= 6:
		return
	if deck.is_empty():
		deck = discard.duplicate()
		discard.clear()
		grave.clear()
		deck.shuffle()
	if not deck.is_empty():
		hand.append(deck.pop_back() if random_mode else player_director.take(deck,hand,turn==1,turn,enemy_hp-player_hp))

func log_line(message: String) -> void:
	battle_tools.record(turn,message)
	toast_time = 3.0
	feed.push_front(message)
	if feed.size() > 7:
		feed.pop_back()

func lane_rect(side: int, lane: int) -> Rect2:
	return Rect2(303 + lane * 208, 151 if side == 1 else 420, 178, 215)

func hand_rect(index: int) -> Rect2:
	var middle := float(hand.size()-1)/2.0
	return Rect2(720-84+(index-middle)*155,694+absf(index-middle)*5,168,210)

func panel(rect: Rect2, color: Color, border: Color = Color("384140")) -> void:
	draw_rect(rect, color)
	draw_rect(rect, border, false, 1.0)

func label_at(pos: Vector2, text: String, size := 16, color := INK) -> void:
	if size>=28 and text.to_upper()!=text.to_lower() and not art.font_glyphs.is_empty():
		var title := text.to_upper()
		var scale_value: float = minf(size/10.0,font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x/maxf(1,battle_voice.width(title,1)))
		var x := pos.x
		for character in title:
			if art.font_glyphs.has(character):
				var glyph: Texture2D = art.font_glyphs[character]
				var rect := Rect2(Vector2(x,pos.y-glyph.get_height()*scale_value),glyph.get_size()*scale_value)
				draw_texture_rect(glyph,Rect2(rect.position+Vector2(2,3),rect.size),false,Color(0,0,0,color.a))
				draw_texture_rect(glyph,rect,false,Color(1,1,1,color.a))
				x += (glyph.get_width()+1)*scale_value
			else: x += 5*scale_value
		return
	draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 2, Color(0.015,0.02,0.02,color.a*0.8))
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func text_width(text: String, size: int) -> float:
	return font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x

func button(rect: Rect2, text: String, active := true) -> void:
	var hover := rect.has_point(get_global_mouse_position()) and not busy
	panel(rect, Color("693c26") if hover and active else Color("1b2529"), ORANGE if active else Color("475150"))
	ui_help.offer(rect,text,ui_help.button_help(text)+( " Currently unavailable." if not active else ""))
	if active:
		var glow := Color(1,0.55,0.2,0.12 if hover else 0.025)
		draw_rect(rect.grow(3),glow,false,3)
		var travel := fposmod(clock*75+rect.position.x,rect.size.x)
		draw_line(rect.position+Vector2(travel,0),rect.position+Vector2(minf(rect.size.x,travel+35),0),Color(1,0.8,0.4,0.85 if hover else 0.25),2)
		if hover:
			for corner in [rect.position,rect.end]:
				var direction: Vector2 = (rect.get_center()-corner).sign()
				draw_line(corner,corner+Vector2(direction.x*15,0),Color("ffe5a1"),3)
	var font_size := 18
	while text_width(text,font_size) > rect.size.x-30 and font_size > 11:
		font_size -= 1
	label_at(rect.position + Vector2(15,rect.size.y/2+6), text, font_size, INK if active else MUTED)

func _process(delta: float) -> void:
	radio.update_context(self)
	match_flair.tick(self,delta)
	hell_meld.tick(self,delta)
	scenery_animation.update_effects(match_flair)
	if battle_tools.pending and modal=="": modal = "mulligan"
	battle_voice.visible = modal in ["","reward","defeat","draw"] and not hero_power.armed and not targeting_weapon()
	battle_voice.set_process(battle_voice.visible)
	clock += delta
	for effect in sprite_effects:
		effect.age += delta
	sprite_effects = sprite_effects.filter(func(effect): return effect.age < effect.duration)
	toast_time = maxf(0,toast_time-delta)
	hit_flash = maxf(0, hit_flash - delta * 4)
	entrance = maxf(0, entrance - delta * 0.5)
	arrival = maxf(0,arrival-delta)
	slam = maxf(0, slam - delta * 2.8)
	for p in particles:
		p.pos += p.vel * delta
		p.vel.y += 160 * delta
		p.life -= delta
	particles = particles.filter(func(p): return p.life > 0)
	for n in numbers:
		n.pos.y -= delta * 35
		n.life -= delta
	numbers = numbers.filter(func(n): return n.life > 0)
	queue_redraw()

func _draw() -> void:
	ui_help.reset()
	# Keep the supplied pixel artwork intact and fill the viewport without stretching it.
	# Animated scenery is drawn by the masked background layer behind the table.
	draw_rect(Rect2(0,0,1440,940),Color(0.01,0.014,0.022,0.38))
	match_flair.draw_toys(self)
	for i in 16:
		var mote := Vector2(fmod(i*137.0+sin(clock*0.25+i)*30,1440),fmod(i*83.0-clock*7+1880,940))
		draw_circle(mote,1.3,Color(1,0.48,0.16,0.16))
	if modal=="radio":
		radio.draw(self)
		return
	if modal=="hell_meld":
		hell_meld.draw(self)
		return
	if frontend.at_home or modal in ["home","options","new_match","leave_match","mode_tutorial"]:
		frontend.draw(self)
		if modal not in ["home","options","new_match","leave_match","mode_tutorial"]: draw_modal()
		return
	button(MENU_BUTTON,"MENU",not busy)
	label_at(Vector2(34,66),"DOOM",42,Color("bb5843"))
	label_at(Vector2(39,92),"H E L L   D E C K",13,MUTED)
	button(ARMORY_BUTTON,"ARMORY")
	if (not battle_voice.visible or battle_voice.speech_age>=5.5) and not (hero_power.active and hero_power.side==1):
		draw_commander_portrait(Rect2(Vector2(444,16)+hero_feedback.offset(1),Vector2(88,88)),enemy_commander,Color("e57968"))
	var opponent_name: String = Commanders.entry(enemy_commander).name
	label_at(Vector2(720-font.get_string_size(opponent_name,HORIZONTAL_ALIGNMENT_LEFT,-1,20).x/2,37),opponent_name,20,Color("f5b5a0"))
	if not (hero_power.active and hero_power.side==0):
		draw_set_transform(Vector2(128,185)+hero_feedback.offset(0),hero_feedback.ready_tilt())
		draw_commander_portrait(Rect2(-60,-60,120,120),player_commander,Color("8ec5ad") if hero_power.available() else MUTED)
		draw_set_transform(Vector2.ZERO)
	var player_name: String = Commanders.entry(player_commander).name
	label_at(Vector2(128-font.get_string_size(player_name,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x/2,265),player_name,18,INK)
	label_at(Vector2(65,284),"CHANGE CHARACTER",12,ORANGE)
	draw_rect(Rect2(549,55,342,8),Color("24191a"))
	draw_rect(Rect2(549,55,342*clampf(float(enemy_hp)/(30+mini(wins,5)*2),0,1),8),Color("ba5744"))
	label_at(Vector2(647,88),"HEALTH %02d" % maxi(0,enemy_hp),20,Color("f5b5a0"))
	# Stencilled centerline and recessed lane corners, not dashboard boxes.
	draw_line(Vector2(290,393),Vector2(1123,393),Color("5b5541"),1)
	for i in 4:
		label_at(Vector2(383+i*208,401),str(i+1),13,Color("b6a477"))
		for side in 2:
			var rect := lane_rect(side,i)
			var units: Array = enemy if side == 1 else friendly
			var legal: bool = side == 0 and selected >= 0 and selected < hand.size() and (units[i].is_empty() or Squads.can_reinforce(units[i],hand[selected])) and Cards.DATA[hand[selected]].hp > 0 and can_afford(hand[selected])
			var over: bool = legal and rect.has_point(drag_position if dragging else get_global_mouse_position())
			var tint := Color("dfb96c") if legal else Color("505954")
			draw_rect(rect,Color(0.015,0.025,0.025,0.25))
			if over:
				draw_rect(rect.grow(6),Color(0.9,0.65,0.25,0.12+0.04*sin(clock*7)))
			for corner in [rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]:
				var direction: Vector2 = (rect.get_center()-corner).sign()
				draw_line(corner,corner+Vector2(direction.x*22,0),tint,2)
				draw_line(corner,corner+Vector2(0,direction.y*22),tint,2)
			if units[i].is_empty():
				if legal:
					label_at(rect.position+Vector2(46,115),"RELEASE" if over and dragging else "+",18 if over and dragging else 28,tint)
			else:
				var offset := moving_offset if moving_side == side and moving_lane == i else Vector2.ZERO
				if side == 0 and slam_lane == i and slam > 0:
					offset.y -= sin(slam*PI)*38
				offset += unit_hit_offset(units[i])
				if (not duel_active or duel_mix < 0.45) and not (counter_visual_active and side==1-moving_side and i==counter_visual_lane):
					card(rect,units[i].id,units[i],false,offset,0.0,false,clock-attack_started if duel_attacking and moving_side==side and moving_lane==i else -1.0)
				if not duel_active and unit_hit_strength(units[i]) > 0:
					draw_rect(rect,Color(1,0.5,0.2,unit_hit_strength(units[i])*0.35))
				if legal and dragging:
					draw_rect(rect.grow(4),Color("9df6b7"),false,3.0+sin(clock*5.0))
					panel(Rect2(rect.position+Vector2(6,-25),Vector2(rect.size.x-12,24)),Color("162d24"),Color("9df6b7"))
					label_at(rect.position+Vector2(15,-8),"CAN REINFORCE",13,Color("9df6b7"))
				if over:
					panel(Rect2(rect.position+Vector2(10,92),Vector2(rect.size.x-20,30)),Color("162d24"),Color("9df6b7"))
					label_at(rect.position+Vector2(22,113),"REINFORCE +",16,Color("9df6b7"))
	# Gauges live in the left table rail.
	gauge(Vector2(128,354),player_hp,30,"HEALTH",Color("8ec5ad"))
	gauge(Vector2(128,495),energy,max_energy,"ENERGY",ORANGE)
	label_at(Vector2(74,595),"%02d  SOULS" % souls,21,Color("c36aff"))
	button(SURGE_BUTTON,"SURGE  /  3 SOULS",souls >= 3 and not ended)
	if has_arch_vile():
		button(REVIVE_BUTTON,"REVIVE  /  3 SOULS",can_revive())
	# Compact opponent resources beside the portrait, away from the menu rail.
	label_at(Vector2(310,43),"ENERGY %d/%d" % [enemy_energy,max_energy],14,ORANGE)
	label_at(Vector2(310,65),"SOULS %d" % hero_power.cpu_souls,14,Color("c36aff"))
	if hero_power.used[1]:
		label_at(Vector2(310,87),"POWER USED",11,MUTED)
	elif hero_power.cpu_souls >= 5:
		label_at(Vector2(310,87),"POWER READY",11,Color("c36aff"))
	label_at(Vector2(1190,446),"HELL COLLAPSE",15,ORANGE)
	label_at(Vector2(1170,468),"IN %d ROUNDS / BOTH HEROES" % (15-turn) if turn<15 else "BOTH HEROES: -%d HEALTH" % mini(5,1+int((turn-15)/3)),12,MUTED if turn<15 else ORANGE)
	if Rect2(1160,428,245,52).has_point(get_global_mouse_position()):
		label_at(Vector2(490,679),"From round 15, both heroes lose Health each round. Damage rises from 1 to 5.",13,ORANGE)
	label_at(Vector2(1220,506),"ROUND %02d" % turn,17,MUTED)
	button(COMBOS_BUTTON,"SQUADS / LEVELS")
	button(battle_tools.HISTORY_BUTTON,"COMBAT HISTORY",not busy)
	button(BATTLE_VIEW_BUTTON,"BATTLE VIEW: "+("ON" if cinematic_enabled else "OFF"),not busy)
	button(END_BUTTON,"ATTACKING..." if busy else "END TURN",not busy and not ended)
	label_at(Vector2(1245,640),"[ SPACE ]",12,MUTED)
	# The physical draw pile replaces the deck counter in a sidebar.
	for i in range(4,-1,-1):
		var back := Rect2(46+i*2,752-i*3,106,137)
		panel(back,Color("222b29"),Color("59635b"))
		if i == 0:
			draw_arc(back.get_center(),28,0,TAU,6,Color("786c46"),2)
			label_at(back.get_center()+Vector2(-19,6),"UAC",18,MUTED)
	label_at(Vector2(45,932),"DIRECTOR ON",11,MUTED)
	label_at(Vector2(53,916),"%02d IN DECK" % deck.size(),13,MUTED)
	var squad_hints: Dictionary = Squads.hand_hints(friendly,hand,energy,souls) if modal=="" and not busy and not ended and not dragging else {"available":{},"playable":{}}
	var top_card := -1
	for i in range(hand.size()-1,-1,-1):
		if hand_rect(i).has_point(get_global_mouse_position()):
			top_card = i
			break
	for i in hand.size():
		if dragging and drag_index == i:
			continue
		if i == top_card:
			continue
		card(hand_rect(i),hand[i],{},selected == i,Vector2.ZERO,(i-float(hand.size()-1)/2)*0.018,not can_afford(hand[i]),-1.0,squad_marks.has(i),squad_hints.playable.has(i),squad_hints.available.has(i))
	if top_card >= 0 and not (dragging and drag_index == top_card):
		card(hand_rect(top_card),hand[top_card],{},selected == top_card,Vector2.ZERO,0.0,not can_afford(hand[top_card]),-1.0,squad_marks.has(top_card),squad_hints.playable.has(top_card),squad_hints.available.has(top_card))
	label_at(Vector2(517,938),"DRAG TO PLAY / REINFORCE   /   RIGHT CLICK: MARK FOR SQUAD",12,MUTED)
	if not feed.is_empty() and toast_time > 0 and not dragging and not hero_power.armed and not Rect2(62,120,132,148).has_point(get_global_mouse_position()) and not Rect2(1160,428,245,52).has_point(get_global_mouse_position()):
		var message: String = feed[0]
		var width := text_width(message,14)
		label_at(Vector2(720-width/2,679),message,14,Color(INK,minf(1,toast_time)))
	var preview_id := inspected_card()
	if preview_id >= 0 and not dragging and not duel_active:
		draw_inspector(preview_id)
	elif SURGE_BUTTON.has_point(get_global_mouse_position()):
		label_at(Vector2(37,710),"Spend 3 Souls: +2 Energy",14,INK)
	if dragging and drag_index >= 0 and drag_index < hand.size():
		if Cards.DATA[hand[drag_index]].hp == 0 and not targeting_weapon():
			draw_rect(PLAY_AREA,Color(0.35,0.7,0.6,0.08))
			label_at(Vector2(558,395),"RELEASE ON TABLE TO CAST",18,INK)
		card(Rect2(drag_position-Vector2(84,112),Vector2(168,210)),hand[drag_index],{},true,Vector2.ZERO,0.0,false,-1.0,squad_marks.has(drag_index))
		draw_reinforcement_preview(hand[drag_index])
	if entrance > 0:
		for i in 11:
			var start := Vector2(90+i*108,660)
			draw_line(start,start+Vector2(30*sin(i*5),-90-60*sin(i)),Color(1,0.13,0.02,entrance),3)
		label_at(Vector2(502,117),"TITAN SIGNATURE DETECTED",20,Color(1,0.55,0.2,entrance))
	if duel_active:
		draw_duel()
	if projectile.x > 0:
		var color: Color = TYPE_COLORS.get(projectile_type,ORANGE)
		for i in 6:
			var trail := Vector2((-1 if projectile_side==0 else 1)*i*5,0) if duel_active else Vector2(0,(1 if projectile_side==0 else -1)*i*5)
			draw_circle(projectile+trail,float(12-i),Color(color,0.12))
		var projectile_frames: Array = (art.side_effect_textures if duel_active else art.effect_textures).get(projectile_art,[])
		if not projectile_frames.is_empty():
			draw_effect_sprite(projectile_art,0 if projectile_art=="MISL" else int((clock-attack_started)*18)%(projectile_frames.size() if projectile_art.begins_with("MMM_SHOT_") else mini(2,projectile_frames.size())),projectile,48)
		elif projectile_type == "ROCKET":
			var direction := -1.0 if projectile_side == 0 else 1.0
			draw_colored_polygon(PackedVector2Array([projectile+Vector2(0,direction*15),projectile+Vector2(-6,0),projectile+Vector2(-6,-direction*10),projectile+Vector2(6,-direction*10),projectile+Vector2(6,0)]),Color("c8cab9"))
			draw_line(projectile-Vector2(0,direction*10),projectile-Vector2(0,direction*32),ORANGE,6)
		elif projectile_type == "BULLET":
			var streak := Vector2(23,0) if duel_active else Vector2(0,23)
			draw_line(projectile-streak,projectile+streak,Color(1,0.65,0.15,0.35),10)
			draw_line(projectile-streak,projectile+streak,Color("fff5ba"),4)
		else:
			draw_circle(projectile,8,color)
			draw_circle(projectile,3,Color.WHITE)
	for effect in sprite_effects:
		var frame: int = effect.first+mini(effect.count-1,int(effect.age/effect.duration*effect.count))
		draw_effect_sprite(effect.key,frame,effect.pos,effect.size)
	if charge > 0:
		draw_circle(Vector2(720,393),charge*105,Color(0.4,1,0.25,0.1))
		draw_arc(Vector2(720,393),charge*95,0,TAU,64,Color("b9ff61"),3)
	for p in particles:
		draw_rect(Rect2(p.pos,Vector2.ONE*p.size),Color(p.color,minf(1,p.life*2)))
	if arrival > 0:
		for i in (6 if arrival_rarity == 5 else 3):
			var hue: Color = Color.from_hsv(fmod(clock*0.2+i*0.14,1),0.65,1) if arrival_rarity == 5 else RARITY[arrival_rarity]
			draw_arc(arrival_center,35+(1.2-arrival)*140+i*8,clock+i,clock+i+PI*1.2,40,Color(hue,arrival*0.45),2)
	for n in numbers:
		label_at(n.pos,n.text,27,Color(n.color,minf(1,n.life*2)))
	if counter_visual_active and not duel_active:
		# Keep the same defender visible from impact through recovery, even if lethal.
		card(lane_rect(1-moving_side,counter_visual_lane),counter_visual_id,counter_visual_unit,false,counter_offset+unit_hit_offset(counter_visual_unit),0.0,false,clock-counter_pose_started if counter_animating else -1.0)
	if not cpu_support.is_empty():
		draw_cpu_support()
	if modal != "":
		draw_modal()

func has_arch_vile() -> bool:
	return friendly.any(func(unit): return not unit.is_empty() and Cards.base_id(unit.id) == 7)

func gauge(center: Vector2, value: int, maximum: int, title: String, color: Color) -> void:
	draw_circle(center+Vector2(3,5),51,Color(0,0,0,0.7))
	draw_circle(center,51,Color("181e1e"))
	draw_arc(center,50,0,TAU,64,Color("535c55"),3)
	draw_arc(center,43,-PI*0.5,-PI*0.5+TAU*clampf(float(value)/maximum,0.001,1),64,color,4)
	var text := "%d/%d" % [value,maximum] if title == "ENERGY" else str(maxi(0,value))
	var text_size := 25 if title == "ENERGY" else 34
	label_at(center+Vector2(-text_width(title,12)/2,-15),title,12,color)
	label_at(center+Vector2(-text_width(text,text_size)/2,20),text,text_size,INK)

func inspected_card() -> int:
	if modal != "":
		return -1
	var mouse := get_global_mouse_position()
	for i in range(hand.size()-1,-1,-1):
		if hand_rect(i).has_point(mouse):
			return hand[i]
	for side in 2:
		var row: Array = friendly if side == 0 else enemy
		for i in 4:
			if lane_rect(side,i).has_point(mouse) and not row[i].is_empty():
				return row[i].id
	return hand[selected] if selected >= 0 and selected < hand.size() else -1

func inspected_unit_location() -> Vector2i:
	var mouse := get_global_mouse_position()
	for i in range(hand.size()-1,-1,-1):
		if hand_rect(i).has_point(mouse): return Vector2i(-1,-1)
	for side in 2:
		var row: Array = friendly if side==0 else enemy
		for lane in 4:
			if not row[lane].is_empty() and lane_rect(side,lane).has_point(mouse): return Vector2i(side,lane)
	return Vector2i(-1,-1)

func paragraph(pos: Vector2, text: String, width: float, size: int, color: Color) -> float:
	var line := ""
	var y := pos.y
	for word in text.split(" "):
		var candidate := word if line.is_empty() else line+" "+word
		if text_width(candidate,size) > width and not line.is_empty():
			label_at(Vector2(pos.x,y),line,size,color)
			y += size+6
			line = word
		else:
			line = candidate
	label_at(Vector2(pos.x,y),line,size,color)
	return y+size+6

func draw_inspector(id: int) -> void:
	var data: Dictionary = Cards.DATA[id]
	var color: Color = TYPE_COLORS.get(data.type,INK)
	var inspected := inspected_unit_location()
	var shown_attack: int = data.atk
	if inspected.x>=0:
		shown_attack = Squads.attack_value(friendly if inspected.x==0 else enemy,inspected.y)
	draw_tactical_inspector(id)
	panel(Rect2(1150,138,262,322),Color(0.025,0.038,0.04,0.94),Color("4a504a"))
	label_at(Vector2(1166,163),RARITY_NAMES[data.rarity]+(" / "+Cards.DATA[Cards.base_id(id)].name if data.has("base_id") else ""),11,RARITY[data.rarity])
	label_at(Vector2(1166,190),data.name,20,INK)
	label_at(Vector2(1166,223),(("%d X %d " % [data.weapon_shots,shown_attack] if data.get("weapon_shots",1)>1 else "%d " % shown_attack) if data.hp > 0 or data.get("targeted",false) else "")+data.type+(" DAMAGE" if data.hp > 0 or id == 9 or data.get("targeted",false) else ""),17,color)
	var y := paragraph(Vector2(1166,253),data.ability,228,13,INK)+7
	if data.hp > 0:
		y = paragraph(Vector2(1166,y),"WEAK TO  "+(data.weak+"  (+%d)" % Cards.weakness_bonus(data.weak) if data.weak != "" else "NONE"),228,14,Color("e9987d"))
		y = paragraph(Vector2(1166,y),"RESISTS  "+(resistance_text(data)),228,14,Color("a8c0b4"))
	if data.hp > 0:
		label_at(Vector2(1166,409),"AMBUSH: FIRST END TURN" if data.get("ambush",false) else "ATTACKS FROM NEXT TURN",12,MUTED)
	label_at(Vector2(1166,433),"%d ENERGY" % data.cost+(" + %d SOULS" % data.soul_cost if data.has("soul_cost") else ""),13,MUTED)

func resistance_text(data: Dictionary) -> String:
	var types: Array = []
	for key in ["resist","extra_resist"]:
		if data.get(key,"") != "":
			types.append(data[key])
	return " / ".join(types)+" (-1)" if not types.is_empty() else "NONE"

func displayed_attack(unit: Dictionary, id: int) -> int:
	if not unit.is_empty():
		for row in [friendly,enemy]:
			for lane in 4:
				if is_same(row[lane],unit):
					return Squads.attack_value(row,lane)
	return Cards.DATA[id].atk

func draw_level_trim(bounds: Rect2, data: Dictionary, unit: Dictionary, glow: Color) -> void:
	if data.hp<=0:
		return
	var pos := bounds.position
	panel(Rect2(pos+Vector2(10,76),Vector2(49,19)),Color("10191d"),glow)
	label_at(pos+Vector2(15,90),"LV %d" % data.level,12,glow)
	if unit.get("reinforced",false):
		label_at(pos+Vector2(12,109),"SQUAD x2",11,Color("9df6b7"))
	var linked := false
	if not unit.is_empty():
		for row in [friendly,enemy]:
			for lane in 4:
				if is_same(row[lane],unit) and (Squads.bonus(row,lane,"attack")+Squads.bonus(row,lane,"breach")>0):
					linked = true
					glowing_squad_text(pos+Vector2(12,126),"SQUAD +1",11,Color("e8a9ff"),true)
	if unit.get("chilled",false):
		label_at(pos+Vector2(12,143),"CHILLED -1",11,Color("9deaff"))
	if linked:
		draw_rect(bounds.grow(5),Color(Color.from_hsv(fposmod(clock*0.18,1.0),0.65,1.0),0.22+0.08*sin(clock*4)),false,5.0)
	if data.level==10 or linked:
		var perimeter := 2*(bounds.size.x+bounds.size.y)
		for i in 64:
			var distance := fmod(i*perimeter/64+clock*65,perimeter)
			var point := bounds.position
			if distance<bounds.size.x:
				point.x += distance
			elif distance<bounds.size.x+bounds.size.y:
				point += Vector2(bounds.size.x,distance-bounds.size.x)
			elif distance<2*bounds.size.x+bounds.size.y:
				point += Vector2(2*bounds.size.x+bounds.size.y-distance,bounds.size.y)
			else:
				point.y += perimeter-distance
			draw_rect(Rect2(point-Vector2(2,2),Vector2(4,4)),Color.from_hsv(fmod(float(i)/64+clock*0.2,1),0.75,1))

func draw_tactical_inspector(id: int) -> void:
	var data: Dictionary = Cards.DATA[id]
	if data.hp<=0:
		return
	panel(Rect2(28,132,246,153),Color(0.025,0.038,0.04,0.95),Color("596854"))
	label_at(Vector2(41,157),"LEVEL %d / 10" % data.level,18,ORANGE)
	var text := "Reinforce once: +1 ATK, +2 HP. Higher incoming level upgrades this unit."
	var inspected := inspected_unit_location()
	if inspected.x>=0:
		var row: Array = friendly if inspected.x==0 else enemy
		if row[inspected.y].get("reinforced",false): text = "REINFORCED: +1 ATK, +2 HP applied. Cannot reinforce again. Current HP: %d." % row[inspected.y].hp
	var names: Array = []
	for combo in Squads.COMBOS:
		if combo.groups.any(func(group): return Squads.matches(id,group)):
			names.append(combo.name)
	paragraph(Vector2(41,178),text,219,12,INK)
	paragraph(Vector2(41,239),"COMBOS: "+" / ".join(names),219,10,Color("ffda73"))

func glowing_squad_text(pos: Vector2, text: String, size: int, tint: Color, rainbow := false) -> void:
	var pulse := 0.22+0.12*sin(clock*3.0)
	for offset in [Vector2(-2,0),Vector2(2,0),Vector2(0,-2),Vector2(0,2)]:
		label_at(pos+offset,text,size,Color(tint,pulse))
	if rainbow:
		for index in text.length():
			var x := text_width(text.substr(0,index),size)
			var hue := fposmod(clock*0.16+x*0.003,1.0)
			label_at(pos+Vector2(x,0),text[index],size,Color.from_hsv(hue,0.55,1.0))
	else:
		label_at(pos,text,size,tint.lerp(Color.WHITE,0.12+0.08*sin(clock*3.0)))

func draw_squad_requirements(pos: Vector2, combo: Dictionary, active: bool, deck_mode := false) -> void:
	var terms: PackedStringArray = combo.rule.split(" + ")
	var x := pos.x
	for index in terms.size():
		var alternatives := terms[index].split(" or ")
		for alternative in alternatives.size():
			var group: Array = combo.groups[index]
			if alternatives.size()==group.size() and alternatives.size()>1:
				group = [group[alternative]]
			var deployed := friendly.any(func(unit): return not unit.is_empty() and Squads.matches(unit.id,group))
			var held := hand.any(func(id): return Squads.matches(id,group))
			var word: String = alternatives[alternative]
			if deck_mode:
				var included := decklist.any(func(id): return Squads.matches(id,group))
				glowing_squad_text(Vector2(x,pos.y),word,14,Color("9df6b7") if included else Color("ff6068"),active and included)
			elif deployed or held:
				glowing_squad_text(Vector2(x,pos.y),word,14,Color("ff6068") if deployed else Color("ffd378"),active)
				# Underlines keep available pieces recognizable without relying on color.
				draw_line(Vector2(x,pos.y+4),Vector2(x+text_width(word,14),pos.y+4),Color("ff6068") if deployed else Color("ffd378"),1)
			else:
				label_at(Vector2(x,pos.y),word,14,MUTED)
			x += text_width(word,14)
			if alternative<alternatives.size()-1:
				label_at(Vector2(x,pos.y)," or ",14,MUTED)
				x += text_width(" or ",14)
		if index<terms.size()-1:
			label_at(Vector2(x,pos.y)," + ",14,MUTED)
			x += text_width(" + ",14)

func squad_guide_state(combo: Dictionary) -> String:
	return Squads.deployment_status(combo,friendly,hand,energy,souls).state

func draw_combo_guide() -> void:
	label_at(Vector2(60,65),"SQUADS / DRAW LEVELS",32,ORANGE)
	paragraph(Vector2(60,105),"PLAYABLE NOW = enough space, Energy and Souls. PIECES AVAILABLE = held but blocked. Deploy in separate lanes. Active bonuses lock for End Turn. Bruiser = Hell Knight or Baron.",1310,17,INK)
	glowing_squad_text(Vector2(60,151),"RED: ON YOUR BOARD",14,Color("ff6068"))
	glowing_squad_text(Vector2(340,151),"GOLD: IN YOUR HAND",14,Color("ffd378"))
	glowing_squad_text(Vector2(620,151),"RAINBOW: PLAYABLE / ACTIVE",14,Color("e8a9ff"),true)
	for i in range(combo_page*12,mini((combo_page+1)*12,Squads.COMBOS.size())):
		var combo: Dictionary = Squads.COMBOS[i]
		var pos := Vector2(60+(i%2)*680,190+int((i%12)/2)*78)
		var status := Squads.deployment_status(combo,friendly,hand,energy,souls)
		var state: String = status.state
		if state != "INCOMPLETE":
			glowing_squad_text(pos,combo.name+"  ["+state+"]",16,Color("e8a9ff"),state in ["ACTIVE","PLAYABLE NOW"])
		else:
			label_at(pos,combo.name,19,ORANGE)
		draw_squad_requirements(pos+Vector2(0,23),combo,state in ["ACTIVE","PLAYABLE NOW"])
		var bonus_text := "+1 ATK" if combo.bonus=="attack" else "+1 DAMAGE AGAINST UNITS"
		label_at(pos+Vector2(0,43),bonus_text+(" / "+status.detail if not status.detail.is_empty() else ""),12,MUTED)
	label_at(Vector2(60,651),"RETALIATION: half ATK back (round up), even when killed. Ignores armor; shield absorbs 1. No splash / event / Health counters.",15,Color("ff9c91"))
	paragraph(Vector2(60,678),"REINFORCE: drag a matching monster onto an ally. Also compatible: Zombieman / Shotgun Guy / SS; Pinky / Spectre; Baron / Hell Knight. Pay the drawn card's cost. Once per unit: +1 ATK, +2 HP, and inherit a higher level. No extra attack or shield refresh.",1300,16,INK)
	paragraph(Vector2(60,758),"DRAW LEVELS: rounds 1-4 mostly LV 1-2; 5-8 LV 2-5; 9-14 LV 3-7; 15+ LV 5-9. Being 8 Health behind gives a small upgrade chance. Levels stay fixed in hand. LV 5 adds resistance. LV 10: 0.3% per eligible unit draw from round 12, once per side, rainbow Prism strike. Same rules for CPU.",1300,15,MUTED)
	button(Rect2(60,840,200,50),"< PREVIOUS",combo_page>0)
	button(Rect2(280,840,200,50),"MORE SQUADS >",(combo_page+1)*12<Squads.COMBOS.size())
	button(Rect2(1100,840,240,50),"BACK TO BATTLE")

func formation_effect(side: int, lane: int, id: int) -> void:
	var row: Array = friendly if side==0 else enemy
	var pos := lane_rect(side,lane).get_center()
	var announced := false
	if Cards.DATA[id].level==10:
		battle_voice.announce("LEVEL 10 - "+Cards.DATA[id].name)
		announced = true
		for hue in 7:
			burst(pos,Color.from_hsv(float(hue)/7,0.8,1),10)
		audio.play("DSGETPOW",-12)
	for combo in Squads.active(row):
		var members := Squads.members(row,combo)
		if lane not in members:
			continue
		for slot in members:
			burst(lane_rect(side,slot).get_center(),Color("ffda73"),10)
		log_line(("YOUR " if side==0 else "CPU ")+combo.name+" ACTIVE")
		if not announced:
			battle_voice.announce(combo.name+" - SQUAD ACTIVE")
			audio.play("DSGETPOW",-18)
			announced = true

func reinforce_lane(side: int, lane: int, id: int) -> void:
	var row: Array = friendly if side==0 else enemy
	if lane < 0 or lane >= row.size() or not Squads.can_reinforce(row[lane],id):
		return
	Squads.reinforce(row[lane],id)
	# The supporting copy is spent; the original unit retains its own identity.
	if side==0:
		discard.append(id)
	else:
		enemy_discard.append(id)
	var pos := lane_rect(side,lane).get_center()
	burst(pos,Color("9df6b7"),32)
	numbers.append({"pos":pos,"text":"REINFORCED!","life":1.3,"color":Color("9df6b7")})
	audio.play("DSWPNUP",-12)
	log_line(("CPU" if side==1 else "YOU")+" / lane %d: " % (lane+1)+Cards.DATA[id].name+" reinforces "+Cards.DATA[row[lane].id].name+" (+1 ATK, +2 HP).")
	formation_effect(side,lane,row[lane].id)

func damage_icon(pos: Vector2, kind: String, color: Color) -> void:
	if kind == "ICE":
		for spoke in 6:
			draw_line(pos,pos+Vector2(0,-9).rotated(spoke*TAU/6),color,2)
	elif kind == "ENERGY":
		draw_colored_polygon(PackedVector2Array([pos+Vector2(2,-9),pos+Vector2(-6,2),pos+Vector2(0,2),pos+Vector2(-2,10),pos+Vector2(7,-2),pos+Vector2(1,-2)]),color)
	elif kind == "BULLET":
		for i in 2:
			draw_rect(Rect2(pos+Vector2(-6+i*8,-5),Vector2(5,12)),color)
			draw_circle(pos+Vector2(-3.5+i*8,-5),2.5,color)
	elif kind == "FIRE":
		draw_colored_polygon(PackedVector2Array([pos+Vector2(0,-10),pos+Vector2(7,3),pos+Vector2(3,8),pos+Vector2(-4,8),pos+Vector2(-7,2)]),color)
		draw_circle(pos+Vector2(0,4),3,Color("ffdf93"))
	else:
		draw_line(pos+Vector2(-6,7),pos+Vector2(6,-7),color,4)

func card(rect: Rect2, id: int, unit: Dictionary = {}, chosen := false, offset := Vector2.ZERO, resting_angle := 0.0, unaffordable := false, attack_age := -1.0, squad_marked := false, squad_playable := false, squad_available := false) -> void:
	var data: Dictionary = Cards.DATA[id]
	var base := Cards.base_id(id)
	var mouse := get_global_mouse_position()
	var hover := rect.has_point(mouse) and not busy
	var local := (mouse - rect.get_center()) / rect.size
	var lift := 13.0 if hover or chosen else 0.0
	var angle := resting_angle
	# A repeating burst draws attention without moving the card hit area.
	var squad_burst := maxf(0,sin(fmod(clock,2.8)/2.8*PI)) if squad_playable else 0.0
	angle += sin(clock*18)*(0.095 if squad_marked else 0.055)*squad_burst
	var origin := rect.get_center() + offset - Vector2(0,lift+absf(sin(clock*9))*9*squad_burst)
	draw_set_transform_matrix(preload("res://scripts/card_tilt.gd").pose(origin,local.x,hover,angle))
	var bounds := Rect2(-rect.size/2,rect.size)
	var glow: Color = RARITY[data.rarity]
	if data.rarity == 5 or data.level == 10:
		glow = Color.from_hsv(fmod(clock*0.12+id*0.03,1.0),0.5,1.0)
	for i in range(5,0,-1):
		if data.rarity > 0 or data.level == 10 or chosen or hover:
			draw_rect(bounds.grow(i*2),Color(glow,(0.025+0.008*sin(clock*3))*float(6-i)),false,2)
	draw_rect(Rect2(bounds.position+Vector2(7,12+lift/2),bounds.size),Color(0,0,0,0.6))
	draw_rect(Rect2(bounds.position+Vector2(0,5),bounds.size),Color("080b0d"))
	panel(bounds,Color("303831"),glow if data.rarity > 0 or chosen else Color("7e8270"))
	draw_rect(bounds.grow(-4),Color("111b1c"))
	var x := bounds.position.x
	var y := bounds.position.y
	panel(Rect2(x+6,y+6,rect.size.x-12,23),Color("0b1115"),Color("303b3d"))
	var display_name: String = "HITLER / UNARMORED" if unit.get("suit_broken",false) else data.name
	var name_size := 14
	while text_width(display_name,name_size) > rect.size.x-24 and name_size > 10:
		name_size -= 1
	label_at(Vector2(x+12,y+23),display_name,name_size,glow)
	var art_box := Rect2(x+10,y+34,rect.size.x-20,rect.size.y-95)
	draw_rect(art_box,Color("0c141a"))
	for j in 5:
		draw_line(Vector2(x+12,y+45+j*19),Vector2(-x-12,y+45+j*19),Color(glow,0.075))
	draw_circle(Vector2(0,y+87),38,Color(glow,0.065+0.025*sin(clock*2)))
	var visual_art := Cards.art_key(id,unit)
	var frames: Array = art.textures.get(visual_art,[])
	var poses: Array = art.attack_textures.get(visual_art,[])
	if attack_age>=0 and not poses.is_empty():
		frames = poses
	if not frames.is_empty():
		var frame := attack_frame(id,attack_age,frames.size()) if attack_age>=0 and not poses.is_empty() else int(clock*2.5+id)%frames.size()
		var texture: Texture2D = frames[frame]
		var sprite_size := texture.get_size()
		var factor := minf((art_box.size.x-26)/sprite_size.x,(art_box.size.y-7)/sprite_size.y)
		sprite_size *= factor
		var parallax := local*9 if hover else Vector2.ZERO
		if base == 5 or base == 4 or (data.has("actor") and frames.size() == 1 and attack_age < 0):
			parallax.y += sin(clock*2.6+id)*5
		draw_ellipse_shadow(Vector2(0,art_box.end.y-3),Vector2(34,5))
		var tint := Color(0.55,0.8,0.95,0.45+sin(clock*5)*0.12) if base == 14 else Color.WHITE
		draw_texture_rect(texture,Rect2(Vector2(-sprite_size.x/2,art_box.end.y-sprite_size.y)+parallax,sprite_size),false,tint)
	elif id == 10:
		draw_rect(Rect2(-24,y+59,48,37),Color("b7b9a6"))
		draw_rect(Rect2(-5,y+63,10,29),Color("b62c25"))
		draw_rect(Rect2(-15,y+73,30,9),Color("b62c25"))
	else:
		label_at(Vector2(-31,y+94),"UAC",25,glow)
	if data.rarity in [1,4,5]:
		for i in (8 if data.rarity == 5 else 4):
			var phase := clock*(1.4 if data.rarity == 4 else 0.65)+i*TAU/4
			var spark := Vector2(sin(phase)*(rect.size.x/2-13),y+65+cos(phase)*25)
			draw_rect(Rect2(spark,Vector2(2,4)),Color(glow,0.6+sin(phase)*0.3))
	if data.has("soul_cost"):
		label_at(Vector2(x+12,y+66),"%d SOULS" % data.soul_cost,11,Color("d89fff"))
	draw_circle(Vector2(x+rect.size.x-18,y+42),12,Color("a45a2d"))
	label_at(Vector2(x+rect.size.x-23,y+47),str(data.cost),15)
	var type_color: Color = TYPE_COLORS.get(data.type,INK)
	draw_rect(Rect2(x+8,-y-58,rect.size.x-16,25),Color(type_color,0.13))
	damage_icon(Vector2(x+22,-y-46),data.type,type_color)
	label_at(Vector2(x+37,-y-40),data.type,15,type_color)
	if data.hp > 0:
		label_at(Vector2(x+12,-y-11),"ATK %d" % displayed_attack(unit,id),19,type_color)
		label_at(Vector2(15,-y-11),"HP %d" % int(unit.get("hp",data.hp)),19,Color("a9d5b0"))
	else:
		label_at(Vector2(x+12,-y-11),"CLICK TO AIM" if data.get("targeted",false) else "DRAG TO CAST",12,INK)
	if unit.get("shield",false):
		draw_arc(Vector2(0,y+83),43,0,TAU,40,Color("77caff"),2)
	if not unit.is_empty() and not unit.get("ready",true):
		draw_rect(Rect2(x+10,y+34,rect.size.x-45,20),Color(0.03,0.04,0.04,0.9))
		label_at(Vector2(x+20,y+49),"NEXT TURN",12,Color("e3bf84"))
	elif data.get("ambush",false):
		label_at(Vector2(x+12,y+49),"AMBUSH",12,Color("6cdeff"))
	draw_level_trim(bounds,data,unit,glow)
	# A moving specular line reinforces the raised card surface.
	draw_line(Vector2(x+2,y+2),Vector2(-x-2,y+2),Color(glow,0.55+0.2*sin(clock*2)),2)
	if unaffordable:
		draw_rect(bounds.grow(10),Color(0.01,0.015,0.02,0.62))
		# Preserve a readable price after dimming both the artwork and rarity glow.
		draw_circle(Vector2(x+rect.size.x-18,y+42),12,Color("65372e"))
		label_at(Vector2(x+rect.size.x-23,y+47),str(data.cost),15,Color("ffc7a1"))
	if squad_marked or squad_available:
		var mark_color := Color("aaff96") if squad_playable else (Color("71e8df") if squad_marked else Color("c3ad78"))
		draw_rect(bounds.grow(3),Color(mark_color,(0.75 if squad_marked or squad_playable else 0.3)+0.15*sin(clock*2)),false,2)
		panel(Rect2(x+10,-y-83,rect.size.x-20,19),Color("102e30"),mark_color)
		label_at(Vector2(x+16,-y-69),"SQUAD PLAYABLE!" if squad_playable else ("SAVED FOR SQUAD" if squad_marked else "SQUAD PIECES HELD"),11,mark_color)
	draw_set_transform(Vector2.ZERO)

func draw_ellipse_shadow(center: Vector2, dimensions: Vector2) -> void:
	var points := PackedVector2Array()
	for i in 24:
		points.append(center+Vector2(cos(i*TAU/24),sin(i*TAU/24))*dimensions)
	draw_colored_polygon(points,Color(0,0,0,0.55))

func cancel_drag() -> void:
	dragging = false
	drag_index = -1

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		hell_meld.support.set_player_drawer(self,false)
		cancel_drag()
		selected = -1

func weapon_target_at(pos: Vector2) -> int:
	for side in 2:
		var row: Array = friendly if side==0 else enemy
		for lane in 4:
			if not row[lane].is_empty() and lane_rect(side,lane).has_point(pos): return side*4+lane
	return -1

func targeting_weapon() -> bool:
	return selected>=0 and selected<hand.size() and Cards.DATA[hand[selected]].get("targeted",false)

func drop_card(pos: Vector2) -> void:
	if selected < 0 or selected >= hand.size():
		return
	if targeting_weapon():
		var target := weapon_target_at(pos)
		if target>=0: play_card(target)
	elif Cards.DATA[hand[selected]].hp == 0:
		if PLAY_AREA.has_point(pos):
			play_card(-1)
	else:
		for i in 4:
			if lane_rect(0,i).has_point(pos) and (friendly[i].is_empty() or Squads.can_reinforce(friendly[i],hand[selected])):
				play_card(i)
				return

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		event = make_input_local(event)
	if modal=="radio":
		radio.handle(self,event)
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F8:
		if not busy: radio.open(self)
		return
	if modal=="hell_meld":
		hell_meld.handle(self,event)
		return
	if frontend.handle(self,event): return
	if modal=="matchup":
		if (event is InputEventKey and event.pressed and event.keycode in [KEY_SPACE,KEY_ESCAPE,KEY_ENTER]) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and Rect2(550,770,340,55).has_point(event.position)):
			match_flair.finish_intro(self)
		return
	if hero_power.handle(event): return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if modal=="mulligan":
				frontend.open(self)
				return
			if modal in ["history","energy_curve"]:
				modal = battle_tools.return_modal
				return
			selected = -1
			cancel_drag()
			if modal == "commanders":
				initial_commander_choice = false
				modal = "home" if frontend.at_home else ""
				return
			if modal == "deck_name":
				finish_deck_name(false)
				return
			if modal == "deck_guide":
				modal = "decks"
				return
			if modal == "decks":
				modal = "home" if frontend.at_home else ""
				return
			if modal == "deck_combos":
				modal = "collection"
				return
			if modal == "combos":
				modal = ""
			if modal == "collection":
				close_collection()
		if event.keycode == KEY_SPACE and not busy and not ended and modal == "" and not dragging:
			cancel_drag()
			end_turn()
	if event is InputEventMouseMotion:
		if drag_index >= 0 and not busy and modal == "":
			drag_position = event.position
			if press_position.distance_to(drag_position) > 8:
				dragging = true
		return
	if not event is InputEventMouseButton:
		return
	if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Right click during a drag still cancels; it must not also mark a card.
		if drag_index < 0 and not busy and not ended and modal == "":
			for i in range(hand.size()-1,-1,-1):
				if hand_rect(i).has_point(event.position):
					if squad_marks.has(i): squad_marks.erase(i)
					else: squad_marks[i] = true
					audio.play("DSSWTCHN",-23)
					log_line("Saved for squad. Right click to unmark." if squad_marks.has(i) else "Squad marker removed.")
					break
		selected = -1
		cancel_drag()
		return
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	var pos: Vector2 = event.position
	if not event.pressed:
		if dragging and not busy and not ended and modal == "":
			drop_card(pos)
			selected = -1
		cancel_drag()
		return
	if busy:
		return
	if modal != "":
		modal_click(pos)
		return
	if match_flair.click_toy(self,pos): return
	if battle_tools.HISTORY_BUTTON.has_point(pos):
		battle_tools.open_history(self)
		return
	if Rect2(53,268,150,22).has_point(pos):
		open_commanders()
		return
	if COMBOS_BUTTON.has_point(pos):
		cancel_drag()
		selected = -1
		modal = "combos"
		return
	if BATTLE_VIEW_BUTTON.has_point(pos):
		cinematic_enabled = not cinematic_enabled
		save_view_setting()
		audio.play("DSSWTCHN",-17)
		return
	if ARMORY_BUTTON.has_point(pos):
		cancel_drag()
		selected = -1
		modal = "collection"
		audio.play("DSDOROPN",-17)
		return
	if ended:
		return
	if END_BUTTON.has_point(pos):
		cancel_drag()
		end_turn()
	elif SURGE_BUTTON.has_point(pos) and souls >= 3:
		audio.play("DSGETPOW")
		souls -= 3
		energy += 2
		log_line("Soul surge: +2 energy.")
	elif REVIVE_BUTTON.has_point(pos) and has_arch_vile():
		revive()
	else:
		# Last drawn card wins in overlapping hand bounds.
		for i in range(hand.size()-1,-1,-1):
			if hand_rect(i).has_point(pos):
				if not can_afford(hand[i]):
					selected = -1
					cancel_drag()
					audio.play("DSNOWAY",-14)
					log_line("Not enough Energy or Souls.")
					return
				audio.play("DSTINK",-23)
				selected = i
				drag_index = i
				press_position = pos
				drag_position = pos
				return
		if selected >= 0:
			drop_card(pos)

func play_card(lane: int) -> void:
	if selected < 0 or selected >= hand.size() or busy or ended:
		return
	var id: int = hand[selected]
	var data: Dictionary = Cards.DATA[id]
	if data.hp > 0 and (lane < 0 or lane >= 4):
		return
	if data.get("targeted",false):
		if lane<0 or lane>=8: return
		var target_row: Array = friendly if lane<4 else enemy
		if target_row[lane%4].is_empty(): return
	if not can_afford(id) or (data.hp>0 and lane >= 0 and not friendly[lane].is_empty() and not Squads.can_reinforce(friendly[lane],id)):
		return
	var weapon_origin := hand_rect(selected).get_center()
	energy -= data.cost
	souls -= int(data.get("soul_cost",0))
	var base := Cards.base_id(id)
	# Follow the specific marked copy as earlier hand slots are consumed.
	var remaining_marks := {}
	for index in squad_marks:
		if index != selected: remaining_marks[index-1 if index>selected else index] = true
	squad_marks = remaining_marks
	hand.remove_at(selected)
	selected = -1
	if data.hp > 0:
		if not friendly[lane].is_empty():
			reinforce_lane(0,lane,id)
			return
		friendly[lane] = Cards.unit(id,true)
		formation_effect(0,lane,id)
		slam_lane = lane
		slam = 1.0
		burst(lane_rect(0,lane).get_center()+Vector2(0,75),RARITY[data.rarity],18)
		play_summon_sound(id)
		if base == 8:
			entrance = 1.0
			table.flare = 1.0
			log_line("CYBERDEMON breaches containment.")
		else:
			log_line(data.name+" deployed.")
		if Cards.base_id(id) == 12:
			for adjacent in [lane-1,lane+1]:
				if adjacent >= 0 and adjacent < 4 and not friendly[adjacent].is_empty():
					friendly[adjacent].shield = true
					burst(lane_rect(0,adjacent).get_center(),Color("6cdeff"),20)
			log_line("Carmack shields adjacent allies.")
		if Cards.base_id(id) in [12,13]:
			burst(lane_rect(0,lane).get_center(),RARITY[3],36)
			audio.play("DSGETPOW" if Cards.base_id(id) == 12 else "DSTELEPT",-14)
		souls += int(data.get("on_play_souls",0))
		if base == 24:
			var spawned := 0
			for i in 4:
				if friendly[i].is_empty() and spawned < 2:
					spawn_token(0,i,0)
					spawned += 1
			log_line("Icon of Sin opens a gate: %d Imps." % spawned)
		if data.rarity in [4,5]:
			arrival = 1.2
			arrival_rarity = data.rarity
			arrival_center = lane_rect(0,lane).get_center()
			burst(arrival_center,RARITY[data.rarity],60 if data.rarity==5 else 30)
			audio.play("DSTELEPT" if data.rarity==5 else "DSMETAL",-14)
	else:
		if not data.get("exhaust",false):
			discard.append(id)
		if data.get("targeted",false):
			busy = true
			cancel_drag()
			var target_side := int(lane/4)
			var target_lane := lane%4
			await fire_weapon(id,target_side,target_lane,weapon_origin,0)
			busy = false
			check_end()
		elif id == 10:
			audio.play("DSITEMUP")
			player_hp = mini(30,player_hp+6)
			log_line("Medikit restores 6 Health.")
		elif id == 11:
			audio.play("DSGETPOW")
			souls += 3
			log_line("Harvested 3 Souls.")
		elif id == 9:
			busy = true
			audio.play("DSBFG",-7)
			var tween := create_tween()
			tween.tween_property(self,"charge",1.0,0.65)
			await tween.finished
			for i in 4:
				if not enemy[i].is_empty():
					spawn_impact(9,lane_rect(1,i).get_center())
					hit(1,i,data.board_damage,"ENERGY",false,id)
			burst(Vector2(720,258),Color("b2ff66"),90)
			audio.play("DSRXPLOD",-9)
			charge = 0.0
			busy = false
			check_end()

func fire_weapon(id: int, target_side: int, lane: int, origin: Vector2, owner: int) -> void:
	var data: Dictionary = Cards.DATA[id]
	var row: Array = friendly if target_side==0 else enemy
	var originals := row.duplicate()
	log_line(("CPU / " if owner==1 else "")+data.name+" fired.")
	battle_tools.record(turn,data.name+" fired","%s weapon; target lane %d. No counterattack." % ["CPU" if owner==1 else "YOUR",lane+1])
	for shot in Weapons.schedule(id,lane):
		if row[shot.lane].is_empty() or not is_same(row[shot.lane],originals[shot.lane]): continue
		var destination := lane_rect(target_side,shot.lane).get_center()
		projectile_type = data.type
		projectile_art = data.get("projectile","")
		projectile_side = owner
		projectile = origin
		audio.play(data.get("weapon_sound","DSBFG" if id==9 else "DSPLASMA"),-10)
		var shot_tween := create_tween()
		shot_tween.tween_property(self,"projectile",destination,0.2 if data.get("weapon_shots",1)>1 else 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await shot_tween.finished
		projectile = Vector2(-100,-100)
		spawn_impact(id,destination)
		hit(target_side,shot.lane,shot.damage,data.type,false,id)
		audio.impact(data.type)
	await get_tree().create_timer(0.35).timeout

func attack_frame(id: int, age: float, count: int) -> int:
	if (Cards.DATA[id].get("actor","")=="Minigunner" or Cards.DATA[id].get("dual_minigun",false)) and count>=3:
		return 1+int(maxf(0,age-attack_pose_duration)/0.08)%2 if minigun_firing else 0
	return mini(count-1,int(maxf(0,age)/attack_pose_duration*count))

func projectile_key(id: int) -> String:
	if Cards.DATA[id].has("projectile"):
		return Cards.DATA[id].projectile
	var base := Cards.base_id(id)
	if Cards.DATA[id].type in ["BULLET","MELEE"]:
		return ""
	return {0:"BAL1",5:"BAL2",6:"BAL7",7:"FIRE",8:"MISL",12:"PLSS",13:"BAL1",16:"BAL7",17:"FATB",18:"MANF",19:"APLS",20:"BAL1",24:"BAL7"}.get(base,"BAL1")

func spawn_impact(id: int, pos: Vector2) -> void:
	var key := projectile_key(id)
	var first := 2
	var count := 3
	if Cards.DATA[id].has("impact"):
		key = Cards.DATA[id].impact
		first = 0
		count = art.effect_textures.get(key,[]).size()
	elif key.begins_with("MMM_SHOT_"):
		key = "MISL" if Cards.DATA[id].type=="ROCKET" else ("PUFF" if Cards.DATA[id].type=="BULLET" else "PLSE")
		first = 1 if key=="MISL" else 0
		count = 3 if key=="MISL" else 4
	elif id==9:
		key = "BFE1"
		first = 0
		count = 6
	elif key in ["MISL","FATB","MANF"]:
		key = "MISL"
		first = 1
	elif key in ["PLSS","APLS"]:
		key = "PLSE" if key=="PLSS" else "APBX"
		first = 0
		count = 5
	elif key=="FIRE":
		first = 0
		count = 8
	elif key=="":
		key = "PUFF"
		first = 0
		count = 4
	sprite_effects.append({"key":key,"first":first,"count":count,"pos":pos,"age":0.0,"duration":0.45,"size":96.0 if key in ["MISL","BFE1","FIRE"] else 64.0})

func side_projectile_flipped(key: String, side: int) -> bool:
	return side==0 and (key in ["BAL7","MISL","FATB","MANF"] or key.begins_with("MMM_SHOT_"))

func draw_effect_sprite(key: String, frame: int, pos: Vector2, size: float) -> void:
	var frames: Array = (art.side_effect_textures if duel_active else art.effect_textures).get(key,[])
	if frames.is_empty():
		return
	var texture: Texture2D = frames[clampi(frame,0,frames.size()-1)]
	var dimensions := texture.get_size()
	dimensions *= size/maxf(dimensions.x,dimensions.y)
	var effect_rect := Rect2(pos-dimensions*0.5,dimensions)
	if duel_active and side_projectile_flipped(key,projectile_side):
		effect_rect.size.x = -dimensions.x
	draw_texture_rect(texture,effect_rect,false)

func load_view_setting() -> void:
	if "--balance-test" in OS.get_cmdline_user_args() or "--smoke-test" in OS.get_cmdline_user_args():
		cinematic_enabled = false
		return
	var settings := ConfigFile.new()
	if settings.load("user://settings.cfg")==OK:
		cinematic_enabled = bool(settings.get_value("presentation","cinematic_battles",true))
		master_volume = clampf(float(settings.get_value("audio","master_volume",0.8)),0,1)
		fullscreen = bool(settings.get_value("presentation","fullscreen",false))
		mode_tutorials = bool(settings.get_value("presentation","mode_tutorials",true))
		joker_reminders = bool(settings.get_value("presentation","joker_reminders",true))
		screen_shake = bool(settings.get_value("presentation","screen_shake",true))
		gibs_enabled = bool(settings.get_value("presentation","gibs_enabled",true))
	apply_options()

func save_view_setting() -> void:
	if "--balance-test" in OS.get_cmdline_user_args() or "--smoke-test" in OS.get_cmdline_user_args():
		return
	var settings := ConfigFile.new()
	settings.load("user://settings.cfg")
	settings.set_value("presentation","cinematic_battles",cinematic_enabled)
	settings.set_value("audio","master_volume",master_volume)
	settings.set_value("presentation","fullscreen",fullscreen)
	settings.set_value("presentation","mode_tutorials",mode_tutorials)
	settings.set_value("presentation","joker_reminders",joker_reminders)
	settings.set_value("presentation","screen_shake",screen_shake)
	settings.set_value("presentation","gibs_enabled",gibs_enabled)
	settings.save("user://settings.cfg")

func draw_duel() -> void:
	var fade := clampf(duel_mix,0,1)
	draw_rect(PLAY_AREA.grow(12),Color(0.014,0.012,0.019,fade*0.72))
	label_at(Vector2(615,170),"DEMON CLASH",22,Color(1,0.6,0.3,fade))
	# Pixel embers scatter from the card positions and reverse when cards reform.
	for side in 2:
		for lane in 4:
			var rect := lane_rect(side,lane)
			for i in 14:
				var origin := rect.position+Vector2(fmod(i*47+lane*19,rect.size.x),fmod(i*31+side*17,rect.size.y))
				var travel := Vector2(sin(i*2.3)*90,-60-fmod(i*17,90))*fade
				var alpha := sin(fade*PI)*0.8
				draw_rect(Rect2(origin+travel,Vector2(4,7)),Color(1,0.45,0.16,alpha))
	if duel_attacker < 0:
		return
	var targets: Array = enemy if moving_side==0 else friendly
	var defender_alive: bool = duel_target_lane>=0 and not targets[duel_target_lane].is_empty() and targets[duel_target_lane].id==duel_defender
	if duel_defender>=0:
		var opacity := fade*(1.0 if defender_alive or counter_finished_at<0 else maxf(0,1.0-(clock-counter_finished_at)/0.3))
		var recoil := (duel_finish-duel_start).normalized()*sin(unit_hit_strength(duel_defender_unit)*PI)*22 if duel_struck and retaliation_started<0 else Vector2.ZERO
		draw_duel_monster(duel_defender,duel_finish+counter_offset+recoil,clock-counter_pose_started if counter_animating else -1.0,opacity,duel_struck and not counter_animating,moving_side==1,duel_defender_unit)
	else:
		draw_arc(duel_finish,46,0,TAU,8,Color(1,0.3,0.15,fade),4)
		label_at(duel_finish+Vector2(-28,7),"HEALTH",15,Color(1,0.75,0.5,fade))
	var attackers: Array = friendly if moving_side==0 else enemy
	var attacker_alive: bool = not attackers[moving_lane].is_empty() and attackers[moving_lane].id==duel_attacker
	var attacker_fade := fade if attacker_alive or retaliation_started<0 else fade*maxf(0,1.0-(clock-retaliation_started)/0.3)
	draw_duel_monster(duel_attacker,duel_start+moving_offset,clock-attack_started if duel_attacking else -1.0,attacker_fade,retaliation_started>=0,moving_side==0,duel_attacker_unit)
	for extra in duel_splash_targets:
		var unit: Dictionary = extra.unit
		var opacity := fade
		if unit.hp<=0 and duel_struck: opacity *= maxf(0,1-(clock-duel_impact_time)/0.9)
		draw_duel_monster(unit.id,extra.center,-1,opacity,duel_struck,moving_side==1,unit,0.6)
		label_at(extra.center+Vector2(-70,74),"LANE %d / SPLASH ONLY" % (extra.lane+1),11,Color(Color("ffd378"),opacity))
	label_at(Vector2(360,635),Cards.DATA[duel_attacker].name+"  >  "+(Cards.DATA[duel_defender].name if duel_defender>=0 else "HEALTH"),17,Color(0.9,0.85,0.7,fade))

func draw_duel_monster(id: int, center: Vector2, attack_age: float, opacity: float, struck: bool, face_right: bool, unit: Dictionary = {}, visual_scale := 1.0) -> void:
	if opacity<=0:
		return
	center += unit_hit_offset(unit)*1.6
	var key: String = Cards.art_key(id,unit)
	var frames: Array = art.side_attack_textures.get(key,[]) if attack_age>=0 else art.side_textures.get(key,[])
	if frames.is_empty():
		frames = art.textures.get(key,[])
	if frames.is_empty():
		return
	var frame := attack_frame(id,attack_age,frames.size()) if attack_age>=0 else int(clock*3)%frames.size()
	var texture: Texture2D = frames[frame]
	var size := texture.get_size()
	size *= minf(200.0/size.x,190.0/size.y)*visual_scale
	draw_ellipse_shadow(center+Vector2(0,95*visual_scale),Vector2(size.x*0.4,10))
	var tint := Color(1,0.45,0.35,opacity) if unit_hit_strength(unit)>0.45 else Color(1,1,1,opacity)
	if Cards.base_id(id)==14:
		tint.a *= 0.6
	var sprite_rect := Rect2(Vector2(center.x-size.x*0.5,center.y+95*visual_scale-size.y),size)
	if face_right:
		sprite_rect.size.x = -size.x
	draw_texture_rect(texture,sprite_rect,false,tint)

func duel_body_center(id: int, anchor: Vector2, unit: Dictionary, visual_scale := 1.0) -> Vector2:
	var frames: Array = art.side_textures.get(Cards.art_key(id,unit),[])
	if frames.is_empty(): return anchor
	var size: Vector2 = frames[0].get_size()
	size *= minf(200.0/size.x,190.0/size.y)*visual_scale
	return anchor+Vector2(0,95*visual_scale-size.y*0.55)

func duel_hit_position(side: int, lane: int) -> Vector2:
	if not duel_active: return lane_rect(side,lane).get_center()
	if side==moving_side and lane==moving_lane: return duel_body_center(duel_attacker,duel_start+moving_offset,duel_attacker_unit)
	if side==1-moving_side:
		if lane==duel_target_lane: return duel_body_center(duel_defender,duel_finish+counter_offset,duel_defender_unit)
		for extra in duel_splash_targets:
			if extra.lane==lane: return duel_body_center(extra.unit.id,extra.center,extra.unit,0.6)
	return lane_rect(side,lane).get_center()

func can_afford(id: int) -> bool:
	return energy >= Cards.DATA[id].cost and souls >= int(Cards.DATA[id].get("soul_cost",0))

func draw_enemy_card() -> void:
	if enemy_hand.size() >= 6:
		return
	if enemy_deck.is_empty():
		enemy_deck = enemy_discard.duplicate()
		enemy_discard.clear()
		enemy_deck.shuffle()
	if not enemy_deck.is_empty():
		enemy_hand.append(enemy_deck.pop_back() if random_mode else cpu_director.take(enemy_deck,enemy_hand,turn==1,turn,player_hp-enemy_hp))

func draw_cpu_support() -> void:
	var destination := lane_rect(1,int(cpu_support.lane)).get_center()
	var start := Vector2(1190,220)
	var travel := clampf((cpu_support_progress-0.3)/0.7,0,1)
	var center := start.lerp(destination,travel)
	center.y -= sin(travel*PI)*65
	var size := Vector2(168,210).lerp(Vector2(120,150),travel)
	var tint := Color("9df6b7")
	draw_rect(lane_rect(1,int(cpu_support.lane)).grow(5),tint,false,3)
	card(Rect2(center-size/2,size),int(cpu_support.id),{},true)
	var message: String = Cards.DATA[int(cpu_support.id)].name+" > "+str(cpu_support.target)
	var width := text_width(message,17)
	panel(Rect2(720-width/2-14,90,width+28,32),Color("0c2021"),tint)
	label_at(Vector2(720-width/2,113),message,17,tint)

func animate_cpu_reinforcement(id: int, lane: int) -> void:
	cpu_support = {"id":id,"lane":lane,"target":Cards.DATA[enemy[lane].id].name}
	cpu_support_progress = 0.0
	var tween := create_tween()
	tween.tween_property(self,"cpu_support_progress",1.0,1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	cpu_support.clear()

func deploy_enemy_cards() -> void:
	for id in enemy_hand.duplicate():
		if id not in [10,11] or Cards.DATA[id].cost>enemy_energy: continue
		if id==10 and enemy_hp>24: continue
		enemy_energy -= Cards.DATA[id].cost
		enemy_spent += Cards.DATA[id].cost
		enemy_plays += 1
		enemy_hand.erase(id)
		if id==10: enemy_hp = mini(30,enemy_hp+6)
		else:
			hero_power.cpu_souls += 3
			enemy_discard.append(id)
		log_line("CPU uses "+Cards.DATA[id].name+".")
	for attempt in 6:
		var weapon := Weapons.best(enemy_hand,friendly,enemy_energy)
		if weapon.id<0: break
		enemy_energy -= Cards.DATA[weapon.id].cost
		enemy_spent += Cards.DATA[weapon.id].cost
		enemy_plays += 1
		enemy_hand.erase(weapon.id)
		await fire_weapon(weapon.id,0,weapon.lane,Vector2(488,60),1)
	var moves := EnemyAI.plan(enemy,friendly,enemy_hand.filter(func(id): return Cards.DATA[id].hp>0),enemy_energy,enemy_hp,player_hp,hero_power.cpu_souls)
	for move in moves:
		var id: int = move.id
		var lane: int = move.lane
		if not enemy_hand.has(id) or Cards.DATA[id].cost > enemy_energy or Cards.DATA[id].get("soul_cost",0)>hero_power.cpu_souls or (not enemy[lane].is_empty() and not Squads.can_reinforce(enemy[lane],id)):
			continue
		enemy_energy -= Cards.DATA[id].cost
		hero_power.cpu_souls -= Cards.DATA[id].get("soul_cost",0)
		enemy_spent += Cards.DATA[id].cost
		enemy_plays += 1
		enemy_hand.erase(id)
		if not enemy[lane].is_empty():
			await animate_cpu_reinforcement(id,lane)
			reinforce_lane(1,lane,id)
		else:
			enemy[lane] = Cards.unit(id,true)
			formation_effect(1,lane,id)
			log_line("CPU / lane %d: " % (lane+1)+Cards.DATA[id].name+" deployed.")
		play_summon_sound(id)
		burst(lane_rect(1,lane).get_center(),Color("df694b"),18)
		await get_tree().create_timer(0.2).timeout

func end_turn() -> void:
	if battle_tools.pending: return
	hero_power.armed = false
	if busy or ended:
		return
	busy = true
	match_flair.observe(friendly)
	Squads.lock_combat(friendly)
	battle_voice.announce("YOUR ATTACK")
	Squads.lock_combat(enemy)
	audio.play("DSSWTCHN",-17)
	cancel_drag()
	selected = -1
	for i in 4:
		if not friendly[i].is_empty():
			await attack(0,i)
			if check_end():
				Squads.clear_combat(friendly)
				Squads.clear_combat(enemy)
				busy = false
				return
	await deploy_enemy_cards()
	await hero_power.cpu_turn()
	if check_end():
		Squads.clear_combat(friendly)
		Squads.clear_combat(enemy)
		busy = false
		return
	battle_voice.announce("ENEMY ATTACK")
	Squads.lock_combat(enemy)
	for i in 4:
		if not enemy[i].is_empty():
			await attack(1,i)
			if check_end():
				Squads.clear_combat(friendly)
				Squads.clear_combat(enemy)
				busy = false
				return
	Squads.clear_combat(friendly)
	Squads.clear_combat(enemy)
	turn += 1
	hero_power.used = [false,false]
	if apply_collapse():
		busy = false
		return
	for row in [friendly,enemy]:
		for unit in row:
			if not unit.is_empty() and unit.get("waited",false):
				unit.ready = true
				unit.erase("waited")
	max_energy = mini(8,3+turn/2)
	energy = max_energy
	for unit in friendly:
		if not unit.is_empty():
			unit.cooldown = maxi(0,unit.cooldown-1)
	draw_card()
	draw_card()
	enemy_energy = max_energy
	draw_enemy_card()
	draw_enemy_card()
	busy = false
	log_line("Turn %d: energy refilled, cards drawn." % turn)
	battle_voice.announce("ROUND %d - YOUR TURN" % turn)
	if enemy_hp<=12 and enemy_hp<player_hp:
		battle_voice.react("losing")
	elif player_hp<=12 and player_hp<enemy_hp:
		battle_voice.react("winning")

func damage_hero(side: int, amount: int, source := "") -> void:
	var before := player_hp if side==0 else enemy_hp
	var lost := mini(maxi(0,before),maxi(0,amount))
	if side==0: player_hp -= lost
	else: enemy_hp -= lost
	if side==1: match_flair.record(source,lost,false)
	hero_feedback.hurt(side,lost)
	if lost>0: battle_tools.record(turn,("YOUR HERO" if side==0 else "ENEMY HERO")+" takes %d damage" % lost,"Health: %d -> %d. Incoming damage: %d." % [before,before-lost,amount])

func apply_collapse() -> bool:
	if turn < 15:
		return false
	var pressure := mini(5,1+int((turn-15)/3))
	log_line("HELL COLLAPSE: up to %d damage to both sides." % pressure)
	for tick in pressure:
		damage_hero(0,1)
		damage_hero(1,1)
		if check_end():
			return true
	return false

func attack(side: int, lane: int) -> void:
	var units: Array = friendly if side == 0 else enemy
	if units[lane].is_empty():
		return
	if not units[lane].get("ready",true):
		units[lane].waited = true
		return
	var strikes: int = Cards.DATA[units[lane].id].get("strikes",1)
	for shot in strikes:
		if player_hp <= 0 or enemy_hp <= 0:
			break
		await attack_once(side,lane,shot>0)
	if not units[lane].is_empty():
		units[lane].erase("chilled")

func attack_once(side: int, lane: int, followup := false) -> void:
	duel_splash_targets.clear()
	counter_visual_active = false
	pending_counter_death.clear()
	counter_animating = false
	counter_offset = Vector2.ZERO
	counter_finished_at = -1.0
	projectile_side = side
	retaliation_started = -1.0
	var kills_before := kills
	var units: Array = friendly if side == 0 else enemy
	var targets: Array = enemy if side == 0 else friendly
	if units[lane].is_empty() or not units[lane].get("ready",true):
		return
	var id: int = units[lane].id
	var data: Dictionary = Cards.DATA[id]
	var target_lane := lane
	if data.get("seeking",false) and targets[lane].is_empty():
		var distance := 5
		for i in 4:
			if not targets[i].is_empty() and absi(i-lane) < distance:
				distance = absi(i-lane)
				target_lane = i
	var start := lane_rect(side,lane).get_center()
	var finish := lane_rect(1-side,target_lane).get_center()
	battle_tools.record(turn,("YOUR " if side==0 else "CPU ")+data.name+" attacks","Attacker: %s, lane %d. Target: %s, lane %d. Damage type: %s." % [data.name,lane+1,Cards.DATA[targets[target_lane].id].name if not targets[target_lane].is_empty() else "HERO HEALTH",target_lane+1,data.type])
	moving_side = side
	moving_lane = lane
	if cinematic_enabled and not targets[target_lane].is_empty():
		duel_active = true
		duel_target_lane = target_lane
		duel_attacker = id
		duel_attacker_unit = units[lane]
		duel_defender_unit = targets[target_lane]
		duel_defender = targets[target_lane].get("id",-1)
		duel_struck = false
		duel_attacking = false
		duel_start = Vector2(475,425) if side==0 else Vector2(950,425)
		duel_finish = Vector2(950,425) if side==0 else Vector2(475,425)
		var splash_radius: int = data.get("splash",2 if Cards.base_id(id)==8 else (1 if Cards.base_id(id)==3 else 0))
		if splash_radius>0:
			for adjacent in [target_lane-1,target_lane+1]:
				if adjacent>=0 and adjacent<4 and not targets[adjacent].is_empty():
					duel_splash_targets.append({"lane":adjacent,"unit":targets[adjacent],"center":Vector2(1080 if side==0 else 345,265 if adjacent<target_lane else 555)})
		start = duel_body_center(duel_attacker,duel_start,duel_attacker_unit)
		finish = duel_hit_position(1-side,target_lane)
		var dissolve := create_tween()
		dissolve.tween_property(self,"duel_mix",1.0,0.16 if followup else 0.28)
		await dissolve.finished
	attack_started = clock
	duel_attacking = true
	# Readable anticipation, then hold the striking pose through impact and recovery.
	var minigunner: bool = data.get("actor","")=="Minigunner" or data.get("dual_minigun",false)
	var pose_count: int = art.attack_textures.get(data.art,[]).size()
	attack_pose_duration = maxf(0.42 if followup else 0.6,minf(1.2,pose_count*0.10))
	if minigunner: attack_pose_duration = 0.26 if followup else 0.65
	var tween := create_tween()
	var melee: bool = data.type == "MELEE"
	tween.tween_property(self,"moving_offset",(finish-start)*(0.68 if melee else 0.18),attack_pose_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if not minigunner: audio.monster(id,"attack")
	if not melee:
		projectile_type = data.type
		projectile_art = projectile_key(id)
		minigun_firing = minigunner
		# Extra tracers are presentation only: one damage/counter resolution per card strike.
		for tracer in (4 if minigunner else 1):
			if minigunner: audio.monster(id,"attack")
			projectile = start+moving_offset if duel_active else start
			if data.get("dual_minigun",false): projectile += Vector2(0,12 if tracer%2==0 else -12) if duel_active else Vector2(12 if tracer%2==0 else -12,0)
			var shot := create_tween()
			shot.tween_property(self,"projectile",finish,0.16 if minigunner else (0.28 if data.type=="BULLET" else 0.44))
			await shot.finished
			if minigunner: spawn_impact(id,finish)
		projectile = Vector2(-100,-100)
		minigun_firing = false
	duel_struck = true
	duel_impact_time = clock
	spawn_impact(id,finish)
	audio.impact(data.type)
	var main_hit_landed: bool = targets[target_lane].is_empty() or not targets[target_lane].shield
	counter_visual_unit = targets[target_lane]
	var counter_id: int = targets[target_lane].get("id",-1)
	counter_visual_active = counter_id>=0
	counter_visual_id = counter_id
	counter_visual_lane = target_lane
	var counter_damage := Squads.retaliation(targets,target_lane) if counter_id>=0 else 0
	if targets[target_lane].is_empty():
		audio.play("DSPLPAIN",-14)
		if side == 0:
			damage_hero(1,Squads.attack_value(units,lane),data.name)
		else:
			damage_hero(0,Squads.attack_value(units,lane))
		burst(finish,ORANGE,12)
		numbers.append({"pos":finish,"text":"-%d HEALTH" % Squads.attack_value(units,lane),"life":0.8,"color":ORANGE})
	else:
		hit(1-side,target_lane,Squads.damage(units,lane,targets[target_lane].id),data.type,false,id)
	if main_hit_landed:
		apply_attack_traits(side,target_lane,data)
	var splash: int = data.get("splash",2 if Cards.base_id(id) == 8 else (1 if Cards.base_id(id) == 3 else 0))
	if splash > 0:
		for adjacent in [target_lane-1,target_lane+1]:
			if adjacent >= 0 and adjacent < 4 and not targets[adjacent].is_empty():
				spawn_impact(id,duel_hit_position(1-side,adjacent))
				hit(1-side,adjacent,splash,data.type,false,id)
	if side == 0 and (Cards.base_id(id) == 13 or data.get("kill_souls",0)>0) and kills > kills_before:
		var bonus := kills-kills_before
		souls += bonus
		burst(start,Color("c36aff"),24)
		numbers.append({"pos":start,"text":"+%d SOUL" % bonus,"life":0.9,"color":Color("c36aff")})
		log_line(data.name+" claims an extra Soul.")
	# Finish the first monster's action and return it home before the counter starts.
	var retreat := create_tween()
	retreat.tween_interval(0.24 if followup else 0.38)
	retreat.tween_property(self,"moving_offset",Vector2.ZERO,0.24 if followup else 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await retreat.finished
	duel_attacking = false
	if Cards.base_id(id) == 3: audio.play("DSSGCOCK",-16)
	if counter_id>=0:
		await animate_counter(counter_id,side,lane,target_lane,start,finish,counter_damage)
	if duel_active:
		var reform := create_tween()
		reform.tween_property(self,"duel_mix",0.0,0.18 if followup else 0.3)
		await reform.finished
		duel_active = false
	moving_side = -1
	moving_lane = -1

func animate_counter(id: int, side: int, lane: int, target_lane: int, destination: Vector2, origin: Vector2, damage: int) -> void:
	var data: Dictionary = Cards.DATA[id]
	counter_visual_id = id
	counter_visual_lane = target_lane
	counter_offset = Vector2.ZERO
	counter_pose_started = clock
	counter_animating = true
	projectile_side = 1-side
	var mini: bool = data.get("actor","")=="Minigunner" or data.get("dual_minigun",false)
	attack_pose_duration = 0.65 if mini else maxf(0.6,minf(1.2,art.attack_textures.get(data.art,[]).size()*0.1))
	var melee: bool = data.type=="MELEE"
	var windup := create_tween()
	windup.tween_property(self,"counter_offset",(destination-origin)*(0.68 if melee else 0.18),attack_pose_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await windup.finished
	if not mini: audio.monster(id,"attack")
	if not melee:
		projectile_type = data.type
		projectile_art = projectile_key(id)
		minigun_firing = mini
		for tracer in (4 if mini else 1):
			if mini: audio.monster(id,"attack")
			projectile = origin+counter_offset
			if data.get("dual_minigun",false): projectile += Vector2(0,12 if tracer%2==0 else -12) if duel_active else Vector2(12 if tracer%2==0 else -12,0)
			var flight := create_tween()
			flight.tween_property(self,"projectile",destination,0.16 if mini else (0.28 if data.type=="BULLET" else 0.44))
			await flight.finished
		projectile = Vector2(-100,-100)
		minigun_firing = false
	retaliation_started = clock
	spawn_impact(id,destination)
	audio.impact(data.type)
	numbers.append({"pos":destination+Vector2(0,-34),"text":"COUNTER","life":0.75,"color":Color("ff6068")})
	hit(side,lane,damage,data.type,true,id)
	log_line(data.name+" retaliates for %d (shield absorbs 1; ignores armor)." % damage)
	var retreat := create_tween()
	retreat.tween_interval(0.38)
	retreat.tween_property(self,"counter_offset",Vector2.ZERO,0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await retreat.finished
	if Cards.base_id(id)==3: audio.play("DSSGCOCK",-16)
	counter_animating = false
	counter_finished_at = clock
	# Resolve death presentation only after the defender's last action finishes.
	# Damage, kills, Souls and death-spawns already resolved in their original order.
	if not pending_counter_death.is_empty():
		show_unit_death(pending_counter_death.id,pending_counter_death.center)
		pending_counter_death.clear()
	counter_visual_active = false
	await get_tree().create_timer(0.32).timeout

func apply_attack_traits(side: int, lane: int, data: Dictionary) -> void:
	var targets: Array = enemy if side==0 else friendly
	if data.get("chill",false) and not targets[lane].is_empty():
		targets[lane].chilled = true
		var pos := duel_hit_position(1-side,lane)
		burst(pos,Color("9deaff"),16)
		numbers.append({"pos":pos,"text":"CHILLED -1 ATK","life":1.0,"color":Color("9deaff")})
	if data.get("lifesteal",0)>0:
		if side==0:
			player_hp = mini(30,player_hp+data.lifesteal)
		else:
			enemy_hp = mini(30+mini(wins,5)*2,enemy_hp+data.lifesteal)

func unit_hit_strength(unit: Dictionary) -> float:
	return clampf(1.0-(clock-float(unit.get("visual_hit_at",-1000.0)))/0.42,0.0,1.0)

func unit_hit_offset(unit: Dictionary) -> Vector2:
	var strength := unit_hit_strength(unit)
	var age := clock-float(unit.get("visual_hit_at",-1000.0))
	return Vector2(cos(age*75)*8,sin(age*55)*3)*strength

func hit(side: int, lane: int, damage: int, kind: String, counter := false, source_id := -1, source := "") -> void:
	var targets: Array = friendly if side == 0 else enemy
	if targets[lane].is_empty():
		return
	# Track each struck unit independently, including shields, counters and splash.
	# The same dictionary also drives the dying defender's final counter animation.
	targets[lane].visual_hit_at = clock
	var incoming_damage := damage
	var previous_hp: int = targets[lane].hp
	var had_shield: bool = targets[lane].shield
	var armor_before: int = 0 if counter else Cards.armor(targets[lane])
	var target_name: String = ("YOUR " if side==0 else "CPU ")+Cards.DATA[targets[lane].id].name+" / LANE %d" % (lane+1)
	var center := duel_hit_position(side,lane)
	if targets[lane].shield:
		audio.play("DSITMBK",-14)
		targets[lane].shield = false
		burst(center,Color("69c5ff"),18)
		numbers.append({"pos":center,"text":"WARD -1" if counter and damage>1 else "BLOCKED","life":0.8,"color":Color("69c5ff")})
		if not counter or damage<=1:
			battle_tools.record(turn,target_name+" blocks the hit","Shield consumed. Incoming %s damage: %d. HP remains %d." % [kind,incoming_damage,previous_hp])
			return
		damage -= 1
	var suit_was_broken: bool = targets[lane].get("suit_broken",false)
	damage = Cards.receive_damage(targets[lane],damage,counter)
	if side==1:
		match_flair.record(Cards.DATA[source_id].name if source_id>=0 else source,mini(previous_hp,maxi(0,previous_hp-targets[lane].hp)),targets[lane].hp<=0,source_id)
	battle_tools.record(turn,target_name+" takes %d%s" % [damage," COUNTER" if counter else " DAMAGE"],"%s hit. Incoming: %d. Shield reduction: %d. Armour: %d%s. HP: %d -> %d. Applied: %d. Incoming normal-attack damage already includes type and squad modifiers; suit protection can limit damage." % [kind,incoming_damage,1 if had_shield else 0,armor_before," (ignored by counters)" if counter else "",previous_hp,maxi(0,targets[lane].hp),damage])
	if not suit_was_broken and targets[lane].get("suit_broken",false):
		burst(center,Color("a9c3d5"),48)
		audio.play("DSBAREXP",-10)
		numbers.append({"pos":center+Vector2(0,-42),"text":"SUIT DESTROYED","life":1.5,"color":Color("ffda73")})
		log_line("Mecha-Hitler's suit breaks! Overflow blocked; armor lost for this deployment.")
	hit_side = side
	hit_lane = lane
	hit_flash = 1.0
	burst(center,TYPE_COLORS.get(kind,ORANGE),24 if kind == "ROCKET" else 12)
	numbers.append({"pos":center,"text":"-%d" % damage,"life":0.9,"color":ORANGE})
	if targets[lane].hp <= 0:
		var id: int = targets[lane].id
		var token: bool = targets[lane].get("token",false)
		if counter_visual_active and side==1-moving_side and lane==counter_visual_lane and not counter:
			pending_counter_death = {"id":id,"center":center}
		else:
			show_unit_death(id,center)
		targets[lane] = {}
		if side == 1:
			if not token:
				enemy_discard.append(id)
			souls += 1
			kills += 1
		elif not token:
			grave.append(id)
			discard.append(id)
		if side==0: hero_power.cpu_souls += 1
		log_line(Cards.DATA[id].name+" destroyed.")
		if Cards.DATA[id].has("death_spawn"):
			spawn_token(side,lane,Cards.DATA[id].death_spawn)
	else:
		audio.monster(targets[lane].id,"pain")

func show_unit_death(id: int, center: Vector2) -> void:
	audio.monster(id,"death")
	burst(center,Color("b53d34"),38)
	burst(center,Color("696b65"),20)

func spawn_token(side: int, lane: int, id: int) -> void:
	var row: Array = friendly if side == 0 else enemy
	if not row[lane].is_empty():
		return
	row[lane] = Cards.unit(id,true)
	row[lane].token = true
	if busy:
		row[lane].combat_attack = 0
		row[lane].combat_breach = 0
	burst(lane_rect(side,lane).get_center(),Color("d491f0"),24)
	play_summon_sound(id)

func burst(pos: Vector2, color: Color, count: int) -> void:
	for i in count:
		particles.append({"pos":pos,"vel":Vector2(rng.randf_range(-150,150),rng.randf_range(-170,80)),"life":rng.randf_range(0.3,0.8),"color":color,"size":rng.randf_range(2,6)})

func can_revive() -> bool:
	if souls < 3 or grave.is_empty() or not friendly.has({}) or ended:
		return false
	for unit in friendly:
		if not unit.is_empty() and Cards.base_id(unit.id) == 7 and unit.cooldown == 0:
			return true
	return false

func revive() -> void:
	if not can_revive():
		return
	for unit in friendly:
		if not unit.is_empty() and Cards.base_id(unit.id) == 7 and unit.cooldown == 0:
			unit.cooldown = 2
			break
	for i in 4:
		if friendly[i].is_empty():
			var id: int = grave.pop_back()
			discard.erase(id)
			friendly[i] = Cards.unit(id,true)
			audio.play("DSSLOP",-10)
			play_summon_sound(id)
			friendly[i].hp = maxi(1,Cards.DATA[id].hp/2)
			souls -= 3
			burst(lane_rect(0,i).get_center(),Color("c36aff"),32)
			log_line("Arch-vile resurrects "+Cards.DATA[id].name)
			return

func check_end() -> bool:
	if ended:
		return true
	if player_hp > 0 and enemy_hp > 0:
		return false
	ended = true
	won = enemy_hp <= 0 and player_hp > 0
	battle_voice.outcome = true
	if player_hp<=0 and enemy_hp<=0:
		battle_voice.announce("MUTUAL DESTRUCTION")
		battle_voice.react("defeat",true)
	elif won:
		battle_voice.announce("VICTORY")
		battle_voice.react("defeat",true)
	else:
		battle_voice.announce("DEFEAT")
		battle_voice.react("victory",true)
	audio.play("DSGETPOW" if won else "DSPDIEHI",-8)
	if won:
		wins += 1
		credits += 75
		rewards = [rng.randi_range(0,4),rng.randi_range(5,7),rng.randi_range(8,Cards.CATALOG_SIZE-1)]
		modal = "reward"
	else:
		modal = "draw" if player_hp<=0 and enemy_hp<=0 else "defeat"
	save_progress()
	return true

func draw_modal() -> void:
	draw_rect(Rect2(0,0,1440,940),Color(0.005,0.009,0.015,0.94))
	if modal=="matchup":
		match_flair.draw_intro(self)
		return
	if modal in ["reward","defeat","draw"]: match_flair.draw_highlights(self)
	if modal in ["mulligan","history","energy_curve"]:
		battle_tools.draw(self)
		return
	if modal in ["reward","defeat","draw"]: button(battle_tools.HISTORY_BUTTON,"COMBAT HISTORY")
	if modal == "commanders":
		draw_commanders()
	elif modal == "deck_combos":
		draw_deck_combos()
	elif modal == "combos":
		draw_combo_guide()
	elif modal == "collection":
		button(Rect2(790,90,240,44),"ENERGY CURVE")
		label_at(Vector2(74,65),"ARMORY / "+str(deck_book.entries[editing_deck].name).to_upper(),28)
		button(DECKS_BUTTON,"MY DECKS  /  %d" % deck_book.entries.size())
		label_at(Vector2(74,103),"%d / 20 CARDS     %d / %d DECK POINTS" % [decklist.size(),DeckRules.cost(decklist),DeckRules.BUDGET],20,ORANGE)
		label_at(Vector2(74,130),"POINTS = deck budget. ENERGY = cost to play in battle. Click a card to add it.",16,MUTED)
		button(DECK_FILTER,"CLEAR SQUAD FILTER" if armory_combo_filter>=0 else ("SHOW COLLECTION" if deck_only else "SHOW DECK CARDS"))
		button(DECK_COMBOS_BUTTON,"DECK COMBOS / %d READY" % deck_combo_count(decklist))
		for slot in range(collection_page*COLLECTION_PAGE_SIZE,mini((collection_page+1)*COLLECTION_PAGE_SIZE,armory_count())):
			var i: int = armory_ids()[slot]
			var rect := collection_rect(slot)
			card(rect,i)
			label_at(rect.position+Vector2(0,211),"%d PTS / %d E   %d/%d COPIES" % [DeckRules.points(i),Cards.DATA[i].cost,decklist.count(i),mini(collection[i],DeckRules.copies(i))],14,MUTED)
			button(Rect2(rect.position+Vector2(0,225),Vector2(rect.size.x,36)),"REMOVE A COPY")
		button(Rect2(76,819,320,55),"SAVE / USE DECK" if DeckRules.issue(decklist,collection).is_empty() else "SAVE DRAFT / RETURN")
		button(Rect2(432,819,300,55),"RESTORE STARTER")
		button(PACK_FILTER,"ALL CARDS" if pack_only else "NEW %d" % (Cards.CATALOG_SIZE-Cards.LEGACY_SIZE))
		button(PREVIOUS_PAGE,"< PREV",collection_page > 0)
		button(NEXT_PAGE,"NEXT >",(collection_page+1)*COLLECTION_PAGE_SIZE < armory_count())
		label_at(Vector2(1100,852),"%d / %d" % [collection_page+1,maxi(1,ceili(float(armory_count())/COLLECTION_PAGE_SIZE))],16,INK)
		var problem := DeckRules.issue(decklist,collection)
		label_at(Vector2(76,780),deck_message if not deck_message.is_empty() else ("READY. Changes apply next match." if problem.is_empty() else problem),17,ORANGE)
		label_at(Vector2(76,914),"Copies: Common 3 / Rare 2 / others 1. Max 6 premium cards, including up to 2 Mythics.",16,MUTED)
	elif modal == "deck_guide":
		draw_deck_guide()
	elif modal in ["decks","deck_name"]:
		draw_deck_manager()
	elif modal == "reward":
		label_at(Vector2(395,190),"CONTAINMENT SUCCESSFUL",36,ORANGE)
		label_at(Vector2(420,235),"+75 CREDITS  /  REWARD CLAIMED" if reward_claimed else "+75 CREDITS  /  CHOOSE A CARD FOR YOUR COLLECTION",16)
		for i in rewards.size():
			card(Rect2(365+i*244,320,195,230),rewards[i])
		label_at(Vector2(421,614),"Reward saved. Choose where to go next." if reward_claimed else "Choose one reward, then return home or start your next match.",17,MUTED)
		button(Rect2(400,850,300,55),"MAIN MENU",reward_claimed)
		button(Rect2(740,850,300,55),"NEXT MATCH",reward_claimed)
	else:
		label_at(Vector2(440,325),"MUTUAL DESTRUCTION" if modal=="draw" else "CONTAINMENT BREACHED",36,Color("ec8a78"))
		label_at(Vector2(442,376),"Hell claims both sides. The match is a draw." if modal=="draw" else Commanders.entry(enemy_commander).name+" wins. Rebuild your strategy and try again.",17,MUTED)
		button(Rect2(490,451,400,64),"RESTART CONTAINMENT")

func armory_ids() -> Array:
	if armory_combo_filter>=0:
		var combo: Dictionary = Squads.COMBOS[armory_combo_filter]
		return range(Cards.CATALOG_SIZE).filter(func(id): return combo.groups.any(func(group): return Squads.matches(id,group)))
	if deck_only:
		var ids: Array = []
		for id in decklist:
			if not ids.has(id): ids.append(id)
		ids.sort()
		return ids
	return range(Cards.LEGACY_SIZE if pack_only else 0,Cards.CATALOG_SIZE)

func armory_count() -> int:
	return armory_ids().size()

func collection_rect(index: int) -> Rect2:
	var slot := index%COLLECTION_PAGE_SIZE
	return Rect2(76+(slot%6)*216,150+(slot/6)*300,178,184)

func modal_click(pos: Vector2) -> void:
	if modal=="deck_guide" and guide_tutorial:
		deck_guide_click(pos)
		return
	if modal in ["home","options","new_match","leave_match","mode_tutorial"]:
		frontend.click(self,pos)
		return
	if modal in ["mulligan","history","energy_curve"]:
		battle_tools.click(self,pos)
		return
	if modal in ["reward","defeat","draw"] and battle_tools.HISTORY_BUTTON.has_point(pos):
		battle_tools.open_history(self)
		return
	if (modal=="collection" and Rect2(790,90,240,44).has_point(pos)) or (modal=="deck_guide" and guide_step>0 and battle_tools.CURVE_BUTTON.has_point(pos)):
		battle_tools.open_curve(self,guide_cards if modal=="deck_guide" else decklist)
		return
	if modal == "commanders":
		for i in Commanders.ROSTER.size():
			if commander_choice_rect(i).has_point(pos):
				commander_draft = Commanders.ROSTER[i].id
				audio.play("DSSWTCHN",-23)
		if Rect2(520,650,400,60).has_point(pos):
			chosen_commander = commander_draft
			commander_selected = true
			save_progress()
			modal = "home" if frontend.at_home else ""
			if initial_commander_choice:
				initial_commander_choice = false
				new_battle()
			else:
				log_line("Character saved for next match: "+Commanders.entry(chosen_commander).name)
		elif Rect2(600,735,240,45).has_point(pos):
			initial_commander_choice = false
			modal = "home" if frontend.at_home else ""
		return
	if modal == "deck_combos":
		if Rect2(60,840,200,50).has_point(pos): combo_page = maxi(0,combo_page-1)
		elif Rect2(280,840,200,50).has_point(pos): combo_page = mini(int((Squads.COMBOS.size()-1)/12),combo_page+1)
		elif Rect2(1100,840,240,50).has_point(pos): modal = "collection"
		else:
			for i in range(combo_page*12,mini((combo_page+1)*12,Squads.COMBOS.size())):
				if Rect2(50+(i%2)*680,166+int((i%12)/2)*78,650,72).has_point(pos):
					armory_combo_filter = i
					collection_page = 0
					deck_message = "Squad pieces: "+Squads.COMBOS[i].name
					modal = "collection"
		return
	if modal == "deck_guide":
		deck_guide_click(pos)
		return
	if modal in ["decks","deck_name"]:
		deck_manager_click(pos)
		return
	if modal == "combos":
		if Rect2(60,840,200,50).has_point(pos):
			combo_page = maxi(0,combo_page-1)
		if Rect2(280,840,200,50).has_point(pos):
			combo_page = mini(int((Squads.COMBOS.size()-1)/12),combo_page+1)
		if Rect2(1100,840,240,50).has_point(pos):
			modal = ""
		return
	if modal == "collection":
		if DECK_COMBOS_BUTTON.has_point(pos):
			combo_page = 0
			modal = "deck_combos"
			return
		if DECKS_BUTTON.has_point(pos):
			store_deck_draft()
			modal = "decks"
			deleting_deck = -1
			deck_message = ""
			return
		if DECK_FILTER.has_point(pos):
			if armory_combo_filter>=0:
				armory_combo_filter = -1
				deck_only = false
				deck_message = ""
			else:
				deck_only = not deck_only
			collection_page = 0
			return
		if PACK_FILTER.has_point(pos):
			armory_combo_filter = -1
			deck_only = false
			pack_only = not pack_only
			collection_page = 0
			return
		if PREVIOUS_PAGE.has_point(pos):
			audio.play("DSSWTCHN",-18)
			collection_page = maxi(0,collection_page-1)
			return
		if NEXT_PAGE.has_point(pos):
			audio.play("DSSWTCHN",-18)
			collection_page = mini(maxi(1,ceili(float(armory_count())/COLLECTION_PAGE_SIZE))-1,collection_page+1)
			return
		for slot in range(collection_page*COLLECTION_PAGE_SIZE,mini((collection_page+1)*COLLECTION_PAGE_SIZE,armory_count())):
			var i: int = armory_ids()[slot]
			var rect := collection_rect(slot)
			if rect.has_point(pos):
				deck_message = DeckRules.issue(decklist+[i],collection,false)
				if deck_message.is_empty():
					audio.play("DSWPNUP",-16)
					decklist.append(i)
			if Rect2(rect.position+Vector2(0,225),Vector2(rect.size.x,36)).has_point(pos):
				audio.play("DSSWTCHX",-18)
				decklist.erase(i)
				deck_message = ""
				collection_page = mini(collection_page,maxi(0,maxi(1,ceili(float(armory_count())/COLLECTION_PAGE_SIZE))-1))
				return
		if Rect2(76,819,320,55).has_point(pos):
			close_collection()
		if Rect2(432,819,300,55).has_point(pos):
			decklist = Cards.STARTER.duplicate()
			deck_message = "Starter loaded. Save to use it next match."
	elif modal == "reward":
		if reward_claimed:
			if Rect2(400,850,300,55).has_point(pos):
				frontend.open(self)
				frontend.started = false
			elif Rect2(740,850,300,55).has_point(pos): frontend.choose_match(self)
			return
		for i in rewards.size():
			if Rect2(365+i*244,320,195,230).has_point(pos):
				audio.play("DSITEMUP",-12)
				collection[rewards[i]] += 1
				reward_claimed = true
				save_progress()
				return
	elif Rect2(490,451,400,64).has_point(pos):
		frontend.choose_match(self)

func close_collection() -> void:
	store_deck_draft()
	deck_book.activate(editing_deck,collection)
	save_progress()
	audio.play("DSDORCLS",-17)
	modal = "decks" if frontend.at_home else ""

func store_deck_draft() -> void:
	deck_book.entries[editing_deck].cards = decklist.duplicate()
	deck_book.ensure_active(collection)
	save_progress()

func progress_data() -> Dictionary:
	var data: Dictionary = deck_book.snapshot()
	data.merge({"commander":chosen_commander,"version":2,"wins":wins,"credits":credits,"collection":collection,"deck":deck_book.battle_cards()})
	return data

func save_progress() -> void:
	if "--smoke-test" in OS.get_cmdline_user_args() or "--balance-test" in OS.get_cmdline_user_args():
		return
	var file := FileAccess.open("user://collection.json",FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(progress_data()))

func load_progress() -> void:
	if "--balance-test" in OS.get_cmdline_user_args():
		return
	if not FileAccess.file_exists("user://collection.json"):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string("user://collection.json"))
	apply_saved_progress(data)

func apply_saved_progress(data: Variant) -> bool:
	if not data is Dictionary or (data.get("version",0)!=1 and data.get("version",0)!=2):
		return false
	var saved_collection = data.get("collection",[])
	var saved_deck = data.get("deck",[])
	if not saved_collection is Array or saved_collection.size() < 12 or saved_collection.size() > Cards.CATALOG_SIZE or not saved_deck is Array or saved_deck.size() != 20:
		return false
	for id in saved_deck:
		if not (id is float or id is int) or id != int(id) or int(id) < 0 or int(id) >= saved_collection.size():
			return false
	for amount in saved_collection:
		if not (amount is float or amount is int) or amount != int(amount) or amount < 0:
			return false
	var normalized_deck: Array = saved_deck.map(func(id): return int(id))
	for i in saved_collection.size():
		if normalized_deck.count(i) > int(saved_collection[i]):
			return false
	decklist.assign(saved_deck.map(func(id): return int(id)))
	collection.assign(saved_collection.map(func(amount): return int(amount)))
	# Extend old collections without replacing their customized deck or progress.
	while collection.size() < Cards.CATALOG_SIZE:
		collection.append(3)
	deck_book.restore(data,decklist,collection)
	editing_deck = maxi(0,deck_book.active) if data.get("version",1)==2 else 0
	decklist = deck_book.entries[editing_deck].cards.duplicate()
	wins = int(data.get("wins",0))
	credits = int(data.get("credits",0))
	commander_selected = Commanders.valid(data.get("commander"))
	chosen_commander = data.commander if commander_selected else Commanders.DEFAULT
	return true

func play_summon_sound(id: int) -> void:
	if not art.monster_sounds.get(Cards.DATA[id].art,{}).get("summon",[]).is_empty():
		audio.monster(id,"summon")
		return
	var sound_map := {0:["DSBGSIT1","DSBGSIT2"],1:["DSPOSIT1","DSPOSIT2","DSPOSIT3"],2:["DSSGTSIT"],3:["DSPOSIT1","DSPOSIT2","DSPOSIT3"],4:["DSSKLATK"],5:["DSCACSIT"],6:["DSBRSSIT"],7:["DSVILSIT"],8:["DSCYBSIT"],14:["DSSGTSIT"],15:["DSPOSIT1","DSPOSIT2","DSPOSIT3"],16:["DSKNTSIT"],17:["DSSKESIT"],18:["DSMANSIT"],19:["DSBSPSIT"],20:["DSPESIT"],21:["DSSPISIT"],22:["DSWPNUP"],23:["DSSSSIT"],24:["DSBOSSIT"]}
	var choices: Array = sound_map.get(Cards.base_id(id),[])
	if choices.is_empty():
		return
	var key: String = choices[rng.randi_range(0,choices.size()-1)]
	audio.play(key)

func capture() -> void:
	if "--cpu-reinforcement" in OS.get_cmdline_user_args():
		enemy[1] = Cards.unit(Cards.by_actor("VoidPinky"))
		cpu_support = {"id":2,"lane":1,"target":"VOID PINKY"}
		cpu_support_progress = 0.55
	if "--squad-marks" in OS.get_cmdline_user_args():
		hand = [1,3,15,8,0]
		squad_marks = {0:true,1:true,2:true,3:true}
		energy = 3
	if "--squad-glow" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(3,true),Cards.unit(15,true),Cards.unit(2),Cards.unit(Cards.leveled_id(1,4),true)]
		enemy = [{},{},{},{}]
		selected = -1
	if "--reinforcement" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(2,true),Cards.unit(14),Cards.unit(0),{}]
		friendly[0].hp = 3
		hand = [Cards.leveled_id(14,7)]
		energy = 8
		selected = 0
		drag_index = 0
		dragging = true
		drag_position = lane_rect(0,0).get_center()
	if "--retaliation" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(0),{},{},{}]
		enemy = [Cards.unit(2),{},{},{}]
		cinematic_enabled = true
		busy = true
		attack(0,0)
		while retaliation_started<0:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://captures/retaliation.png")
		get_tree().quit()
		return
	if "--deck-combos" in OS.get_cmdline_user_args():
		modal = "deck_combos"
	if "--decks" in OS.get_cmdline_user_args():
		deck_book.create("Frozen Legion",DeckRules.legalize(Cards.pack_starter()))
		deck_book.create("Cyber Siege",EnemyAI.deck_for(1,4))
		deck_book.create("Work in Progress",[0,1,2])
		modal = "decks"
		if "--deck-name" in OS.get_cmdline_user_args(): open_deck_name(1)
	if "--selected-pack" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(Cards.by_actor("ScientistFreeze")),Cards.unit(Cards.by_actor("FrozenImp")),Cards.unit(Cards.by_actor("Cryocubus")),Cards.unit(Cards.by_actor("CyberKnight"))]
		enemy = [Cards.unit(Cards.by_actor("DarkCaco")),Cards.unit(Cards.by_actor("Draugr")),Cards.unit(Cards.by_actor("HellstormArchon")),Cards.unit(Cards.by_actor("Annihilator"))]
		hand = [Cards.by_actor("HelmetMan"),Cards.by_actor("Minigunner"),Cards.by_actor("TechGunman"),Cards.by_actor("HellAfrit"),Cards.by_actor("CardinalDemon")]
		energy = 8
		max_energy = 8
		selected = -1
		toast_time = 0.0
		if "--pack-armory" in OS.get_cmdline_user_args():
			pack_only = true
			collection_page = 0
			modal = "collection"
	if "--levels" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(Cards.leveled_id(16,6)),Cards.unit(Cards.leveled_id(15,7)),Cards.unit(Cards.leveled_id(18,6)),Cards.unit(Cards.leveled_id(1,10))]
		Squads.reinforce(friendly[3],1)
		enemy = [Cards.unit(Cards.leveled_id(2,6)),Cards.unit(Cards.leveled_id(19,7)),Cards.unit(Cards.leveled_id(5,6)),{}]
		hand = [Cards.leveled_id(0,5),Cards.leveled_id(1,8),Cards.leveled_id(3,10),Cards.leveled_id(14,7),9]
		turn = 16
		energy = 8
		max_energy = 8
		selected = -1
		toast_time = 0.0
	if "--combo-guide" in OS.get_cmdline_user_args():
		modal = "combos"
	if "--showcase" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(0),Cards.unit(8),{},Cards.unit(5)]
		enemy = [Cards.unit(2),Cards.unit(6),Cards.unit(3),{}]
		hand = [0,3,7,9,10]
		energy = 6
		max_energy = 6
		souls = 3
		selected = -1
		toast_time = 0.0
	if "--inspect" in OS.get_cmdline_user_args():
		selected = 0
	if "--founders" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(0),Cards.unit(12),Cards.unit(13),Cards.unit(5)]
		hand = [12,13,9,0,10]
		selected = 0
	if "--armory" in OS.get_cmdline_user_args():
		modal = "collection"
		if "--new-roster" in OS.get_cmdline_user_args():
			audio.play("DSSWTCHN",-18)
			collection_page = 1
		if "--variants" in OS.get_cmdline_user_args():
			audio.play("DSSWTCHN",-18)
			collection_page = 5
	if "--new-roster" in OS.get_cmdline_user_args() and modal != "collection":
		friendly = [Cards.unit(22),Cards.unit(17),Cards.unit(18),Cards.unit(21)]
		enemy = [Cards.unit(16),Cards.unit(19),Cards.unit(20),Cards.unit(15)]
		hand = [22,17,18,19,20,24]
		energy = 7
		max_energy = 7
		selected = 0
	if "--variants" in OS.get_cmdline_user_args() and modal != "collection":
		friendly = [Cards.unit(25),Cards.unit(56),Cards.unit(63),Cards.unit(79)]
		enemy = [Cards.unit(18),Cards.unit(19),Cards.unit(20),Cards.unit(21)]
		hand = [25,44,63,79,22]
		energy = 8
		max_energy = 8
		souls = 6
		selected = 2
		arrival_rarity = 5
		arrival = 1.8
		arrival_center = lane_rect(0,2).get_center()
	if "--summons" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(0,true),Cards.unit(14,true),Cards.unit(13,true),Cards.unit(5)]
		enemy = [Cards.unit(2,true),Cards.unit(1),{},{}]
		hand = [14,0,3,9,10]
		selected = 0
		energy = 2
	if "--drag-demo" in OS.get_cmdline_user_args():
		selected = 0
		drag_index = 0
		dragging = true
		drag_position = lane_rect(0,2).get_center()
	await get_tree().create_timer(1.0).timeout
	if "--effects" in OS.get_cmdline_user_args():
		friendly = [Cards.unit(0),Cards.unit(8),Cards.unit(19),Cards.unit(5)]
		enemy = [Cards.unit(2),Cards.unit(6),Cards.unit(1),Cards.unit(5)]
		moving_side = 0
		moving_lane = 0
		attack_started = clock-0.16
		projectile = Vector2(420,335)
		projectile_type = "FIRE"
		projectile_art = "BAL1"
		spawn_impact(8,lane_rect(1,1).get_center())
		spawn_impact(19,lane_rect(1,2).get_center())
		queue_redraw()
		await get_tree().process_frame
	if "--cinematic" in OS.get_cmdline_user_args():
		cinematic_enabled = true
		friendly = [Cards.unit(0),{},{},{}]
		enemy = [Cards.unit(2),{},{},{}]
		moving_side = 0
		moving_lane = 0
		duel_active = true
		duel_mix = 1.0
		duel_attacker = 0
		duel_defender = 2
		duel_target_lane = 0
		duel_start = Vector2(475,425)
		duel_finish = Vector2(950,425)
		duel_struck = false
		duel_attacking = true
		attack_started = clock-0.28
		projectile = Vector2(720,425)
		projectile_art = "BAL1"
		projectile_type = "FIRE"
		queue_redraw()
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://captures")
	var filename := "table-drag.png" if "--drag-demo" in OS.get_cmdline_user_args() else ("table-inspect.png" if "--inspect" in OS.get_cmdline_user_args() else "table.png")
	if "--founders" in OS.get_cmdline_user_args():
		filename = "founders.png"
	if "--armory" in OS.get_cmdline_user_args():
		filename = "armory.png"
	if "--summons" in OS.get_cmdline_user_args():
		filename = "summons.png"
	if "--new-roster" in OS.get_cmdline_user_args() and modal != "collection":
		filename = "new-roster.png"
	if "--variants" in OS.get_cmdline_user_args() and modal != "collection":
		filename = "variants.png"
	if "--effects" in OS.get_cmdline_user_args():
		filename = "attack-effects.png"
	if "--cinematic" in OS.get_cmdline_user_args():
		filename = "cinematic-battle.png"
	if "--levels" in OS.get_cmdline_user_args():
		filename = "levels.png"
	if "--combo-guide" in OS.get_cmdline_user_args():
		filename = "squad-guide.png"
	if "--selected-pack" in OS.get_cmdline_user_args():
		filename = "selected-monsters-armory.png" if "--pack-armory" in OS.get_cmdline_user_args() else "selected-monsters.png"
	if "--decks" in OS.get_cmdline_user_args(): filename = "deck-name.png" if "--deck-name" in OS.get_cmdline_user_args() else "deck-manager.png"
	if "--deck-combos" in OS.get_cmdline_user_args(): filename = "deck-combos.png"
	if "--reinforcement" in OS.get_cmdline_user_args(): filename = "reinforcement-preview.png"
	if "--squad-glow" in OS.get_cmdline_user_args(): filename = "squad-rainbow.png"
	if "--held-squad-guide" in OS.get_cmdline_user_args():
		hand = [1,3,15,14]
		friendly = [{},{},{},{}]
		modal = "combos"
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		filename = "held-squad-guide.png"
	if "--squad-marks" in OS.get_cmdline_user_args(): filename = "squad-marks.png"
	if "--cpu-reinforcement" in OS.get_cmdline_user_args(): filename = "cpu-reinforcement.png"
	get_viewport().get_texture().get_image().save_png("res://captures/"+filename)
	get_tree().quit()

func run_audio_tests() -> void:
	assert(art.sounds.size() > 100,"Full local WAD sound bank decoded")
	for id in Cards.CATALOG_SIZE:
		if Cards.DATA[id].hp <= 0:
			continue
		var base := Cards.base_id(id)
		assert(art.sounds.has(audio.ATTACK[base]),"Attack sound exists for "+Cards.DATA[id].name)
		for key in audio.DEATH[base]:
			assert(art.sounds.has(key),"Death sound exists: "+key)
	for key in ["DSBFG","DSRXPLOD","DSFIRXPL","DSSGCOCK","DSITEMUP","DSGETPOW","DSTELEPT","DSITMBK","DSSLOP","DSSWTCHN","DSNOWAY"]:
		assert(art.sounds.has(key),"Action sound exists: "+key)
	assert(not audio.play("MISSING"),"Missing audio safely ignored")
	audio.last_played.clear()
	assert(audio.play("DSRXPLOD"),"Explosion starts")
	assert(not audio.play("DSRXPLOD"),"Simultaneous splash explosions coalesced")
	assert(audio.play("DSPLPAIN"),"Voice can overlap explosion")
	assert(audio.voices.filter(func(voice): return voice.playing).size() >= 2,"Independent sound voices")
	new_battle()
	friendly = [Cards.unit(3,true),{},{},{}]
	enemy = [Cards.unit(2),{},{},{}]
	audio.last_played.clear()
	await attack(0,0)
	assert(not audio.last_played.has("DSSHOTGN"),"Waiting cards do not fire")
	friendly[0].ready = true
	await attack(0,0)
	assert(audio.last_played.has("DSSHOTGN") and audio.last_played.has("DSSGCOCK"),"Shotgun firing and pump follow combat")
	enemy[0] = Cards.unit(2)
	audio.last_played.clear()
	hit(1,0,99,"BULLET")
	assert(audio.last_played.has("DSSGTDTH"),"Lethal hit plays target death")
	print("PASS: full WAD audio, all variant mappings, overlapping voices, splash coalescing, summon silence, shotgun/pump timing, death audio")

func run_enemy_ai_tests() -> void:
	var empty := [{},{},{},{}]
	var cards := [0,0,8]
	var choices := EnemyAI.plan(empty,empty,cards,2,30,30)
	assert(choices.size()==2,"CPU plans multiple affordable deployments")
	assert(cards==[0,0,8] and empty==[{},{},{},{}],"Planning never mutates live state")
	var total := 0
	var lanes := {}
	for choice in choices:
		total += Cards.DATA[choice.id].cost
		assert(not lanes.has(choice.lane),"No duplicate lane assignments")
		lanes[choice.lane] = true
	assert(total==2,"CPU respects Energy and duplicate copies")
	assert(EnemyAI.plan(empty,empty,[8],5,30,30).is_empty(),"Unaffordable CPU card stays in hand")
	var lethal := EnemyAI.plan(empty,empty,[14,2],2,30,3)
	assert(lethal.size()==1 and lethal[0].id==14,"CPU recognizes immediate Ambush lethal")
	var threat := [{},{},Cards.unit(8),{}]
	var defense := EnemyAI.plan(empty,threat,[1],1,3,30)
	assert(defense.size()==1 and defense[0].lane==2,"CPU blocks lethal visible threat")
	new_battle()
	enemy = empty.duplicate(true)
	friendly = empty.duplicate(true)
	enemy_hand = [0,0,8]
	enemy_energy = 2
	await deploy_enemy_cards()
	assert(enemy_energy==0 and enemy_hand==[8] and enemy_plays==2,"Deployment pays each cost and consumes cards")
	assert(enemy.filter(func(unit): return not unit.is_empty() and not unit.ready).size()==2,"Normal CPU summons still wait")
	enemy_deck.clear()
	enemy_hand.clear()
	enemy_discard = [3]
	draw_enemy_card()
	assert(enemy_hand==[3] and enemy_discard.is_empty(),"CPU recycles discarded cards")
	print("PASS: CPU budget, multi-deployment, copies, non-mutating search, Ambush lethal, lethal blocking, summon delay, deck recycling")
	new_battle()

func run_director_tests() -> void:
	var first = DrawDirector.new()
	var second = DrawDirector.new()
	first.reset(12345)
	second.reset(12345)
	var pile_a: Array = [0,0,1,2,3,4,5,8,9,12,22,63,72]
	var pile_b := pile_a.duplicate()
	var original := pile_a.duplicate()
	var observed: Array = []
	while not pile_a.is_empty():
		var can_limit := pile_a.any(func(id): return not DrawDirector.powerful(id))
		var recent: Array = first.history.slice(maxi(0,first.history.size()-4))
		var at_limit := recent.filter(func(id): return DrawDirector.powerful(id)).size()>=2
		var id: int = first.take(pile_a,[],observed.is_empty())
		assert(id==second.take(pile_b,[],observed.is_empty()),"Both sides use identical seeded draw rules")
		assert(original.has(id),"Director only draws owned copies")
		original.erase(id)
		if can_limit and at_limit:
			assert(not DrawDirector.powerful(id),"Power streak capped when ordinary cards remain")
		observed.append(id)
	assert(original.is_empty() and observed.size()==13,"Director preserves the full deck multiset")
	assert(Cards.DATA[observed[0]].cost<=3 and Cards.DATA[observed[0]].hp>0,"Usable opening when available")
	first.reset(9)
	var held := [8,9]
	var pile: Array = [8,0,9]
	assert(first.take(pile,held)==0 and held==[8,9],"Strong hand draws ordinary card without changing hand")
	first.history.assign([63])
	pile = [72,0]
	assert(first.take(pile,[])==0,"No consecutive Mythics when alternative exists")
	pile = [63,72]
	assert(first.take(pile,held)>=0 and pile.size()==1,"All-power deck never blocks a legal draw")
	assert(first.take([],[])==-1,"Empty pile is safe")
	first.reset(4)
	assert(first.history.is_empty(),"History resets for a new battle")
	var saved_history: Array = player_director.history.duplicate()
	var saved_deck := deck.duplicate()
	var saved_hand := hand.duplicate()
	hand = [0,0,0,0,0,0]
	draw_card()
	assert(player_director.history==saved_history and deck==saved_deck,"Full hand does not consume draw or director history")
	hand = saved_hand
	print("PASS: symmetric seeded director, power streak cap, hand cap, opening support, Mythic spacing, copy preservation, fallback, reset, full-hand safety")

func run_balance_effect_tests() -> void:
	for prefix in WadArt.ATTACK_POSES:
		assert(not art.attack_textures.get(prefix,[]).is_empty(),"Front attack frames: "+prefix)
	for prefix in WadArt.EFFECT_POSES:
		assert(not art.effect_textures.get(prefix,[]).is_empty(),"Projectile/impact frames: "+prefix)
	assert(projectile_key(0)=="BAL1" and projectile_key(25)=="BAL1" and projectile_key(5)=="BAL2" and projectile_key(8)=="MISL","Per-monster and inherited projectile artwork")
	for edge in [0,3]:
		friendly = [{},{},{},{}]
		friendly[edge] = Cards.unit(3)
		enemy = [Cards.unit(2),Cards.unit(2),Cards.unit(2),Cards.unit(2)]
		await attack(0,edge)
		assert(enemy[3-edge].hp==6,"Edge splash never wraps to the opposite lane")
		assert(enemy[1 if edge==0 else 2].hp==5,"Edge splash hits its one legal neighbor")
	assert(Cards.DATA[9].exhaust and Cards.DATA[10].exhaust and Cards.DATA[11].cost==1,"Limited board clears and paid Soul generation")
	new_battle()
	discard.clear()
	hand = [9,10]
	energy = 8
	selected = 0
	await play_card(-1)
	selected = 0
	await play_card(-1)
	assert(not discard.has(9) and not discard.has(10),"Exhausted cards cannot reshuffle")
	turn = 14
	player_hp = 30
	enemy_hp = 30
	assert(not apply_collapse() and player_hp==30 and enemy_hp==30,"Collapse waits until round 15")
	turn = 15
	assert(not apply_collapse() and player_hp==29 and enemy_hp==29,"Collapse affects both sides equally")
	turn = 18
	player_hp = 1
	enemy_hp = 2
	assert(apply_collapse() and modal=="defeat" and enemy_hp==1,"Collapse stops on first lethal tick")
	new_battle()
	turn = 15
	player_hp = 1
	enemy_hp = 1
	var prior_wins := wins
	assert(apply_collapse() and modal=="draw" and wins==prior_wins,"Simultaneous defeat is a draw without win rewards")
	new_battle()
	print("PASS: attack/projectile WAD frames, variant artwork inheritance, exhaust, Soul cost, collapse timing and draw handling")

func run_cinematic_tests() -> void:
	var outcomes: Array = []
	for enabled in [false,true]:
		new_battle()
		cinematic_enabled = enabled
		friendly = [Cards.unit(0),{},{},{}]
		enemy = [Cards.unit(2),{},{},{}]
		await attack(0,0)
		assert(not duel_active and is_zero_approx(duel_mix),"Battle view finishes and reforms cards")
		outcomes.append([enemy[0].hp,player_hp,enemy_hp,souls])
	assert(outcomes[0]==outcomes[1],"Cinematic presentation cannot change combat outcome")
	enemy[0] = Cards.unit(1)
	enemy[0].hp = 3 # Wounded target remains lethal with the smaller Fire weakness bonus.
	await attack(0,0)
	assert(enemy[0].is_empty() and not duel_active,"Defeated card stays destroyed after cinematic")
	assert(friendly[0].is_empty(),"Lethal retaliation also destroys the wounded attacker")
	friendly = [Cards.unit(0),{},{},{}]
	enemy = [{},{},{},{}]
	var before := enemy_hp
	var observed := {"cinematic":false}
	var watch := func(): observed.cinematic = observed.cinematic or duel_active
	get_tree().process_frame.connect(watch)
	await attack(0,0)
	assert(enemy_hp==before-2 and not observed.cinematic,"Direct CPU Health hit stays on the table throughout")
	friendly = [{},{},{},{}]
	enemy = [Cards.unit(1),{},{},{}]
	before = player_hp
	await attack(1,0)
	get_tree().process_frame.disconnect(watch)
	assert(player_hp==before-2 and not observed.cinematic,"Direct player Health hit stays on the table throughout")
	new_battle()
	busy = false
	modal = ""
	test_mouse(BATTLE_VIEW_BUTTON.get_center(),true)
	assert(not cinematic_enabled,"View toggle turns off")
	busy = true
	test_mouse(BATTLE_VIEW_BUTTON.get_center(),true)
	assert(not cinematic_enabled,"View cannot change mid-combat")
	busy = false
	new_battle()
	print("PASS: cinematic parity, surviving/dead card restoration, unblocked attacks, toggle and combat lock")

func run_smoke_test() -> void:
	await run_cinematic_tests()
	await run_balance_effect_tests()
	run_director_tests()
	await run_enemy_ai_tests()
	await run_audio_tests()
	await run_variant_tests()
	await run_roster_tests()
	await run_summon_tests()
	await run_founder_tests()
	run_interaction_tests()
	assert(Cards.damage(0,2)==3,"Imp exploits Pinky weakness")
	assert(Cards.damage(1,2)==1,"Resistance cannot reduce damage below one")
	assert(decklist.size()==20)
	assert(art.textures.get("TROO",[]).size()>0,"WAD sprites loaded")
	assert(art.textures.get("VILE",[]).size()>0,"Combined-rotation Arch-vile sprites loaded")
	enemy[0] = Cards.unit(5)
	hit(1,0,99,"FIRE")
	assert(enemy[0].hp==4 and not enemy[0].shield,"Shield consumes first hit")
	hit(1,0,99,"FIRE")
	assert(enemy[0].is_empty() and souls==1,"Kill grants Soul")
	friendly[0] = Cards.unit(7)
	grave = [2]
	discard = [2]
	souls = 3
	revive()
	assert(friendly[1].id==2 and friendly[0].cooldown==2 and souls==0)
	friendly = [{},{},{},{}]
	enemy = [{},{},{},{}]
	hand = [0,8,9]
	energy = 12
	selected = 0
	await play_card(0)
	assert(friendly[0].id==0 and energy==11)
	selected = 0
	await play_card(1)
	assert(friendly[1].id==8 and entrance>0)
	var health_before := enemy_hp
	enemy_hand.clear() # Isolate summon timing from the CPU's choice of Ambush cards.
	await end_turn()
	assert(turn==2 and not busy and enemy_hp==health_before and friendly[0].ready and friendly[1].ready,"New units wait through their first attack phase")
	enemy = [Cards.unit(1),Cards.unit(2),Cards.unit(5),{}]
	hand = [9]
	energy = 5
	selected = 0
	await play_card(-1)
	assert(hand==[9] and energy==5 and enemy[0].hp==4,"BFG needs seven energy")
	energy = 7
	await play_card(-1)
	assert(enemy[0].is_empty() and enemy[1].hp==2 and enemy[2].hp==4 and not enemy[2].shield and energy==0,"Nerfed BFG deals four damage, leaves Pinky alive, and respects shields")
	enemy = [Cards.unit(1),Cards.unit(6),Cards.unit(1),{}]
	friendly = [{},Cards.unit(8),{},{}]
	await attack(0,1)
	assert(enemy[0].hp==2 and enemy[2].hp==2 and enemy[1].is_empty(),"Rocket exploits weakness and splashes adjacent lanes")
	enemy_hp = 1
	enemy = [{},{},{},{}]
	await end_turn()
	assert(ended and won and modal=="reward" and rewards.size()==3,"Victory offers reward")
	new_battle()
	player_hp = 0
	check_end()
	assert(ended and not won and modal=="defeat","Defeat and restart")
	new_battle()
	assert(player_hp==30 and not ended and hand.size()==5)
	print("PASS: WAD art, 20-card deck, weakness, resistance, shield, Souls, resurrection, deploy, legendary entrance, full turn, BFG, rocket splash, victory rewards, defeat, restart")
	get_tree().quit()

func run_roster_tests() -> void:
	for id in range(15,Cards.CATALOG_SIZE):
		assert(not art.textures.get(Cards.DATA[id].art,[]).is_empty(),"Missing roster art: "+Cards.DATA[id].name)
	for key in ["DSKNTSIT","DSSKESIT","DSMANSIT","DSBSPSIT","DSPESIT","DSSPISIT","DSSSSIT","DSBOSSIT","DSWPNUP"]:
		assert(art.sounds.has(key),"Missing sound: "+key)
	friendly = [Cards.unit(15),{},{},{}]
	enemy = [Cards.unit(5),{},{},{}]
	await attack(0,0)
	assert(enemy[0].is_empty(),"Double burst consumes shield then kills bullet-weak Cacodemon")
	friendly[0] = Cards.unit(19)
	enemy = [{},{},{},{}]
	enemy_hp = 30
	await attack(0,0)
	assert(enemy_hp==26,"Arachnotron fires twice")
	friendly[0] = Cards.unit(21)
	await attack(0,0)
	assert(enemy_hp==20,"Spider fires three times")
	friendly[0] = Cards.unit(17)
	enemy = [{},{},Cards.unit(6),{}]
	await attack(0,0)
	assert(enemy[2].hp==1 and enemy_hp==20,"Revenant homes off-lane with the smaller Rocket weakness bonus")
	friendly = [{},Cards.unit(18),{},{}]
	enemy = [Cards.unit(1),Cards.unit(6),Cards.unit(1),{}]
	await attack(0,1)
	assert(enemy[0].hp==3 and enemy[2].hp==3 and enemy[1].hp==4,"Mancubus splash and resistance")
	friendly[0] = Cards.unit(22)
	hit(0,0,4,"ROCKET")
	assert(friendly[0].hp==4,"Doomguy armor reduces incoming hits")
	hit(0,0,1,"BULLET")
	assert(friendly[0].hp==3,"Armor retains minimum one damage")
	friendly = [Cards.unit(20),{},{},{}]
	hit(0,0,99,"ENERGY")
	assert(friendly[0].id==4 and friendly[0].token and not friendly[0].ready,"Pain Elemental death spawns a sleeping Lost Soul")
	var old_grave := grave.size()
	hit(0,0,99,"ENERGY")
	assert(grave.size()==old_grave,"Tokens never enter deck or resurrection pool")
	friendly = [{},{},{},Cards.unit(1)]
	hand = [24]
	selected = 0
	energy = 7
	await play_card(0)
	assert(friendly[1].id==0 and friendly[2].id==0 and friendly[1].token and not friendly[1].ready,"Icon summons Imps into empty lanes")
	hand = [23]
	selected = 0
	energy = 2
	souls = 0
	friendly[3] = {}
	await play_card(3)
	assert(souls==1,"SS secret stash")
	var old_deck := decklist.duplicate()
	modal = "collection"
	collection_page = 1
	decklist = []
	pack_only = false
	deck_only = false
	armory_combo_filter = -1
	modal_click(NEXT_PAGE.get_center())
	assert(collection_page==2)
	modal_click(collection_rect(24).get_center())
	assert(decklist==[24],"Armory page adds the correct card to an editable draft")
	collection_page = ceili(float(Cards.CATALOG_SIZE)/COLLECTION_PAGE_SIZE)-1
	modal_click(NEXT_PAGE.get_center())
	assert(collection_page==ceili(float(Cards.CATALOG_SIZE)/COLLECTION_PAGE_SIZE)-1,"Pagination stops at last page")
	decklist = old_deck
	collection_page = 0
	modal = ""
	print("PASS: full roster art/audio, multi-hit, homing, splash, armor, death spawn, tokens, Icon gate, SS stash, Armory pagination")
	new_battle()

func run_variant_tests() -> void:
	assert(Cards.LEGACY_SIZE==82 and Cards.MONSTERS.size()==19)
	for id in range(25,Cards.LEGACY_SIZE):
		assert(Cards.DATA[id].hp > Cards.BASE_DATA[Cards.base_id(id)].hp)
		assert(Cards.DATA[id].get("ambush",false)==(Cards.base_id(id)==14),"Only Spectres have Ambush")
	assert(Cards.unit(25,true).shield,"Rare ward grants first-hit shield")
	friendly = [Cards.unit(44),{},{},{}]
	hit(0,0,3,"BULLET")
	assert(friendly[0].hp==3,"Elite armor reduces incoming damage")
	energy = 8
	souls = 1
	hand = [63]
	selected = 0
	friendly = [{},{},{},{}]
	await play_card(0)
	assert(hand.size()==1 and souls==1 and energy==8,"Mythics cannot bypass Soul cost")
	souls = 2
	await play_card(0)
	assert(friendly[0].id==63 and souls==0 and energy==5 and arrival_rarity==5,"Mythic payment and entrance")
	friendly[0].ready = true
	enemy = [{},{},{},{}]
	enemy_hp = 30
	await attack(0,0)
	assert(enemy_hp==26,"Mythic Imp attacks twice")
	var original := {"version":1,"wins":wins,"credits":credits,"collection":collection.duplicate(),"deck":decklist.duplicate()}
	var legacy_deck := [0,0,0,1,12,2,14,3,3,4,4,5,5,6,7,8,9,10,13,11]
	assert(apply_saved_progress({"version":1,"wins":4,"credits":300,"collection":[3,3,3,3,3,3,3,3,3,3,3,3,3,3,3],"deck":legacy_deck}))
	assert(collection.size()==Cards.CATALOG_SIZE and collection[81]==3 and decklist==legacy_deck and credits==300)
	assert(apply_saved_progress(original))
	print("PASS: 57 variants, inherited Ambush, Rare shields, Elite armor, Mythic Soul cost/multi-strike/effects, save expansion")
	new_battle()

func run_founder_tests() -> void:
	var original := {"version":1,"wins":wins,"credits":credits,"collection":collection.duplicate(),"deck":decklist.duplicate()}
	var legacy_deck := [0,0,0,1,1,2,2,3,3,4,4,5,5,6,7,8,9,10,10,11]
	assert(apply_saved_progress({"version":1,"wins":7,"credits":123,"collection":[3,3,3,3,3,3,3,3,3,3,3,3],"deck":legacy_deck}))
	assert(collection.size()==Cards.CATALOG_SIZE and collection[12]==3 and collection[13]==3 and collection[14]==3 and decklist==legacy_deck and wins==7 and credits==123,"Old saves grant new cards without resetting deck or progress")
	assert(apply_saved_progress(original))
	assert(art.textures["CARMACK"].size()==1 and art.textures["ROMERO"].size()==1)
	friendly = [Cards.unit(0),{},Cards.unit(2),Cards.unit(1)]
	hand = [12]
	energy = 4
	selected = 0
	await play_card(1)
	assert(friendly[0].shield and friendly[2].shield and not friendly[1].shield and not friendly[3].shield and energy==0,"Carmack shields only adjacent allies")
	hit(0,0,9,"ROCKET")
	assert(friendly[0].hp==3 and not friendly[0].shield,"Carmack shield absorbs exactly one hit")
	friendly = [{},{},{},{}]
	enemy = [Cards.unit(1),{},{},{}]
	hand = [13]
	energy = 4
	selected = 0
	await play_card(0)
	souls = 0
	friendly[0].ready = true
	await attack(0,0)
	assert(enemy[0].is_empty() and souls==2,"Romero kill awards normal Soul plus one bonus")
	enemy[0] = Cards.unit(5)
	await attack(0,0)
	assert(souls==2 and enemy[0].hp==4,"Romero grants no bonus on a blocked hit")
	print("PASS: founders portraits, legacy save migration, Carmack shield targeting, Romero kill bonus")
	new_battle()

func run_summon_tests() -> void:
	assert(art.sounds.size() >= 10,"Monster alert sounds decoded from local WAD")
	var sample: AudioStreamWAV = art.sounds["DSBGSIT1"]
	assert(sample.mix_rate > 0 and sample.data.size() > 100 and sample.get_length()>0)
	assert(art.decode_sound(PackedByteArray([0,0,0,0,0,0,0,0]),0,8)==null,"Invalid DMX rejected")
	friendly = [Cards.unit(0,true),Cards.unit(14,true),{},{}]
	enemy = [{},{},{},{}]
	enemy_hand.clear()
	enemy[3] = Cards.unit(1,true)
	player_hp = 30
	enemy_hp = 30
	await end_turn()
	assert(enemy_hp==27 and player_hp==30,"Only Spectre attacks on summon; enemy normal summon also waits")
	assert(friendly[0].ready and enemy[3].ready,"Both sides ready after their summon round")
	await attack(0,0)
	assert(enemy_hp==25,"Normal unit attacks next round")
	await attack(1,3)
	assert(player_hp==28,"Enemy unit attacks next round")
	enemy[2] = Cards.unit(14,true)
	await attack(1,2)
	assert(player_hp==25,"Enemy Spectre also has Ambush")
	friendly = [Cards.unit(7),{},{},{}]
	grave = [0]
	discard = [0]
	souls = 3
	revive()
	assert(not friendly[1].ready,"Resurrected normal unit waits")
	var health_before := enemy_hp
	await attack(0,1)
	assert(enemy_hp==health_before)
	var legacy := {"version":1,"wins":wins,"credits":credits,"collection":collection.slice(0,14),"deck":[0,0,0,1,12,2,2,3,3,4,4,5,5,6,7,8,9,10,13,11]}
	var original := {"version":1,"wins":wins,"credits":credits,"collection":collection.duplicate(),"deck":decklist.duplicate()}
	assert(apply_saved_progress(legacy) and collection[14]==3,"14-card saves gain Spectre")
	assert(apply_saved_progress(original))
	print("PASS: DMX sounds, summon delay on both sides, Spectre Ambush, resurrection delay, Spectre save migration")
	new_battle()

func test_mouse(pos: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = get_global_transform_with_canvas()*pos
	event.pressed = pressed
	_unhandled_input(event)

func test_drag(from: Vector2, to: Vector2) -> void:
	test_mouse(from,true)
	var motion := InputEventMouseMotion.new()
	motion.position = get_global_transform_with_canvas()*to
	_unhandled_input(motion)
	test_mouse(to,false)

func run_interaction_tests() -> void:
	friendly = [{},{},{},{}]
	hand = [0,3,10]
	energy = 8
	test_drag(hand_rect(0).get_center(),lane_rect(0,2).get_center())
	assert(friendly[2].get("id",-1)==0 and energy==7 and hand.size()==2,"Drag deploys once and pays correct cost")
	test_drag(hand_rect(0).get_center(),lane_rect(0,2).get_center())
	assert(energy==7 and hand.size()==2 and friendly[2].id==0,"Occupied drop returns card without spending")
	test_drag(hand_rect(0).get_center(),Vector2(25,25))
	assert(energy==7 and hand.size()==2 and not dragging,"Outside drop cancels")
	energy = 0
	test_drag(hand_rect(0).get_center(),lane_rect(0,1).get_center())
	assert(friendly[1].is_empty() and hand.size()==2,"Unaffordable card cannot deploy")
	energy = 8
	test_mouse(hand_rect(0).get_center(),true)
	test_mouse(hand_rect(0).get_center(),false)
	test_mouse(lane_rect(0,1).get_center(),true)
	test_mouse(lane_rect(0,1).get_center(),false)
	assert(friendly[1].get("id",-1)==3 and energy==6,"Click-to-place remains available")
	player_hp = 20
	test_drag(hand_rect(0).get_center(),Vector2(20,20))
	assert(player_hp==20 and energy==6 and hand.size()==1,"Invalid event drop cannot cast")
	test_drag(hand_rect(0).get_center(),PLAY_AREA.get_center())
	assert(player_hp==26 and energy==5 and hand.is_empty(),"Event casts on table release")
	hand = [0]
	test_mouse(hand_rect(0).get_center(),true)
	var cancel := InputEventMouseButton.new()
	cancel.button_index = MOUSE_BUTTON_RIGHT
	cancel.pressed = true
	_unhandled_input(cancel)
	test_mouse(lane_rect(0,0).get_center(),false)
	assert(friendly[0].is_empty() and hand.size()==1 and not dragging,"Right click cancels pending drag")
	assert(Cards.DATA[5].type=="ENERGY" and Cards.DATA[3].type=="BULLET")
	assert(Cards.damage(5,8)==4,"Energy exploits Cyberdemon weakness")
	print("PASS: drag placement, invalid/occupied drops, energy validation, click placement, event drops, cancellation, ENERGY/BULLET damage")
	new_battle()

const DeckGuide = preload("res://scripts/deck_guide.gd")
var guide_step := 0
var guide_squads: Array = []
var guide_cards: Array = []
var guide_rarity := -1
var guide_page := 0
var guide_message := ""
var guide_editing := -1
var guide_tutorial := false
var guide_repair: Dictionary = {}

func draw_deck_manager() -> void:
	if modal == "deck_name":
		label_at(Vector2(180,155),"NAME YOUR DECK",32,ORANGE)
		label_at(Vector2(180,275),"Up to 24 characters. Enter to save, Escape to cancel.",20,MUTED)
		button(Rect2(180,320,250,55),"SAVE NAME")
		button(Rect2(460,320,250,55),"CANCEL")
		return
	label_at(Vector2(76,65),"UAC / MY DECKS",32,ORANGE)
	label_at(Vector2(76,104),"20 cards / 120 points. Open GUIDE for step-by-step help, suggested cuts and finishing a draft.",20)
	for i in deck_book.entries.size():
		var item: Dictionary = deck_book.entries[i]
		var y: float = 140.0+i*70
		var problem := DeckRules.issue(item.cards,collection)
		panel(Rect2(76,y,1280,62),Color("101a1e"),ORANGE if i==deck_book.active else Color("394547"))
		label_at(Vector2(92,y+25),str(item.name).to_upper(),22)
		label_at(Vector2(92,y+49),"%d/20 CARDS  %d/120 PTS  /  %s" % [item.cards.size(),DeckRules.cost(item.cards),"ACTIVE" if i==deck_book.active else ("READY" if problem.is_empty() else "DRAFT")],16,MUTED)
		if deleting_deck==i:
			label_at(Vector2(620,y+37),"DELETE THIS DECK?",20,ORANGE)
			button(Rect2(1010,y+9,150,44),"DELETE")
			button(Rect2(1180,y+9,150,44),"KEEP")
		else:
			button(Rect2(600,y+9,120,44),"EDIT CARDS")
			button(Rect2(730,y+9,120,44),"GUIDE")
			button(Rect2(860,y+9,120,44),"USE DECK",problem.is_empty())
			button(Rect2(980,y+9,145,44),"RENAME")
			button(Rect2(1140,y+9,190,44),"DELETE",deck_book.entries.size()>1)
	label_at(Vector2(76,743),deck_message,18,ORANGE)
	button(Rect2(76,780,270,55),"NEW EMPTY DECK",deck_book.entries.size()<DeckBook.LIMIT)
	button(Rect2(366,780,270,55),"UAC STARTER",deck_book.entries.size()<DeckBook.LIMIT)
	button(Rect2(1080,780,276,55),"MAIN MENU" if frontend.at_home else "BACK TO TABLE")
	button(Rect2(366,842,270,40),"GUIDED DECK BUILDER",deck_book.entries.size()<DeckBook.LIMIT)
	label_at(Vector2(656,867),"Pick squads / choose cards / make it yours",17,MUTED)
	label_at(Vector2(76,911),"Up to 8 decks. Deck points are a building limit, not currency. Energy is spent during battle.",18,MUTED)

func open_deck_name(index: int) -> void:
	naming_deck = index
	modal = "deck_name"
	name_input = LineEdit.new()
	name_input.position = Vector2(180,190)
	name_input.size = Vector2(800,60)
	name_input.max_length = 24
	name_input.add_theme_font_override("font",font)
	name_input.add_theme_font_size_override("font_size",30)
	name_input.text = deck_book.entries[index].name if index>=0 else "New Deck"
	name_input.text_submitted.connect(func(_text): finish_deck_name(true))
	name_input.gui_input.connect(func(event):
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
			name_input.accept_event()
			finish_deck_name(false))
	add_child(name_input)
	name_input.grab_focus()
	name_input.select_all()

func finish_deck_name(accept: bool) -> void:
	if not is_instance_valid(name_input): return
	if accept:
		if naming_deck<0:
			editing_deck = deck_book.create(name_input.text,[])
			decklist = []
		else:
			deck_book.rename(naming_deck,name_input.text)
		save_progress()
	name_input.queue_free()
	name_input = null
	modal = "collection" if accept and naming_deck<0 else "decks"
	deck_message = ""

func deck_manager_click(pos: Vector2) -> void:
	if modal=="deck_name":
		if Rect2(180,320,250,55).has_point(pos): finish_deck_name(true)
		elif Rect2(460,320,250,55).has_point(pos): finish_deck_name(false)
		return
	for i in deck_book.entries.size():
		var y: float = 140.0+i*70
		if deleting_deck==i:
			if Rect2(1010,y+9,150,44).has_point(pos):
				deck_book.remove(i,collection)
				editing_deck = maxi(0,deck_book.active)
				decklist = deck_book.entries[editing_deck].cards.duplicate()
				deleting_deck = -1
				save_progress()
				return
			if Rect2(1180,y+9,150,44).has_point(pos): deleting_deck = -1
			continue
		if Rect2(730,y+9,120,44).has_point(pos):
			open_guided_deck(i)
			return
		if Rect2(600,y+9,120,44).has_point(pos):
			editing_deck = i
			decklist = deck_book.entries[i].cards.duplicate()
			collection_page = 0
			deck_message = ""
			modal = "collection"
			return
		if Rect2(860,y+9,120,44).has_point(pos):
			if deck_book.activate(i,collection):
				deck_message = deck_book.entries[i].name+" selected for the next match."
				save_progress()
			else: deck_message = DeckRules.completion_message(deck_book.entries[i].cards,collection)+" Open GUIDE for suggested cuts."
		if Rect2(980,y+9,145,44).has_point(pos):
			open_deck_name(i)
			return
		if Rect2(1140,y+9,190,44).has_point(pos) and deck_book.entries.size()>1:
			deleting_deck = i
	if Rect2(1080,780,276,55).has_point(pos):
		modal = "home" if frontend.at_home else ""
		deleting_deck = -1
		return
	if deck_book.entries.size()>=DeckBook.LIMIT: return
	if Rect2(366,842,270,40).has_point(pos):
		open_guided_deck(-1)
		return
	if Rect2(76,780,270,55).has_point(pos):
		open_deck_name(-1)
		return
	if Rect2(366,780,270,55).has_point(pos):
		editing_deck = deck_book.create("UAC Starter",Cards.STARTER)
		decklist = Cards.STARTER.duplicate()
		deck_message = "Starter created. Use it now or edit and rename it."
		save_progress()

func open_guided_deck(index: int) -> void:
	guide_editing = index
	guide_cards = deck_book.entries[index].cards.duplicate() if index>=0 else []
	guide_squads = []
	for i in Squads.COMBOS.size():
		if DeckGuide.complete(guide_cards,i) and guide_squads.size()<3: guide_squads.append(i)
	guide_step = 1 if index>=0 else 0
	guide_page = 0
	guide_rarity = -1
	guide_message = "Editing "+str(deck_book.entries[index].name)+". Changes apply only when you save." if index>=0 else ""
	guide_tutorial = true
	modal = "deck_guide"

func deck_combo_count(cards: Array) -> int:
	return Squads.active(cards.map(func(id): return Cards.unit(id))).size()

func draw_deck_combos() -> void:
	label_at(Vector2(60,65),"DECK COMBOS / "+str(deck_book.entries[editing_deck].name).to_upper(),30,ORANGE)
	label_at(Vector2(60,105),"%d complete squads in this deck. Click a squad to browse its matching monsters in the Armory." % deck_combo_count(decklist),18,INK)
	glowing_squad_text(Vector2(60,151),"GREEN: INCLUDED",14,Color("9df6b7"))
	glowing_squad_text(Vector2(340,151),"RED: MISSING",14,Color("ff6068"))
	glowing_squad_text(Vector2(620,151),"RAINBOW: ALL PIECES IN DECK",14,Color("e8a9ff"),true)
	var row: Array = decklist.map(func(id): return Cards.unit(id))
	for i in range(combo_page*12,mini((combo_page+1)*12,Squads.COMBOS.size())):
		var combo: Dictionary = Squads.COMBOS[i]
		var pos := Vector2(60+(i%2)*680,190+int((i%12)/2)*78)
		var ready := not Squads.members(row,combo).is_empty()
		if ready: glowing_squad_text(pos,combo.name+" [IN DECK]",19,Color("9df6b7"),true)
		else: label_at(pos,combo.name,19,ORANGE)
		draw_squad_requirements(pos+Vector2(0,23),combo,ready,true)
		var missing: Array[String] = []
		var terms: PackedStringArray = combo.rule.split(" + ")
		for group_index in combo.groups.size():
			if not decklist.any(func(id): return Squads.matches(id,combo.groups[group_index])):
				missing.append(terms[group_index])
		var bonus := "+1 ATK" if combo.bonus=="attack" else "+1 DAMAGE VS UNITS"
		var status := bonus+" / "+("ALL PIECES INCLUDED" if ready else "MISSING: "+", ".join(missing))
		var text_size := 12
		while text_width(status,text_size)>640 and text_size>10: text_size -= 1
		label_at(pos+Vector2(0,43),status,text_size,MUTED)
	paragraph(Vector2(60,695),"These highlights use the deck you are editing, including unsaved changes. Owning a card is not enough: include it in this deck. Variants count for their monster family; named pack squads require the named monsters.",1300,19,INK)
	paragraph(Vector2(60,770),"A complete recipe is a possibility, not an active bonus. Draw and deploy its members together in separate lanes to activate it. Normal deck points and copy limits still apply.",1300,17,MUTED)
	button(Rect2(60,840,200,50),"< PREVIOUS",combo_page>0)
	button(Rect2(280,840,200,50),"MORE SQUADS >",(combo_page+1)*12<Squads.COMBOS.size())
	button(Rect2(1100,840,240,50),"BACK TO ARMORY")

func reinforcement_preview(lane: int, incoming: int) -> Dictionary:
	if not Squads.can_reinforce(friendly[lane],incoming): return {}
	var row: Array = friendly.duplicate(true)
	var before_attack := Squads.attack_value(row,lane)
	Squads.reinforce(row[lane],incoming)
	return {"unit":row[lane],"attack_before":before_attack,"attack_after":Squads.attack_value(row,lane),"hp_before":friendly[lane].hp,"level_before":Cards.DATA[friendly[lane].id].level}

func draw_reinforcement_preview(incoming: int) -> void:
	if Cards.DATA[incoming].hp<=0: return
	var lane := -1
	for i in 4:
		if lane_rect(0,i).has_point(drag_position) and not friendly[i].is_empty(): lane = i
	var box := Rect2(1150,138,262,322)
	panel(box,Color("101c1c"),Color("9df6b7"))
	if lane<0:
		label_at(Vector2(1166,170),"REINFORCEMENT",20,Color("9df6b7"))
		paragraph(Vector2(1166,203),"Green outlines show allies this card can strengthen. Hover over one to preview its stats.",228,16,INK)
		paragraph(Vector2(1166,305),"Use an EMPTY lane to keep both monsters and build a squad.",228,16,ORANGE)
		return
	var preview := reinforcement_preview(lane,incoming)
	if preview.is_empty():
		label_at(Vector2(1166,170),"CANNOT REINFORCE",18,Color("ff6068"))
		paragraph(Vector2(1166,205),"Already reinforced." if friendly[lane].get("reinforced",false) else "This monster cannot accept that card. Use an empty lane to deploy it separately.",228,17,INK)
		return
	var unit: Dictionary = preview.unit
	label_at(Vector2(1166,167),"AFTER REINFORCEMENT",17,Color("9df6b7"))
	paragraph(Vector2(1166,195),Cards.DATA[unit.id].name,228,16,INK)
	label_at(Vector2(1166,243),"ATK %d -> %d" % [preview.attack_before,preview.attack_after],21,ORANGE)
	label_at(Vector2(1166,271),"HP  %d -> %d" % [preview.hp_before,unit.hp],21,Color("9df6b7"))
	label_at(Vector2(1166,299),"LEVEL %d -> %d" % [preview.level_before,Cards.DATA[unit.id].level],17,INK)
	var price := "%d ENERGY" % Cards.DATA[incoming].cost
	if Cards.DATA[incoming].get("soul_cost",0)>0: price += " / %d SOULS" % Cards.DATA[incoming].soul_cost
	label_at(Vector2(1166,327),price,15,ORANGE)
	paragraph(Vector2(1166,351),"Incoming card is consumed. Keeps this monster's abilities and attack timing. No new squad member.",228,14,INK)
	label_at(Vector2(1166,438),"RELEASE TO REINFORCE" if can_afford(incoming) else "NOT ENOUGH RESOURCES",12,Color("9df6b7") if can_afford(incoming) else Color("ff6068"))


func guide_squad_rect(index: int) -> Rect2:
	return Rect2(76+(index%3)*435,158+int(index/3)*99,415,90)

func guide_card_rect(index: int) -> Rect2:
	return Rect2(76+(index%4)*220,225+int(index/4)*278,200,224)

func draw_deck_guide() -> void:
	if guide_step>0: button(battle_tools.CURVE_BUTTON,"ENERGY CURVE")
	label_at(Vector2(76,64),"BUILD YOUR HELL DECK",32,ORANGE)
	label_at(Vector2(76,105),["1 / PICK UP TO THREE SQUADS","2 / PICK YOUR CARDS","3 / REVIEW YOUR DECK","MAKE ROOM TO FINISH"][guide_step],24)
	button(Rect2(1160,40,196,48),"CANCEL")
	button(Rect2(940,40,196,48),"HOW THIS WORKS")
	if guide_step==0:
		label_at(Vector2(76,136),"Optional: choose a theme, then swap any suggested monster. Squad pieces may share a deck.",17,MUTED)
		for i in Squads.COMBOS.size():
			var rect := guide_squad_rect(i)
			var combo: Dictionary = Squads.COMBOS[i]
			panel(rect,Color("101a1e"),ORANGE if i in guide_squads else Color("394547"))
			label_at(rect.position+Vector2(12,26),("[+] " if i in guide_squads else "")+combo.name,20,ORANGE)
			var text_size := 15
			while text_width(combo.rule,text_size)>390 and text_size>10: text_size -= 1
			label_at(rect.position+Vector2(12,51),combo.rule,text_size)
			label_at(rect.position+Vector2(12,75),"+1 ATTACK" if combo.bonus=="attack" else "+1 DAMAGE AGAINST UNITS",14,MUTED)
		label_at(Vector2(76,807),"Start without squads if you prefer. Suggestions never lock your choices.",18,MUTED)
		button(Rect2(1040,850,316,55),"CHOOSE CARDS >")
	else:
		label_at(Vector2(990,148),"YOUR PICKS: %d / 20" % guide_cards.size(),23,ORANGE)
		label_at(Vector2(990,179),"%d / 120 POINTS  (%d LEFT)" % [DeckRules.cost(guide_cards),120-DeckRules.cost(guide_cards)],19)
		label_at(Vector2(990,207),"NAME (click to remove)       PTS / ENERGY",14,MUTED)
		for i in guide_cards.size():
			var data: Dictionary = Cards.DATA[guide_cards[i]]
			var text_size := 16
			while text_width(data.name,text_size)>245 and text_size>10: text_size -= 1
			label_at(Vector2(995,239+i*25),data.name,text_size,RARITY[data.rarity])
			label_at(Vector2(1248,239+i*25),"%d P / %d E" % [DeckRules.points(guide_cards[i]),data.cost],14,MUTED)
		paragraph(Vector2(990,752),DeckRules.completion_message(guide_cards,collection),365,16,ORANGE)
		var mythic_count := guide_cards.filter(func(id): return Cards.DATA[id].rarity==5).size()
		var premium_count := guide_cards.filter(func(id): return Cards.DATA[id].rarity>=2).size()
		label_at(Vector2(990,818),"MYTHIC %d/2 / PREMIUM %d/6" % [mythic_count,premium_count],15,MUTED)
		if guide_step==1:
			label_at(Vector2(76,211),"Deck points: building budget. Energy: battle cost. Click a card to add it.",16,MUTED)
			for i in 7:
				var rarity: int = i-1
				button(Rect2(76+i*125,144,116,42),"ALL" if i==0 else RARITY_NAMES[rarity],true)
				if guide_rarity==rarity: draw_rect(Rect2(76+i*125,185,116,3),ORANGE)
			var options := DeckGuide.suggestions(guide_cards,guide_squads,collection,guide_rarity)
			var hovered_ability := ""
			var pages := maxi(1,ceili(options.size()/8.0))
			guide_page = mini(guide_page,pages-1)
			for slot in range(guide_page*8,mini(options.size(),guide_page*8+8)):
				var id: int = options[slot]
				var rect := guide_card_rect(slot%8)
				card(rect,id)
				if rect.has_point(get_global_mouse_position()): hovered_ability = Cards.DATA[id].name+": "+Cards.DATA[id].ability
				label_at(rect.position+Vector2(0,244),"%d DECK PTS / %d ENERGY" % [DeckRules.points(id),Cards.DATA[id].cost],15,ORANGE)
			var ability_line := ""
			var ability_y := 766
			for word in hovered_ability.split(" "):
				if text_width(ability_line+word,14)>850:
					label_at(Vector2(76,ability_y),ability_line,14)
					ability_line = ""
					ability_y += 17
					if ability_y>783: break
				ability_line += word+" "
			if ability_y<=783: label_at(Vector2(76,ability_y),ability_line,14)
			if options.is_empty(): label_at(Vector2(76,275),"No cards fit this filter and budget. Remove a pick or choose ALL.",20,MUTED)
			button(Rect2(76,793,130,42),"< PREV",guide_page>0)
			button(Rect2(220,793,130,42),"NEXT >",guide_page+1<pages)
			label_at(Vector2(374,820),"%d / %d" % [guide_page+1,pages],16,MUTED)
			button(Rect2(526,793,400,42),"FILL WITH SUGGESTIONS",guide_cards.size()<20)
		elif guide_step==3:
			label_at(Vector2(76,177),"KEEP YOUR IDEA. FREE SOME POINTS.",24,ORANGE)
			paragraph(Vector2(76,220),DeckRules.completion_message(guide_cards,collection)+" Removing a card also creates a slot to fill. These cuts leave enough budget for a legal 20-card deck.",830,18,INK)
			for i in mini(guide_repair.get("cuts",[]).size(),7):
				var id: int = guide_repair.cuts[i]
				label_at(Vector2(90,325+i*40),"REMOVE "+Cards.DATA[id].name+" / FREE %d POINTS" % DeckRules.points(id),19,RARITY[Cards.DATA[id].rarity])
			paragraph(Vector2(76,635),"Expensive picks are suggested first, with a preference for keeping completed squads and cheap early units. You can instead remove any card from the list yourself.",820,17,MUTED)
			button(Rect2(480,850,440,55),"APPLY CUTS / KEEP BUILDING" if not guide_repair.get("cuts",[]).is_empty() else "NO CUTS NEEDED / KEEP BUILDING",guide_repair.get("possible",false))
			if not guide_repair.get("possible",false): label_at(Vector2(76,730),"Not enough eligible owned cards to finish. Keep this as a draft.",18,ORANGE)
		else:
			label_at(Vector2(76,177),"A STARTING POINT. MAKE IT YOURS.",25,ORANGE)
			label_at(Vector2(76,219),"Your picks stay editable in the Armory. Saving does not switch your battle deck.",18)
			var cheap := guide_cards.filter(func(id): return Cards.DATA[id].hp>0 and Cards.DATA[id].cost<=2).size()
			var premium := guide_cards.filter(func(id): return Cards.DATA[id].rarity>=2).size()
			label_at(Vector2(76,275),"EARLY UNITS (1-2 ENERGY): %d   /   PREMIUM CARDS: %d / 6" % [cheap,premium],20)
			if cheap<6: label_at(Vector2(76,310),"Suggestion: add more cheap blockers so expensive cards have time to arrive.",17,ORANGE)
			for i in guide_squads.size():
				var index: int = guide_squads[i]
				var ready := DeckGuide.complete(guide_cards,index)
				label_at(Vector2(76,375+i*55),Squads.COMBOS[index].name+" / "+("ALL PIECES" if ready else "MISSING PIECES"),22,Color("9df6b7") if ready else ORANGE)
			label_at(Vector2(76,580),"Squad bonuses activate when their monsters are deployed in distinct lanes.",18,MUTED)
			var issue := DeckRules.issue(guide_cards,collection)
			label_at(Vector2(76,635),"READY TO PLAY" if issue.is_empty() else "UNFINISHED: "+issue,20,ORANGE)
			button(Rect2(1040,850,316,55),"SAVE / NAME DECK" if DeckRules.issue(guide_cards,collection).is_empty() else "SAVE UNFINISHED DRAFT")
		button(Rect2(76,850,250,55),"< SQUADS" if guide_step==1 else "< CHOOSE CARDS")
		if guide_step==1: button(Rect2(1040,850,316,55),"REVIEW >")
		if guide_step in [1,2]: button(Rect2(360,850,350,55),"HELP FINISH / SUGGEST CUTS")
	label_at(Vector2(76,938),guide_message,16,ORANGE)
	if guide_tutorial: draw_guide_tutorial()

func deck_guide_click(pos: Vector2) -> void:
	if guide_tutorial:
		if Rect2(570,590,300,55).has_point(pos): guide_tutorial = false
		return
	if Rect2(940,40,196,48).has_point(pos):
		guide_tutorial = true
		return
	if guide_step in [1,2] and Rect2(360,850,350,55).has_point(pos):
		guide_repair = DeckGuide.repair(guide_cards,guide_squads,collection)
		guide_step = 3
		return
	if guide_step==3 and Rect2(480,850,440,55).has_point(pos):
		if guide_repair.get("possible",false):
			guide_cards = guide_repair.kept.duplicate()
			guide_step = 1
			guide_message = "Cuts applied to your draft. Add your own cards or use FILL WITH SUGGESTIONS."
		return
	var prior_step := guide_step
	deck_guide_action(pos)
	if guide_step!=prior_step and guide_step in [0,1,2]: guide_tutorial = true

func draw_guide_tutorial() -> void:
	draw_rect(Rect2(0,0,1440,940),Color(0,0,0,0.8))
	panel(Rect2(330,260,780,425),Color("101a1e"),ORANGE)
	label_at(Vector2(365,310),"DECK BUILDING / "+["SQUADS","POINTS AND ENERGY","READY FOR BATTLE","MAKING ROOM"][guide_step],25,ORANGE)
	var lessons := [
		"Start with a plan. A squad is a group of matching monsters that grants a bonus when deployed together in different lanes. Pick up to three, or skip this step. Choosing a squad suggests its pieces; it does not force you to keep them.",
		"Build exactly 20 cards within 120 deck points. Points are your building budget; Energy is what you pay each turn in battle. Start with cheap monsters, add squad pieces, then a few costly threats or weapons. Rarer cards use more points, so filling every slot with rares will not fit. If you run short, HELP FINISH suggests cuts. Nothing is removed until you apply them.",
		"Check your early monsters and completed squads. Common cards allow 3 copies, Rares 2, other rarities 1. You may include up to 6 premium cards, including 2 Mythics. Save unfinished work as a draft. A complete deck becomes playable when you select USE DECK in My Decks.",
		"Removing an expensive card frees points but also adds an empty slot. The suggestions account for both. Apply cuts, then fill the open slots yourself or use suggestions. Your saved deck stays unchanged until you save."
	]
	paragraph(Vector2(365,365),lessons[guide_step],710,21,INK)
	button(Rect2(570,590,300,55),"GOT IT / CONTINUE")

func deck_guide_action(pos: Vector2) -> void:
	if Rect2(1160,40,196,48).has_point(pos):
		modal = "decks"
		return
	if guide_step==0:
		for i in Squads.COMBOS.size():
			if guide_squad_rect(i).has_point(pos):
				if i in guide_squads: guide_squads.erase(i)
				elif guide_squads.size()<3: guide_squads.append(i)
				else: guide_message = "Choose up to three squads. Click a selected squad to remove it."
		if Rect2(1040,850,316,55).has_point(pos):
			# Preserve manual picks on return; only seed an empty deck.
			if guide_cards.is_empty(): guide_cards = DeckGuide.seed_squads(guide_squads,collection)
			guide_step = 1
			guide_page = 0
			guide_message = "Click a suggested card to add it. Every pick respects ownership, copies and budget."
		return
	for i in guide_cards.size():
		if Rect2(985,219+i*25,371,25).has_point(pos):
			guide_cards.remove_at(i)
			if guide_step==3: guide_repair = DeckGuide.repair(guide_cards,guide_squads,collection)
			return
	if Rect2(76,850,250,55).has_point(pos):
		guide_step = 1 if guide_step==3 else guide_step-1
		return
	if guide_step==1:
		for i in 7:
			if Rect2(76+i*125,144,116,42).has_point(pos):
				guide_rarity = i-1
				guide_page = 0
				return
		var options := DeckGuide.suggestions(guide_cards,guide_squads,collection,guide_rarity)
		if Rect2(76,793,130,42).has_point(pos): guide_page = maxi(0,guide_page-1)
		elif Rect2(220,793,130,42).has_point(pos): guide_page = mini(maxi(0,ceili(options.size()/8.0)-1),guide_page+1)
		elif Rect2(526,793,400,42).has_point(pos):
			guide_cards = DeckGuide.fill(guide_cards,guide_squads,collection)
			guide_message = DeckRules.completion_message(guide_cards,collection)
		elif Rect2(1040,850,316,55).has_point(pos): guide_step = 2
		else:
			for slot in range(guide_page*8,mini(options.size(),guide_page*8+8)):
				if guide_card_rect(slot%8).has_point(pos):
					guide_cards.append(options[slot])
					return
	elif guide_step==2 and Rect2(1040,850,316,55).has_point(pos):
		if guide_editing<0 and deck_book.entries.size()>=DeckBook.LIMIT:
			guide_message = "Deck library is full. Delete an unused deck before saving."
			return
		editing_deck = guide_editing if guide_editing>=0 else deck_book.create("Guided Deck",guide_cards)
		deck_book.entries[editing_deck].cards = guide_cards.duplicate()
		decklist = guide_cards.duplicate()
		save_progress()
		open_deck_name(editing_deck)


func open_commanders() -> void:
	cancel_drag()
	selected = -1
	commander_draft = chosen_commander
	modal = "commanders"

func commander_choice_rect(index: int) -> Rect2:
	var spacing := 1300.0/Commanders.ROSTER.size()
	return Rect2(70+index*spacing,240,spacing-16,280)

func draw_commander_portrait(rect: Rect2, id: String, tint: Color) -> void:
	draw_rect(rect.grow(5),Color("101714"))
	draw_texture_rect(Commanders.entry(id).portrait,rect,false)
	draw_rect(rect.grow(3),tint,false,2)

func draw_commanders() -> void:
	label_at(Vector2(80,115),"CHOOSE YOUR COMMANDER",38,ORANGE)
	label_at(Vector2(80,158),"Seven faces of Hell. Every match pits you against a random OTHER commander.",20,INK)
	label_at(Vector2(80,191),"Each commander has a unique hero power. 5 Souls, once per round. Click or drag your portrait to use it.",17,MUTED)
	for i in Commanders.ROSTER.size():
		var choice: Dictionary = Commanders.ROSTER[i]
		var rect := commander_choice_rect(i)
		var picked: bool = commander_draft == choice.id
		var tint := ORANGE if picked else MUTED
		panel(rect,Color("101714"),tint)
		draw_commander_portrait(Rect2(rect.position+Vector2(12,12),Vector2.ONE*(rect.size.x-24)),choice.id,tint)
		var name_size := 18
		while text_width(choice.name,name_size)>rect.size.x-20: name_size -= 1
		label_at(rect.position+Vector2(12,225),choice.name,name_size,tint)
		label_at(rect.position+Vector2(12,250),choice.kind,16,MUTED)
		label_at(rect.position+Vector2(0,305),hero_power.POWERS[choice.id].name,15,Color("c36aff"))
		if picked:
			label_at(rect.position+Vector2(68,-18),"SELECTED",20,ORANGE)
	label_at(Vector2(80,595),hero_power.POWERS[commander_draft].description,19,INK)
	button(Rect2(520,650,400,60),"ENTER THE ARENA" if initial_commander_choice else "SAVE FOR NEXT MATCH")
	button(Rect2(600,735,240,45),"CANCEL")
	if not initial_commander_choice:
		label_at(Vector2(80,840),"The current match keeps its characters. Your selection applies when the next match starts.",18,MUTED)

func apply_options() -> void:
	AudioServer.set_bus_volume_db(0,linear_to_db(maxf(master_volume,0.001)))
	AudioServer.set_bus_mute(0,master_volume<=0)
	if DisplayServer.get_name()!="headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func menu_frame(rect: Rect2) -> void:
	panel(rect,Color("0b1718"),Color("5e694f"))
	var glow := 0.5+sin(clock*2)*0.15
	draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color(1,0.52,0.18,glow),3)
	for i in 5:
		var x := fposmod(clock*45+i*241,rect.size.x)
		draw_rect(Rect2(rect.position+Vector2(x,4),Vector2(24,2)),Color(1,0.74,0.3,0.35))
