extends Node2D
## Presentation only: no combat RNG, waits, or rule changes.
var glyphs: Dictionary = {}
var game
var fallback: Font
var elapsed := 0.0
var speech := ""
var headline := ""
var speech_age := 99.0
var headline_age := 99.0
var cooldown := 0.0
var speaker := "graves"
var outcome := false
var seen: Dictionary = {}
var presentation_rng := RandomNumberGenerator.new()
var speech_center := Vector2(720,300)
var speech_tilt := 0.0
const Commanders = preload("res://scripts/commanders.gd")
const LINES := {
	"tuin":["LET'S MAKE SOME TROUBLE.","LOOKING GOOD, TEAM!","WE'RE STILL IN THIS.","THAT'S HOW WE DO IT!","ALRIGHT. REMATCH?"],
	"synapse":["THREE TARGETS. ONE THOUGHT.","YOUR MOVES ARE CALCULATED.","RECALIBRATING...","A FLAWLESS FIRING SOLUTION.","THAT WAS NOT IN THE MODEL."],
	"ashfang":["LET'S TURN UP THE HEAT!","YOU'RE STARTING TO SIZZLE.","JUST A SCRATCH... RIGHT?","ASHES. JUST AS PLANNED.","WHO PUT OUT MY FIRE?!"],
	"oculus":["I HAVE MY EYE ON YOU.","I SEE A TASTY VICTORY.","STOP AIMING FOR THE EYE!","A DELICIOUS LITTLE DUEL.","I DID NOT SEE THAT COMING."],
	"iron_tyrant":["TARGET ACQUIRED.","YOUR DEFENSES ARE FAILING.","ARMOR CRITICAL. STILL FIRING.","RESISTANCE TERMINATED.","SYSTEM FAILURE... IMPOSSIBLE."],
	"goremaw":["COME CLOSER. I'M HUNGRY.","I CAN SMELL YOUR FEAR!","THAT ONE HAD TEETH.","ALL BITE. NO SURVIVORS.","I BIT OFF TOO MUCH."],
	"graves":["LOCK AND LOAD.","KEEP UP. IF YOU CAN.","NOT OUT OF THIS FIGHT YET.","AREA SECURED.","GOOD SHOT. NEXT TIME'S MINE."],
}

func _ready() -> void:
	presentation_rng.randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	z_index = 10

func reset(id: String) -> void:
	speaker = id
	seen.clear()
	cooldown = 0
	outcome = false
	react("opening",true)
	announce("ENTER THE ARENA")

func react(event: String, force := false) -> void:
	if not force and (cooldown>0 or seen.has(event)): return
	var index: int = {"opening":0,"winning":1,"losing":2,"victory":3,"defeat":4}.get(event,0)
	speech = LINES.get(speaker,LINES.graves)[index]
	speech_age = 0
	speech_center = Vector2(720+presentation_rng.randf_range(-85,85),300+presentation_rng.randf_range(-15,15))
	speech_tilt = deg_to_rad(presentation_rng.randf_range(3,7))*(1 if presentation_rng.randf()>0.5 else -1)
	cooldown = 12
	seen[event] = true

func announce(message: String) -> void:
	headline = message.to_upper()
	headline_age = 0

func _process(delta: float) -> void:
	elapsed += delta
	speech_age += delta
	headline_age += delta
	cooldown = maxf(0,cooldown-delta)
	queue_redraw()

func width(text: String, scale_value: float) -> float:
	var result := 0.0
	for character in text:
		result += (glyphs[character].get_width()+1 if glyphs.has(character) else 5)*scale_value
	return result

func lettering(text: String, position: Vector2, scale_value: float, alpha: float, age: float) -> void:
	if glyphs.is_empty():
		draw_string(fallback,position+Vector2(0,16),text,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color(1,0.35,0.2,alpha))
		return
	var x := position.x
	for i in text.length():
		var character := text[i]
		var reveal := clampf((age-i*0.018)/0.24,0,1)
		if glyphs.has(character):
			var texture: Texture2D = glyphs[character]
			var pos := Vector2(x,position.y+(1-reveal)*(1-reveal)*14+sin(elapsed*2+i*0.4)*0.6)
			var rect := Rect2(pos,texture.get_size()*scale_value)
			draw_texture_rect(texture,Rect2(rect.position+Vector2(2,3),rect.size),false,Color(0,0,0,alpha*reveal))
			draw_texture_rect(texture,rect,false,Color(1,1,1,alpha*reveal))
			x += (texture.get_width()+1)*scale_value
		else: x += 5*scale_value

func _draw() -> void:
	if headline_age<3:
		var alpha := minf(headline_age/0.2,(3-headline_age)/0.5)
		var size_scale := minf(2.5,790/maxf(1,width(headline,1)))
		lettering(headline,Vector2(720-width(headline,size_scale)/2,113),size_scale,clampf(alpha,0,1),headline_age)
	if speech_age>=5.5: return
	var portrait_rect := speaking_portrait_rect(speech_age)
	var return_amount := clampf((speech_age-4.85)/0.65,0,1)
	var tilt := speech_tilt*clampf(speech_age/0.55,0,1)*(1-return_amount)
	draw_set_transform(portrait_rect.get_center()+(game.hero_feedback.offset(1) if game!=null else Vector2.ZERO),tilt)
	var local_rect := Rect2(-portrait_rect.size/2,portrait_rect.size)
	draw_rect(local_rect.grow(6),Color(0.05,0.025,0.015,0.94))
	draw_texture_rect(Commanders.entry(speaker).portrait,local_rect,false)
	draw_rect(local_rect.grow(3),Color("e57968"),false,3)
	draw_set_transform(Vector2.ZERO)
	var alpha := clampf(minf((speech_age-0.65)/0.25,(4.85-speech_age)/0.4),0,1)
	draw_set_transform(speech_center+Vector2(0,151),speech_tilt)
	var line := ""
	var line_index := 0
	for word in speech.split(" "):
		if width(line+word,3.5)>560 and not line.is_empty():
			lettering(line,Vector2(-width(line,3.5)/2,line_index*39),3.5,alpha,speech_age-0.65)
			line_index += 1
			line = ""
		line += word+" "
	lettering(line,Vector2(-width(line,3.5)/2,line_index*39),3.5,alpha,speech_age-0.65)
	draw_set_transform(Vector2.ZERO)

func speaking_portrait_rect(age: float) -> Rect2:
	# One continuous portrait: travel, overshoot-scale, speak, then glide home.
	var travel := 1-pow(1-clampf(age/0.55,0,1),3)
	var return_progress := clampf((age-4.85)/0.65,0,1)
	var home := return_progress*return_progress*(3-2*return_progress)
	var pop := clampf((age-0.2)/0.4,0,1)
	var overshoot := 1+2.70158*pow(pop-1,3)+1.70158*pow(pop-1,2)
	var extent := lerpf(88,224,overshoot*(1-home))
	var center := Vector2(488,60).lerp(speech_center,travel*(1-home))
	center.y -= sin(travel*PI)*70*(1-home)
	# A small sideward arc gives the return a sweep instead of a straight shrink.
	center += Vector2(65*(1 if speech_tilt>0 else -1),-45)*sin(home*PI)
	return Rect2(center-Vector2.ONE*extent/2,Vector2.ONE*extent)
