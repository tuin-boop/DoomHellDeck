extends Node2D
const Commanders = preload("res://scripts/commanders.gd")
const COST := 5
const POWERS := {
	"tuin":{"name":"SECOND WIND","description":"Give one friendly monster on the board +2 HP. Can exceed its starting HP.","buff_hp":2,"damage":0,"hero":0,"kind":"ENERGY","art":"","sound":"DSGETPOW"},
	"synapse":{"name":"PLASMA VOLLEY","description":"1 damage to your chosen enemy monster and up to two nearest others, or 3 damage to the enemy hero.","damage":1,"hero":3,"kind":"ENERGY","art":"APLS","sound":"DSPLASMA","volley":true},
	"ashfang":{"name":"HELLFIRE HEX","description":"3 damage. A surviving unit loses 1 ATK next attack phase.","damage":3,"hero":3,"kind":"FIRE","art":"BAL1","sound":"DSFIRSHT","chill":true},
	"oculus":{"name":"SWOOP AND BITE","description":"3 damage to a unit or hero. Restore 1 Health.","damage":3,"hero":3,"kind":"MELEE","art":"","sound":"DSSGTATK","heal":1},
	"iron_tyrant":{"name":"SIEGE BARRAGE","description":"2 damage to a unit and its neighbours, or 3 to a hero.","damage":2,"hero":3,"kind":"ROCKET","art":"MISL","sound":"DSRLAUNC","splash":2},
	"goremaw":{"name":"BONE CRUSHER","description":"4 damage to a unit, or 2 to a hero.","damage":4,"hero":2,"kind":"MELEE","art":"","sound":"DSSGTATK"},
	"graves":{"name":"ROCKET STRIKE","description":"3 damage to a unit or hero. Adjacent units take 1.","damage":3,"hero":3,"kind":"ROCKET","art":"MISL","sound":"DSRLAUNC","splash":1},
}
var game
var armed := false
var pointer := Vector2.ZERO
var pressed_at := Vector2.ZERO
var dragged := false
var used := [false,false]
var cpu_souls := 0
var active := false
var side := 0
var hero := "graves"
var portrait_position := Vector2.ZERO
var portrait_scale := 1.0
var shot := Vector2.ZERO
var shooting := false
var shot_key := ""
var shot_direction := Vector2.RIGHT
var impact := Vector2.ZERO
var impact_size := 0.0
var focus := 0.0
var attack_phase := ""

