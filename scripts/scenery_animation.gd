extends Sprite2D
const FRAMES := [
	preload("res://assets/backgrounds/animation/frame-00.png"),
	preload("res://assets/backgrounds/animation/frame-01.png"),
	preload("res://assets/backgrounds/animation/frame-02.png"),
	preload("res://assets/backgrounds/animation/frame-03.png"),
	preload("res://assets/backgrounds/animation/frame-04.png"),
	preload("res://assets/backgrounds/animation/frame-05.png"),
	preload("res://assets/backgrounds/animation/frame-06.png"),
	preload("res://assets/backgrounds/animation/frame-07.png")]

func _ready() -> void:
	texture = FRAMES[0]
	position = Vector2(720,470)
	scale = Vector2.ONE*maxf(1440.0/texture.get_width(),940.0/texture.get_height())
	z_index = -10
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://scripts/scenery_animation.gdshader")
	shader_material.set_shader_parameter("eyes",FRAMES[3])
	material = shader_material

func update_effects(flair) -> void:
	var phase: float = flair.scenery_time/0.85
	var index := int(phase)%FRAMES.size()
	material.set_shader_parameter("frame_a",FRAMES[index])
	material.set_shader_parameter("frame_b",FRAMES[(index+1)%FRAMES.size()])
	material.set_shader_parameter("blend",smoothstep(0.0,1.0,fposmod(phase,1.0)))
	var lava := 0.0
	for i in [1,2,4]: lava = maxf(lava,flair.ambient_strength(i,flair.scenery_time)/0.65)
	material.set_shader_parameter("lava_strength",lava*0.75)
	for i in [0,3]:
		var age: float = flair.toy_age[i]
		var clicked := sin(clampf(age/2.4,0,1)*PI) if age<2.4 else 0.0
		var strength := maxf(clicked,flair.ambient_strength(i,flair.scenery_time)/0.65)
		var prefix := "upper" if i==0 else "lower"
		material.set_shader_parameter(prefix+"_strength",strength*0.75)
		material.set_shader_parameter(prefix+"_green",flair.green_eyes[i])
