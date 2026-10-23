extends SceneTree
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var combo: Dictionary = Squads.COMBOS[1]
	var row: Array = [Cards.unit(3),{},Cards.unit(5),Cards.unit(0)]
	var hand: Array = [17,15,1,0]
	var status := Squads.deployment_status(combo,row,hand,10,10)
	assert(status.state=="PIECES AVAILABLE" and status.playable.is_empty())
	assert(status.detail=="Needs 2 free lanes (1 available)")
	row[2] = {}
	status = Squads.deployment_status(combo,row,hand,10,10)
	assert(status.state=="PLAYABLE NOW" and status.playable.has(1) and status.playable.has(2))
	assert(Squads.hand_hints(row,hand,10,10).playable.has(1),"Automatic without markers")
	status = Squads.deployment_status(combo,row,hand,0,10)
	assert(status.state=="PIECES AVAILABLE" and "Energy" in status.detail)
	row[1] = Cards.unit(15)
	row[2] = Cards.unit(1)
	assert(Squads.deployment_status(combo,row,hand,0,0).state=="ACTIVE")
	assert(Squads.deployment_status(combo,[{},{},{},{}],[1,1,3],20,20).state=="INCOMPLETE")
	var mythic := -1
	for id in Cards.CATALOG_SIZE:
		if Cards.base_id(id)==15 and Cards.DATA[id].get("soul_cost",0)>0: mythic=id
	assert("Souls" in Squads.deployment_status(combo,[Cards.unit(1),Cards.unit(3),{},{}],[mythic],30,0).detail)
	var g = preload("res://scripts/main.gd").new()
	root.add_child(g)
	root.warp_mouse(Vector2(1420,920))
	g.friendly = [Cards.unit(3),{},Cards.unit(5),Cards.unit(0)]
	g.hand = hand
	g.energy = 10
	g.souls = 10
	g.modal = "combos"
	assert(g.squad_guide_state(combo)=="PIECES AVAILABLE")
	if "--visual-test" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/squad-availability-guide.png")
	g.friendly[2] = {}
	g.modal = ""
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99
	if "--visual-test" in OS.get_cmdline_user_args():
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://captures/automatic-squad-hints.png")
	print("PASS: blocked screenshot scenario, automatic hints, lanes, combined resources, incomplete and active squads")
	g.queue_free()
	await process_frame
	quit()
