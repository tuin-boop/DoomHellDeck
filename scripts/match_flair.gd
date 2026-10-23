extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
const Voices = preload("res://scripts/battle_voice.gd")
var intro_age := 0.0
var biggest := 0
var biggest_name := "No damage dealt"
var kills: Dictionary = {}
var squad_name := "No squad formed"
var squad_power := 0
var toy_age := [99.0,99.0,99.0,99.0,99.0]
var scenery_time := 0.0
var scenery_rng := RandomNumberGenerator.new()
var next_scenery_effect := 0.0
var ambient_started := [-99.0,-99.0,-99.0,-99.0,-99.0]
var green_eyes := [false,false,false,false,false]

func _init() -> void:
	scenery_rng.randomize()
	next_scenery_effect = scenery_rng.randf_range(10.0,45.0)

func reset() -> void:
	intro_age = 0
	biggest = 0
	biggest_name = "No damage dealt"
	kills.clear()
	squad_name = "No squad formed"
	squad_power = 0
	toy_age = [99.0,99.0,99.0,99.0,99.0]

func record(source: String, damage: int, killed: bool, card_id := -1) -> void:
	if source.is_empty(): return
	if damage>biggest:
		biggest = damage
		biggest_name = source
	if killed and card_id>=0:
		var name: String = Cards.DATA[card_id].name
		kills[name] = int(kills.get(name,0))+1

func observe(row: Array) -> void:
	for combo in Squads.active(row):
		var power := 0
		for lane in Squads.members(row,combo): power += Squads.attack_value(row,lane)
		if power>squad_power:
			squad_name = combo.name
			squad_power = power

func start_intro(g) -> void:
	intro_age = 0
	g.modal = "matchup"
	g.audio.play("DSDOROPN",-15)
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99

func finish_intro(g) -> void:
	g.modal = ""
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99

func tick(g, delta: float) -> void:
	scenery_time += delta
	if scenery_time>=next_scenery_effect:
		var region := scenery_rng.randi_range(0,4)
		ambient_started[region] = scenery_time
		if region in [0,3]: green_eyes[region] = scenery_rng.randf()<0.4
		next_scenery_effect = scenery_time+scenery_rng.randf_range(10.0,45.0)
	for i in toy_age.size(): toy_age[i] += delta
	if g.modal=="matchup":
		var before := intro_age
		intro_age += delta
		if before<0.55 and intro_age>=0.55: g.audio.play("DSBAREXP",-20)
		if intro_age>=4.8: finish_intro(g)
	if g.modal=="" and not g.busy and not g.ended:
		observe(g.friendly)

func draw_intro(g) -> void:
	g.label_at(Vector2(490,150),"ONE TABLE. ONE SURVIVOR.",30,g.ORANGE)
	var progress := clampf(intro_age/0.55,0,1)
	var ease_out := 1-pow(1-progress,3)
	for side in 2:
		var id: String = g.player_commander if side==0 else g.enemy_commander
		var center := Vector2(400 if side==0 else 1040,390)
		center.x += (-700 if side==0 else 700)*(1-ease_out)
		var slam := sin((intro_age-0.55)*42)*maxf(0,1-(intro_age-0.55)/0.35)*7 if intro_age>=0.55 else 0.0
		g.draw_set_transform(center+Vector2(slam,0),(-0.035 if side==0 else 0.035)*progress)
		g.draw_commander_portrait(Rect2(-140,-140,280,280),id,g.ORANGE)
		g.draw_set_transform(Vector2.ZERO)
		if intro_age>0.6:
			var name: String = g.Commanders.entry(id).name
			g.label_at(Vector2(center.x-g.text_width(name,26)/2,575),name,26,g.INK)
		if intro_age>(0.85 if side==0 else 1.65):
			var line: String = Voices.LINES[id][0]
			g.label_at(Vector2(center.x-g.text_width(line,19)/2,625),line,19,g.ORANGE)
	if intro_age>0.55: g.label_at(Vector2(680,410),"VS",44,g.ORANGE)
	g.button(Rect2(550,770,340,55),"FIGHT / SKIP INTRO")

