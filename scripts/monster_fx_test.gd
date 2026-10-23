extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void:
	assert("--balance-test" in OS.get_cmdline_user_args())
	run.call_deferred()
func run() -> void:
	var game = Game.new()
	root.add_child(game)
	var count := 0
	var checked_textures := {}
	game.new_battle()
	AudioServer.set_bus_mute(0,true)
	var report := FileAccess.open("res://reports/monster-effects-audit.csv",FileAccess.WRITE)
	report.store_csv_line(["Monster","Attack type","Projectile or tracer","Front frames","Side frames","Hit reaction"])
	for id in game.Cards.CATALOG_SIZE:
		var data: Dictionary = game.Cards.DATA[id]
		if data.hp<=0: continue
		count += 1
		var key: String = game.projectile_key(id)
		if key!="":
			for bank in [game.art.effect_textures,game.art.side_effect_textures]:
				assert(not bank.get(key,[]).is_empty(),"Missing projectile: "+data.name)
				for texture in bank[key]:
					if checked_textures.has(texture): continue
					checked_textures[texture] = true
					assert(texture.get_image().get_used_rect().has_area(),"Invisible projectile: "+data.name)
		else:
			assert(data.type in ["MELEE","BULLET"],"Ranged monster without projectile")
		for level in range(1,11):
			var leveled: int = game.Cards.leveled_id(id,level)
			for side in 2:
				var unit: Dictionary = game.Cards.unit(leveled)
				unit.hp = 100
				unit.shield = false
				var row: Array = game.friendly if side==0 else game.enemy
				row[0] = unit
				game.hit(side,0,1,"BULLET",side==1)
				assert(game.unit_hit_strength(unit)==1 and game.unit_hit_offset(unit).length()>0,"Missing hit shake: "+data.name)
		report.store_csv_line([data.name,data.type,key if key!="" else ("BULLET TRACER" if data.type=="BULLET" else "MELEE"),str(game.art.effect_textures.get(key,[]).size()),str(game.art.side_effect_textures.get(key,[]).size()),"PASS: both sides, levels 1-10"])
	# Simultaneous splash must retain every reaction; shields also react to contact.
	for lane in 4:
		game.enemy[lane] = game.Cards.unit(1)
		game.enemy[lane].shield = true
		game.hit(1,lane,1,"ROCKET")
	for unit in game.enemy: assert(game.unit_hit_strength(unit)==1)
	game.clock += 0.5
	for unit in game.enemy: assert(game.unit_hit_strength(unit)==0)
	Engine.time_scale = 4
	var attacks := 0
	for cinema in [false,true]:
		game.cinematic_enabled = cinema
		for side in 2:
			for id in game.Cards.CATALOG_SIZE:
				if game.Cards.DATA[id].hp<=0: continue
				game.friendly = [game.Cards.unit(id),{},{},{}]
				game.enemy = [game.Cards.unit(id),{},{},{}]
				for row in [game.friendly,game.enemy]:
					row[0].hp = 1000
					row[0].shield = false
					row[0].ready = true
				game.player_hp = 1000
				game.enemy_hp = 1000
				var shot_seen := [false,false]
				game.attack_once(side,0)
				while game.moving_side>=0:
					if game.projectile.x>0: shot_seen[game.projectile_side] = true
					await process_frame
				if game.Cards.DATA[id].type!="MELEE":
					assert(shot_seen[0] and shot_seen[1],"Missing attack/counter projectile: "+game.Cards.DATA[id].name)
				attacks += 1
	print("PASS: ",attacks," full attack/counter sequences, every monster in both views and both directions")
	print("PASS: ",count," monsters, both sides at all 10 levels; ",checked_textures.size()," projectile textures; simultaneous splash, shields and shake expiry")
	game.queue_free()
	await process_frame
	quit()
