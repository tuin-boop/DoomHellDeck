extends Node3D
var rails: Array[MeshInstance3D] = []
var time := 0.0
var flare := 0.0

func _ready() -> void:
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0, 9, 7)
	camera.look_at(Vector3.ZERO)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 12.0
	camera.current = true
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("090b10")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("8eabc3")
	settings.ambient_light_energy = 1.65
	environment.environment = settings
	add_child(environment)
	var light := OmniLight3D.new()
	light.position = Vector3(-3, 6, 2)
	light.light_color = Color("d7aa7c")
	light.light_energy = 3.0
	light.omni_range = 18
	add_child(light)
	box(Vector3(0,-0.5,0), Vector3(15,0.8,10), Color("151b23"))
	box(Vector3(0,-0.02,0), Vector3(13.8,0.16,8.8), Color("51544b"))
	# Recessed control rails, hazard stripes, and rivets make the table feel physical.
	for x in [-5.0,5.0]:
		box(Vector3(x,0.13,0),Vector3(1.5,0.25,8.1),Color("252d2c"))
		for z in [-3.8,-1.8,0.2,2.2,3.8]:
			box(Vector3(x-0.57,0.28,z),Vector3(0.10,0.08,0.10),Color("839183"))
			box(Vector3(x+0.57,0.28,z),Vector3(0.10,0.08,0.10),Color("839183"))
	for i in 18:
		var stripe := box(Vector3(-4.1+i*0.47,0.13,-3.9),Vector3(0.21,0.035,0.38),Color("9c7337"))
		stripe.rotation.y = 0.5
	for i in 10:
		box(Vector3(-6.2+i*1.38,0.075,0),Vector3(0.018,0.02,8.5),Color("202a2c"))
	for i in 8:
		box(Vector3(0,0.075,-4+i*1.15),Vector3(13.4,0.02,0.018),Color("202a2c"))
	for x in [-7.1, 7.1]:
		box(Vector3(x,0.08,0), Vector3(0.35,0.35,10), Color("36424a"))
	for z in [-4.7,4.7]:
		box(Vector3(0,0.08,z), Vector3(14.6,0.35,0.25), Color("36424a"))
	for x in [-6.6,6.6]:
		rails.append(box(Vector3(x,0.13,0), Vector3(0.055,0.04,8.8), Color("c95725"), true))
	for i in 12:
		box(Vector3(-6.1+i*1.1,0.12,4.2),Vector3(0.5,0.03,0.13),Color("7a602a"))

func box(pos: Vector3, dimensions: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = dimensions
	mesh.mesh = shape
	mesh.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = 0.65
	mat.roughness = 0.6
	mat.emission_enabled = glow
	mat.emission = color
	mesh.material_override = mat
	add_child(mesh)
	return mesh

func _process(delta: float) -> void:
	time += delta
	flare = maxf(0, flare - delta * 0.35)
	rotation.y = sin(time * 0.2) * 0.006
	for rail in rails:
		rail.material_override.emission_energy_multiplier = 1.0 + sin(time * 2.0) * 0.3 + flare * 4.0