func draw_highlights(g) -> void:
	g.label_at(Vector2(330,690),"YOUR MATCH HIGHLIGHTS",24,g.ORANGE)
	g.label_at(Vector2(330,727),"STRONGEST SQUAD: "+squad_name+(" / %d TOTAL ATK" % squad_power if squad_power>0 else ""),17,g.INK)
	g.label_at(Vector2(330,758),"BIGGEST HIT: "+biggest_name+(" / %d DAMAGE" % biggest if biggest>0 else ""),17,g.INK)
	var leader := "No card kills"
	var count := 0
	for name in kills:
		if kills[name]>count:
			leader = name
			count = kills[name]
	g.label_at(Vector2(330,789),"TOP SLAYER: "+leader+(" / %d KILLS" % count if count>0 else ""),17,g.INK)
	g.label_at(Vector2(330,824),"Squad ranked by combined ATK; hits use actual Health / HP removed. Kills grouped by card name.",12,g.MUTED)

# Coordinates follow the original 640x400 background, not the window size.
# Only existing painted scenery is relit; no decorative sprites are added.
const GLOW_MASK = preload("res://assets/backgrounds/hellscape-glow-mask.png")
# Bounds select independent parts of the supplied white-on-black emission mask.
const MASK_REGIONS := [Rect2(510,145,40,35),Rect2(200,65,120,165),Rect2(195,330,240,70),Rect2(540,270,45,32),Rect2(312,188,74,46)]
const SCENERY := [
	[Vector2(510,145),Vector2(550,145),Vector2(550,180),Vector2(510,180)],
	[Vector2(200,65),Vector2(320,65),Vector2(320,230),Vector2(200,230)],
	[Vector2(210,270),Vector2(415,270),Vector2(415,400),Vector2(210,400)],
	[Vector2(545,255),Vector2(595,255),Vector2(595,315),Vector2(545,315)],
	[Vector2(312,188),Vector2(386,188),Vector2(386,234),Vector2(312,234)]
]
var mask_textures: Array[Texture2D] = []
var bloom_textures: Array[Texture2D] = []

func prepare_mask() -> void:
	if not mask_textures.is_empty(): return
	var source: Image = GLOW_MASK.get_image()
	if source.is_compressed(): source.decompress()
	source.convert(Image.FORMAT_RGBA8)
	var ratio := Vector2(source.get_size())/Vector2(640,400)
	for region in MASK_REGIONS:
		var pixels: Image = source.get_region(Rect2i(region.position*ratio,region.size*ratio))
		for y in pixels.get_height():
			for x in pixels.get_width():
				var pixel := pixels.get_pixel(x,y)
				var mask := clampf((maxf(pixel.r,maxf(pixel.g,pixel.b))-0.08)/0.92,0,1)*pixel.a
				pixels.set_pixel(x,y,Color(1,1,1,mask))
		mask_textures.append(ImageTexture.create_from_image(pixels))
		bloom_textures.append(ImageTexture.create_from_image(soft_bloom(pixels)))

func soft_bloom(source: Image) -> Image:
	var width := source.get_width()
	var height := source.get_height()
	var values := PackedFloat32Array()
	values.resize(width*height)
	for y in height:
		for x in width: values[y*width+x] = source.get_pixel(x,y).a
	# Two separable box passes approximate a soft Gaussian, computed once.
	var radius := 7
	for pass_index in 2:
		var horizontal := PackedFloat32Array()
		horizontal.resize(values.size())
		for y in height:
			var total := 0.0
			for x in range(-radius,width+radius):
				if x+radius<width and x+radius>=0: total += values[y*width+x+radius]
				if x-radius-1>=0 and x-radius-1<width: total -= values[y*width+x-radius-1]
				if x>=0 and x<width: horizontal[y*width+x] = total/float(radius*2+1)
		var vertical := PackedFloat32Array()
		vertical.resize(values.size())
		for x in width:
			var total := 0.0
			for y in range(-radius,height+radius):
				if y+radius<height and y+radius>=0: total += horizontal[(y+radius)*width+x]
				if y-radius-1>=0 and y-radius-1<height: total -= horizontal[(y-radius-1)*width+x]
				if y>=0 and y<height: vertical[y*width+x] = total/float(radius*2+1)
		values = vertical
	var result := Image.create(width,height,false,Image.FORMAT_RGBA8)
	for y in height:
		for x in width: result.set_pixel(x,y,Color(1,1,1,clampf(values[y*width+x],0,1)))
	return result

