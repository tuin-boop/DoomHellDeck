extends Node2D
## Cosmetic feedback never consumes combat randomness.
var game
var hit_age := [99.0,99.0]
var blood: Array = []
var ready_elapsed := 0.0
var reminder_age := 99.0
var was_ready := false
var border_phase := 0.0

func reset() -> void:
	hit_age = [99.0,99.0]
	blood.clear()
	ready_elapsed = 0
	reminder_age = 99
	was_ready = false
	border_phase = 0

func offset(side: int) -> Vector2:
	var age: float = hit_age[side]
	return Vector2(sin(age*95)*10,cos(age*73)*6)*pow(1-age/0.6,2) if age<0.6 else Vector2.ZERO

func ready_tilt() -> float:
	return sin(reminder_age*24)*0.09*sin(reminder_age/1.2*PI) if reminder_age<1.2 else 0.0

func portrait_center(side: int) -> Vector2:
	if game.hero_power.active and game.hero_power.side==side: return game.hero_power.portrait_position
	if side==1 and game.battle_voice.visible and game.battle_voice.speech_age<5.5:
		return game.battle_voice.speaking_portrait_rect(game.battle_voice.speech_age).get_center()
	return Vector2(128,185) if side==0 else Vector2(488,60)

func hurt(side: int, amount: int) -> void:
	if amount<=0: return
	hit_age[side] = 0
	var center := portrait_center(side)
	for i in mini(32,12+amount*3):
		var angle := i*2.39996+side
		blood.append({"pos":center+Vector2(cos(angle)*22,sin(angle)*16),"vel":Vector2(cos(angle)*100,sin(angle)*90-65),"life":0.65+(i%4)*0.1,"size":3+i%4})

func _process(delta: float) -> void:
	if ready_border_visible(): border_phase = fposmod(border_phase+delta/2.8,1.0)
	for side in 2: hit_age[side] += delta
	for drop in blood:
		drop.pos += drop.vel*delta
		drop.vel.y += 230*delta
		drop.life -= delta
	blood = blood.filter(func(drop): return drop.life>0)
	var eligible: bool = game.souls>=5 and not game.hero_power.used[0] and not game.ended
	var idle: bool = not game.busy and game.modal=="" and not game.hero_power.armed
	if not eligible:
		was_ready = false
		ready_elapsed = 0
		reminder_age = 99
	elif idle:
		reminder_age += delta
		ready_elapsed += delta
		if not was_ready or ready_elapsed>=20:
			was_ready = true
			ready_elapsed = 0
			reminder_age = 0
	else: reminder_age = 99
	queue_redraw()

func _draw() -> void:
	if game.modal not in ["","reward","defeat","draw"]: return
	for drop in blood:
		draw_rect(Rect2(drop.pos,Vector2.ONE*drop.size),Color(0.75,0.025,0.04,minf(1,drop.life*3)))
	if ready_border_visible(): draw_ready_border()
	if reminder_age<1.2 and game.modal=="" and not game.busy:
		var strength := sin(reminder_age/1.2*PI)
		draw_arc(Vector2(128,185),78+reminder_age*12,0,TAU,48,Color(0.76,0.35,1,strength*0.8),3,true)
		draw_string_outline(game.font,Vector2(66,298),"POWER READY",HORIZONTAL_ALIGNMENT_LEFT,-1,14,3,Color(0,0,0,strength))
		draw_string(game.font,Vector2(66,298),"POWER READY",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color(0.9,0.65,1,strength))

func ready_border_visible() -> bool:
	return game.hero_power.available() and not game.hero_power.active

func border_point(distance: float) -> Vector2:
	var d := fposmod(distance,512.0)
	if d<128: return Vector2(-64+d,-64)
	if d<256: return Vector2(64,-64+d-128)
	if d<384: return Vector2(64-(d-256),64)
	return Vector2(-64,64-(d-384))

func draw_ready_border() -> void:
	# Follow the portrait's existing shake, keeping the light on its square frame.
	draw_set_transform(Vector2(128,185)+offset(0),ready_tilt())
	draw_rect(Rect2(-64,-64,128,128),Color(1,0.76,0.12,0.45),false,2)
	var head := border_phase*512
	for step in 48:
		var fade := pow(1.0-float(step)/48,1.5)
		var point := border_point(head-step*2.5)
		draw_circle(point,6,Color(1,0.65,0.02,fade*0.055))
		draw_circle(point,3.5,Color(1,0.86,0.08,fade*0.17))
		draw_rect(Rect2(point-Vector2.ONE*1.4,Vector2.ONE*2.8),Color(1,0.93,0.32,fade))
	draw_circle(border_point(head),2.2,Color("fff4b0"))
	draw_set_transform(Vector2.ZERO)
