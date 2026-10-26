extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	run.call_deferred()
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.start(g)
	m.progression.enabled = true
	m.progression.recorded = true
	m.round_number = 3
	m.support.slots = [[0,47],[2,49]]
	m.support.chosen = m.support.offers[0]
	if m.support.chosen==0: m.support.chosen = m.support.offers[1]
	m.support.finish_pick(m)
	m.progression.offers = [{"id":48,"edition":1,"price":11,"sold":false},{"id":49,"edition":4,"price":11,"sold":false},{"id":41,"edition":2,"price":9,"sold":false}]
	m.support.editions[0][0] = 6
	await shot("progression-shop")
	var before_credits: int = m.progression.credits[0]
	var pack_click := InputEventMouseButton.new()
	pack_click.button_index = MOUSE_BUTTON_LEFT
	pack_click.pressed = true
	pack_click.position = Vector2(1120,385)
	m.progression.handle(g,m,pack_click)
	assert(m.progression.preview_pack==1 and m.progression.credits[0]==before_credits and m.progression.pack_kind==-1)
	await shot("shop-edition-explanation")
	pack_click.position = Vector2(300,725)
	m.progression.handle(g,m,pack_click)
	assert(m.progression.preview_pack==-1 and m.progression.credits[0]==before_credits)
	m.progression.credits[0] = 30
	m.progression.open_pack(m,1)
	m.progression.pack_choices = [1,2,8]
	m.progression.pack_age = 3
	await shot("progression-pack")
	m.progression.pack_kind = -1
	m.progression.finish(m)
	m.next_round()
	m.round_intro = true
	m.round_intro_age = 12
	await shot("progression-boss")
	m.round_intro = false
	m.round_number = 2
	m.finish_round(0,"test")
	m.power_panel = true
	await shot("progression-boss-routes")
	m.power_panel = false
	m.profile.open = true
	m.profile.unlocked = ["hellatro","obsidian","scream_king","gold","prism","sleepy_mancubus","pirate_cacodemon"]
	m.profile.page = 0
	await shot("progression-backs-1")
	m.profile.page = 1
	await shot("progression-backs-2")
	m.profile.selected = "pirate_cacodemon"
	m.profile.selection_started = Time.get_ticks_msec()/1000.0-0.4
	await shot("card-back-equipped")
	m.profile.open = false
	m.progression.recap_open = true
	m.progression.recap.best = [{"name":"HELL'S LADDER","gain":133},{"name":"RIFT MARCH","gain":98}]
	m.progression.recap.jokers = [{0:35,47:0},{2:40}]
	m.progression.earned_backs = ["SCREAM KING","SLEEPY MANCUBUS"]
	await shot("progression-recap")
	# Options entry and close use the real input route.
	m.progression.recap_open = false
	g.modal = "options"
	g.frontend.click(g,Vector2(800,730))
	assert(m.profile.open)
	var key := InputEventKey.new()
	key.pressed = true
	key.keycode = KEY_ESCAPE
	assert(g.frontend.handle(g,key) and not m.profile.open)
	print("PASS: shop, packs, boss reveal, boss routes, card back collection, recap and options navigation rendered")
	quit()