func scenery_scale(g) -> Vector2:
	var cover := maxf(1440.0/g.BACKGROUND.get_width(),940.0/g.BACKGROUND.get_height())
	return g.BACKGROUND.get_size()*cover/Vector2(640,400)

func scenery_offset(g) -> Vector2:
	return (Vector2(1440,940)-Vector2(640,400)*scenery_scale(g))/2

func scenery_points(g, index: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in SCENERY[index]: points.append(scenery_offset(g)+point*scenery_scale(g))
	return points

func scenery_center(g, index: int) -> Vector2:
	var center := Vector2.ZERO
	for point in scenery_points(g,index): center += point
	return center/SCENERY[index].size()

func click_toy(g, pos: Vector2) -> bool:
	if g.modal!="" or g.busy or g.ended or g.drag_index>=0 or g.selected>=0 or g.hero_power.armed: return false
	# Foreground controls and cards always get priority over scenery behind them.
	for rect in [g.MENU_BUTTON,g.ARMORY_BUTTON,g.COMMANDER_BUTTON,g.END_BUTTON,g.BATTLE_VIEW_BUTTON,g.COMBOS_BUTTON,g.battle_tools.HISTORY_BUTTON,g.SURGE_BUTTON,g.REVIVE_BUTTON]:
		if rect.has_point(pos): return false
	for h in g.hand.size():
		if g.hand_rect(h).has_point(pos): return false
	for side in 2:
		var row: Array = g.friendly if side==0 else g.enemy
		for lane in 4:
			if not row[lane].is_empty() and g.lane_rect(side,lane).has_point(pos): return false
	for i in SCENERY.size():
		if Geometry2D.is_point_in_polygon(pos,scenery_points(g,i)):
			if toy_age[i]<0.4: return true
			toy_age[i] = 0
			if i in [0,3]: green_eyes[i] = scenery_rng.randf()<0.4
			return true
	return false

func ambient_strength(index: int, time: float) -> float:
	var age: float = time-ambient_started[index]
	var duration := 6.0 if index in [1,2,4] else 3.6
	if age<0 or age>=duration: return 0.0
	# Quiet red bloom fades smoothly in and out; scheduling uses cosmetic RNG only.
	return pow(sin(age/duration*PI),2)*0.65

func draw_toys(g) -> void:
	prepare_mask()
	for i in MASK_REGIONS.size():
		# Skull chroma masks are rendered independently by scenery_animation.
		if i in [0,3]: continue
		var age: float = toy_age[i]
		var clicked := 0.0
		if age<2.4:
			clicked = minf(age/0.12,1.0)*pow(maxf(0,1-age/2.4),1.3)*(0.88+0.12*sin(age*13))
		var strength := maxf(clicked,ambient_strength(i,scenery_time))*0.75
		if strength<=0: continue
		var region: Rect2 = MASK_REGIONS[i]
		var destination := Rect2(scenery_offset(g)+region.position*scenery_scale(g),region.size*scenery_scale(g))
		g.draw_texture_rect(bloom_textures[i],destination,false,Color(1,0.025,0.005,strength*0.65))
		g.draw_texture_rect(mask_textures[i],destination,false,Color(1,0.06,0.015,strength*0.65))