func label_at(pos: Vector2, text: String, size := 16, color := Color("e5e0cf")) -> void:
	draw_string_outline(game.font,pos,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,3,Color("090b0c"))
	draw_string(game.font,pos,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func reset() -> void:
	armed = false
	active = false
	focus = 0
	attack_phase = ""
	used = [false,false]
	cpu_souls = 0

func available(owner := 0) -> bool:
	return not game.busy and not game.ended and game.modal=="" and not used[owner] and (game.souls if owner==0 else cpu_souls)>=COST

func target_at(pos: Vector2, owner := 0) -> int:
	var support: bool = POWERS[game.player_commander if owner==0 else game.enemy_commander].has("buff_hp")
	var target_side: int = owner if support else 1-owner
	var row: Array = game.friendly if target_side==0 else game.enemy
	for lane in 4:
		if not row[lane].is_empty() and game.lane_rect(target_side,lane).has_point(pos): return lane
	if support: return -1
	if (Rect2(435,8,480,100) if owner==0 else Rect2(55,290,150,125)).has_point(pos): return 4
	return -1

func handle(event: InputEvent) -> bool:
	if event is InputEventMouse: pointer = event.position
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE and armed:
		armed = false
		return true
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_RIGHT and armed:
		armed = false
		return true
	if event is InputEventMouseMotion and armed:
		pointer = event.position
		if pointer.distance_to(pressed_at)>10: dragged = true
		return true
	if not event is InputEventMouseButton or event.button_index!=MOUSE_BUTTON_LEFT: return false
	if game.busy or game.ended or game.modal!="": return false
	if armed:
		pointer = event.position
		if event.pressed or dragged:
			var target := target_at(pointer)
			if target>=0: activate(0,target)
			elif dragged or event.pressed: armed = false
		return true
	if event.pressed and Rect2(62,120,132,148).has_point(event.position):
		if available():
			game.cancel_drag()
			game.selected = -1
			armed = true
			dragged = false
			pressed_at = event.position
			pointer = event.position
		else: game.log_line("Hero power: 5 Souls, once per round." if not used[0] else "Hero power used. Ready next round.")
		return true
	return false

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if game==null or game.modal!="": return
	if active: draw_rect(Rect2(0,0,1440,940),Color(0.015,0.008,0.025,focus*0.24))
	var power: Dictionary = POWERS[game.player_commander]
	label_at(Vector2(35,111),"%s / 5 SOULS" % power.name,12,Color("c36aff") if available() else Color("899493"))
	if not armed and Rect2(62,120,132,148).has_point(get_global_mouse_position()):
		label_at(Vector2(300,670),power.description+("" if power.has("buff_hp") else "  (Shields / armour apply.)"),15,Color("f1caff"))
		label_at(Vector2(300,690),"USED THIS ROUND" if used[0] else "5 SOULS / CLICK OR DRAG PORTRAIT / ONCE PER ROUND",13)
	if armed and power.has("buff_hp"):
		var target := target_at(pointer)
		for lane in 4:
			if not game.friendly[lane].is_empty(): draw_rect(game.lane_rect(0,lane).grow(4),Color("9df6b7"),false,3)
		draw_aim_arrow(Vector2(128,185),pointer,target>=0)
		label_at(Vector2(300,670),"SECOND WIND / CHOOSE A FRIENDLY MONSTER / +2 HP",15,Color("9df6b7"))
		label_at(Vector2(300,690),"RIGHT CLICK OR ESC TO CANCEL",13)
		if target>=0: label_at(game.lane_rect(0,target).position+Vector2(0,-9),"HP %d -> %d" % [game.friendly[target].hp,game.friendly[target].hp+2],18,Color("9df6b7"))
	if armed and not power.has("buff_hp"):
		var target := target_at(pointer)
		for lane in 4:
			if not game.enemy[lane].is_empty():
				draw_rect(game.lane_rect(1,lane).grow(4),Color("c36aff"),false,3)
		draw_rect(Rect2(435,8,480,100),Color("c36aff"),false,2)
		draw_aim_arrow(Vector2(128,185),pointer,target>=0)
		label_at(Vector2(300,670),"%s  /  %s" % [power.name,power.description],15,Color("f1caff"))
		label_at(Vector2(300,690),"DROP / CLICK A TARGET   -   RIGHT CLICK OR ESC TO CANCEL",13)
		if target>=0:
			var where: Vector2 = Vector2(650,108) if target==4 else game.lane_rect(1,target).position+Vector2(0,-9)
			var predicted: int = power.hero
			if target<4:
				var preview: Dictionary = game.enemy[target].duplicate(true)
				predicted = 0 if preview.shield else game.Cards.receive_damage(preview,power.damage)
			if target<4 and power.get("volley",false):
				for extra in volley_lanes(game.enemy,target).slice(1):
					draw_rect(game.lane_rect(1,extra).grow(7),Color("ffb063"),false,4)
					label_at(game.lane_rect(1,extra).position+Vector2(0,-9),"%d DAMAGE" % (0 if game.enemy[extra].shield else 1),16,Color("f1caff"))
			label_at(where,"%d DAMAGE%s" % [predicted," + SPLASH" if target<4 and power.has("splash") else ""],16,Color("f1caff"))
	if not game.busy and game.targeting_weapon():
		var mouse: Vector2 = pointer
		var target: int = game.weapon_target_at(mouse)
		for owner in 2:
			var row: Array = game.friendly if owner==0 else game.enemy
			for lane in 4:
				if not row[lane].is_empty(): draw_rect(game.lane_rect(owner,lane).grow(4),Color("ffab55"),false,2)
		draw_aim_arrow(game.hand_rect(game.selected).get_center(),mouse,target>=0)
		label_at(Vector2(300,670),game.Cards.DATA[game.hand[game.selected]].name+" / CHOOSE ANY MONSTER / RIGHT CLICK OR ESC TO CANCEL",15,Color("ffcc88"))
		if target>=0:
			var row: Array = game.friendly if target<4 else game.enemy
			var result: Dictionary = game.Weapons.preview(game.hand[game.selected],row,target%4)
			for lane in 4:
				if lane==target%4 or result.loss[lane]>0:
					label_at(game.lane_rect(int(target/4),lane).position+Vector2(0,-9),"%d DAMAGE / NO COUNTER" % result.loss[lane],14,Color("ffcc88"))
	if active:
		var extent := 120*portrait_scale
		draw_texture_rect(Commanders.entry(hero).portrait,Rect2(portrait_position+game.hero_feedback.offset(side)-Vector2.ONE*extent/2,Vector2.ONE*extent),false)
		if shooting:
			var frames: Array = (game.art.side_effect_textures if shot_key=="MISL" else game.art.effect_textures).get(shot_key,[])
			if not frames.is_empty():
				var texture: Texture2D = frames[0 if shot_key=="MISL" else int(game.clock*12)%mini(2,frames.size())]
				var shot_size := texture.get_size()*minf(56.0/texture.get_width(),56.0/texture.get_height())
				draw_set_transform(shot,shot_direction.angle()+PI if shot_key=="MISL" else 0)
				draw_texture_rect(texture,Rect2(-shot_size/2,shot_size),false)
				draw_set_transform(Vector2.ZERO)
			else: draw_circle(shot,14,Color("9df6b7") if hero=="tuin" else Color("ff8e42"))
		if impact_size>0:
			draw_arc(impact,impact_size,0,TAU,24,Color(1,0.55,0.2,1-impact_size/90),5,true)
		if attack_phase=="windup":
			draw_arc(portrait_position,88+sin(game.clock*8)*5,game.clock*3,game.clock*3+PI*1.6,40,Color(0.85,0.5,1,focus*0.85),4,true)

func activate(owner: int, target: int) -> void:
	if not available(owner) or target<0 or target>4: return
	if POWERS[game.player_commander if owner==0 else game.enemy_commander].has("buff_hp"):
		await grant_health(owner,target)
		return
	var row: Array = game.enemy if owner==0 else game.friendly
	if target<4 and row[target].is_empty(): return
	armed = false
	used[owner] = true
	if owner==0: game.souls -= COST
	else: cpu_souls -= COST
	game.busy = true
	active = true
	attack_phase = "windup"
	focus = 0
	side = owner
	hero = game.player_commander if owner==0 else game.enemy_commander
	var power: Dictionary = POWERS[hero]
	var home := Vector2(128,185) if owner==0 else Vector2(488,60)
	var destination: Vector2 = (Vector2(720,65) if owner==0 else Vector2(128,354)) if target==4 else game.lane_rect(1-owner,target).get_center()
	portrait_position = home
	portrait_scale = 1
	game.battle_voice.speech_age = 99
	game.battle_voice.announce(power.name)
	var windup := create_tween().set_parallel(true)
	windup.tween_property(self,"portrait_position",home+Vector2(50,25),0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	windup.tween_property(self,"portrait_scale",1.5,0.7)
	windup.tween_property(self,"focus",1.0,0.35)
	await windup.finished
	await get_tree().create_timer(0.25).timeout
	attack_phase = "strike"
	game.audio.play(power.sound)
	if power.kind=="MELEE":
		var swoop := create_tween()
		swoop.tween_property(self,"portrait_position",destination,0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		await swoop.finished
	else:
		shot = portrait_position
		shot_key = power.art
		shot_direction = (destination-shot).normalized()
		shooting = true
		var flight := create_tween()
		flight.tween_property(self,"shot",destination,0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		flight.parallel().tween_property(self,"portrait_position",home-Vector2(14,0),0.15)
		await flight.finished
		shooting = false
	impact = destination
	attack_phase = "impact"
	impact_size = 5
	game.audio.impact(power.kind)
	if power.get("volley",false):
		game.sprite_effects.append({"key":"APBX","first":0,"count":5,"pos":destination,"age":0.0,"duration":0.45,"size":95.0})
	if power.kind=="ROCKET":
		game.sprite_effects.append({"key":"MISL","first":1,"count":3,"pos":destination,"age":0.0,"duration":0.45,"size":110.0})
	if target==4:
		game.damage_hero(1-owner,int(power.hero),power.name)
		game.numbers.append({"pos":destination,"text":"-%d HEALTH" % power.hero,"life":1.0,"color":Color("ff8e42")})
	else:
		var original: Dictionary = row[target]
		var blocked: bool = original.shield
		game.hit(1-owner,target,power.damage,power.kind,false,-1,power.name)
		if power.get("chill",false) and not blocked and is_same(row[target],original): row[target].chilled = true
		if power.get("volley",false):
			for extra in volley_lanes(row,target).slice(1):
				shot = portrait_position
				shot_key = power.art
				var extra_pos: Vector2 = game.lane_rect(1-owner,extra).get_center()
				shot_direction = (extra_pos-shot).normalized()
				shooting = true
				game.audio.play(power.sound)
				var bolt := create_tween()
				bolt.tween_property(self,"shot",extra_pos,0.32)
				await bolt.finished
				shooting = false
				game.sprite_effects.append({"key":"APBX","first":0,"count":5,"pos":extra_pos,"age":0.0,"duration":0.45,"size":80.0})
				game.hit(1-owner,extra,1,"ENERGY",false,-1,power.name)
		for adjacent in [target-1,target+1]:
			if power.has("splash") and adjacent>=0 and adjacent<4 and not row[adjacent].is_empty():
				game.hit(1-owner,adjacent,power.splash,power.kind,false,-1,power.name)
	if power.has("heal"):
		if owner==0: game.player_hp = mini(30,game.player_hp+int(power.heal))
		else: game.enemy_hp = mini(30+mini(game.wins,5)*2,game.enemy_hp+int(power.heal))
	game.log_line(Commanders.entry(hero).name+" uses "+power.name+".")
	var shock := create_tween()
	shock.tween_property(self,"impact_size",65.0,0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await shock.finished
	attack_phase = "recovery"
	var recover := create_tween().set_parallel(true)
	recover.tween_property(self,"impact_size",90.0,0.5)
	recover.tween_property(self,"portrait_position",home,0.85).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	recover.tween_property(self,"portrait_scale",1.0,0.85)
	recover.tween_property(self,"focus",0.0,0.85)
	await recover.finished
	active = false
	attack_phase = ""
	impact_size = 0
	game.busy = false
	game.check_end()

func cpu_turn() -> void:
	if cpu_souls<COST or used[1] or game.ended: return
	var power: Dictionary = POWERS[game.enemy_commander]
	if power.has("buff_hp"):
		var best := -1
		var best_value := -1.0
		for lane in 4:
			if game.enemy[lane].is_empty(): continue
			var unit: Dictionary = game.enemy[lane]
			var data: Dictionary = game.Cards.DATA[unit.id]
			var value: float = data.atk*data.get("strikes",1)+(3 if unit.hp<=2 else 0)
			if value>best_value:
				best_value = value
				best = lane
		if best>=0:
			game.busy = false
			await activate(1,best)
			game.busy = true
		return
	var target := 4
	var score := float(power.hero)
	if game.player_hp>power.hero:
		for lane in 4:
			var unit: Dictionary = game.friendly[lane]
			if unit.is_empty(): continue
			var value := minf(unit.hp,power.damage)+(3 if unit.hp<=power.damage and not unit.shield else 0)
			if power.get("volley",false):
				for extra in volley_lanes(game.friendly,lane).slice(1):
					if not game.friendly[extra].shield: value += 1+(3 if game.friendly[extra].hp<=1 else 0)
			for adjacent in [lane-1,lane+1]:
				if adjacent>=0 and adjacent<4 and not game.friendly[adjacent].is_empty(): value += power.get("splash",0)
			if value>score:
				score = value
				target = lane
	game.busy = false
	await activate(1,target)
	game.busy = true

# Shared moving segmented arrow for hero powers and targeted weapons.
func draw_aim_arrow(origin: Vector2, tip: Vector2, valid: bool) -> void:
	var delta := tip-origin
	if delta.length()<24: return
	var control := (origin+tip)*0.5+Vector2(-minf(75,delta.length()*0.12),-65)
	var tint := Color("ff4428") if valid else Color("bc4635")
	var points := PackedVector2Array()
	for i in 33:
		var t := float(i)/32
		points.append(origin*(1-t)*(1-t)+control*2*(1-t)*t+tip*t*t)
	draw_polyline(points,Color(0.3,0.01,0,0.25),18,true)
	var count := maxi(2,int(delta.length()/32))
	for i in count:
		var t := (i+fposmod(game.clock*1.6,1.0))/count
		if t>0.94: continue
		var pos := origin*(1-t)*(1-t)+control*2*(1-t)*t+tip*t*t
		var tangent := ((control-origin)*(1-t)+(tip-control)*t).normalized()
		draw_set_transform(pos,tangent.angle())
		draw_rect(Rect2(-10,-7,20,14),Color("3c100b"))
		draw_rect(Rect2(-8,-5,16,10),tint)
		draw_line(Vector2(-7,-5),Vector2(7,-5),Color("ffb063"),2,true)
	draw_set_transform(Vector2.ZERO)
	var forward := (tip-control).normalized()
	var normal := forward.orthogonal()
	draw_colored_polygon(PackedVector2Array([tip,tip-forward*27+normal*15,tip-forward*21,tip-forward*27-normal*15]),tint)
	if valid:
		draw_arc(tip,23+sin(game.clock*6)*2,game.clock,game.clock+TAU*0.85,32,Color("ffbe64"),3,true)

func volley_lanes(row: Array, chosen: int) -> Array:
	var other: Array = []
	for lane in 4:
		if lane!=chosen and not row[lane].is_empty(): other.append(lane)
	other.sort_custom(func(a,b): return absi(a-chosen)<absi(b-chosen) or (absi(a-chosen)==absi(b-chosen) and a<b))
	return [chosen]+other.slice(0,2)

func grant_health(owner: int, target: int) -> void:
	var row: Array = game.friendly if owner==0 else game.enemy
	if target>=4 or row[target].is_empty(): return
	armed = false
	used[owner] = true
	if owner==0: game.souls -= COST
	else: cpu_souls -= COST
	game.busy = true
	active = true
	side = owner
	hero = "tuin"
	attack_phase = "windup"
	var home := Vector2(128,185) if owner==0 else Vector2(488,60)
	var destination: Vector2 = game.lane_rect(owner,target).get_center()
	portrait_position = home
	portrait_scale = 1
	focus = 0
	game.battle_voice.speech_age = 99
	game.battle_voice.announce("SECOND WIND")
	var windup := create_tween().set_parallel(true)
	windup.tween_property(self,"portrait_scale",1.35,0.55)
	windup.tween_property(self,"focus",1.0,0.4)
	await windup.finished
	attack_phase = "support"
	game.audio.play("DSGETPOW")
	shooting = true
	shot_key = ""
	shot = home
	var flight := create_tween()
	flight.tween_property(self,"shot",destination,0.65).set_trans(Tween.TRANS_SINE)
	await flight.finished
	shooting = false
	row[target].hp += 2
	game.burst(destination,Color("9df6b7"),32)
	game.numbers.append({"pos":destination,"text":"+2 HP","life":1.2,"color":Color("9df6b7")})
	game.battle_tools.record(game.turn,"TUIN / SECOND WIND","%s lane %d: %s gains +2 HP (now %d)." % ["YOUR" if owner==0 else "CPU",target+1,game.Cards.DATA[row[target].id].name,row[target].hp])
	var recovery := create_tween().set_parallel(true)
	recovery.tween_property(self,"portrait_scale",1.0,0.6)
	recovery.tween_property(self,"focus",0.0,0.6)
	await recovery.finished
	active = false
	attack_phase = ""
	game.busy = false
