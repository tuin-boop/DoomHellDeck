extends SceneTree
const Game = preload("res://scripts/main.gd")
const Cards = preload("res://scripts/cards.gd")
const Squads = preload("res://scripts/squads.gd")
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func shot(name: String) -> void:
	if not "--visual-test" in OS.get_cmdline_user_args(): return
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://captures/"+name+".png")
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	root.warp_mouse(Vector2(1420,920))
	var daisy := Cards.by_actor("Daisy")
	assert(daisy==148 and Cards.CATALOG_SIZE==155)
	assert(Cards.DATA[daisy].hp==3 and Cards.DATA[daisy].cost==2)
	assert(Cards.unit(daisy,true).ready and Cards.unit(daisy).shield)
	assert(g.art.textures.DAISY.size()==4 and g.art.side_attack_textures.DAISY.size()==4)
	assert(g.art.sounds.has("res://assets/daisy/bite.wav"))
	assert(Squads.active([Cards.unit(22),Cards.unit(daisy),{},{}]).size()==1)
	g.match_flair.start_intro(g)
	g.match_flair.intro_age = 2
	assert(g.modal=="matchup")
	await shot("quickplay-matchup")
	g.match_flair.tick(g,3)
	assert(g.modal=="")
	g.hand = [daisy,22,0,3]
	g.friendly = [Cards.unit(22),Cards.unit(daisy),{},{}]
	g.match_flair.observe(g.friendly)
	assert(g.match_flair.squad_name=="BUNNY GUARD")
	var old_energy: int = g.energy
	var old_souls: int = g.souls
	var old_rng: int = g.rng.state
	for i in [0,1]: assert(g.match_flair.click_toy(g,g.match_flair.scenery_center(g,i)))
	assert(g.energy==old_energy and g.souls==old_souls and g.rng.state==old_rng)
	g.busy = true
	assert(not g.match_flair.click_toy(g,Vector2(1200,310)))
	g.busy = false
	await shot("daisy-card-and-tabletop")
	g.enemy = [Cards.unit(1),{},{},{}]
	g.enemy[0].hp = 2
	g.hit(1,0,99,"MELEE",false,daisy)
	assert(g.match_flair.biggest==2 and g.match_flair.kills.DAISY==1,"Actual HP removed, not overkill")
	g.enemy[0] = Cards.unit(5)
	g.hit(1,0,99,"MELEE",false,daisy)
	assert(g.match_flair.biggest==2,"Shielded hits do not count")
	g.enemy[0] = Cards.unit(1)
	g.enemy[0].hp = 1
	g.hit(1,0,1,"MELEE",true,daisy)
	assert(g.match_flair.kills.DAISY==2,"Counters attributed to defender")
	g.damage_hero(1,7,"ROCKET STRIKE")
	assert(g.match_flair.biggest==7 and g.match_flair.biggest_name=="ROCKET STRIKE")
	g.enemy_hp = 0
	g.check_end()
	g.battle_voice.speech_age = 99
	g.battle_voice.headline_age = 99
	await shot("quickplay-highlights")
	g.new_battle()
	assert(g.match_flair.biggest==0 and g.match_flair.kills.is_empty() and g.match_flair.squad_power==0)
	print("PASS: matchup lifecycle, highlights damage/counters/shields/reset, cosmetic toys isolated from combat, Daisy assets/stats/Ambush/squad")
	g.queue_free()
	await process_frame
	quit()
