extends SceneTree
const Game = preload("res://scripts/main.gd")
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var g = Game.new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.profile.path = "user://run-feature-test-profile.cfg"
	m.run.path = "user://run-feature-test.cfg"
	m.start(g)
	m.run.enabled = true
	m.progression.enabled = true
	m.support.chosen = m.support.offers[0]
	m.support.finish_pick(m)
	m.progression.credits = [40,40]
	assert(not m.progression.open_pack(m,1,2),"Legendary locked before stage 4")
	m.profile.highest_stage = 4
	assert(m.progression.open_pack(m,1,2))
	assert(m.progression.pack_choices.size()==8 and m.progression.credits[0]==33)
	var choices: Array = m.progression.pack_choices.duplicate()
	m.run.save_run(m)
	assert(FileAccess.file_exists(m.run.path))
	# Rewrite the existing save atomically, then restore a paid unopened choice.
	m.progression.credits[0] = 32
	m.run.save_run(m)
	m.progression.pack_choices.clear()
	assert(m.run.resume(g,m))
	assert(m.progression.pack_choices==choices and m.progression.credits[0]==32)
	assert(m.progression.choose_pack(m,7))
	m.run.save_run(m)
	assert(m.run.resume(g,m) and m.progression.apply_edition>0)
	m.progression.pack_kind = -1
	m.progression.apply_edition = -1
	m.progression.packs_bought.clear()
	assert(m.progression.open_pack(m,2,2))
	m.progression.pack_age = 4
	var family: String = m.progression.pack_choices[0]
	assert(m.progression.choose_pack(m,0) and m.upgrades[0][family]==3)
	m.support.slots[0].clear()
	m.round_number = 3
	m.progression.credits[0] = 40
	assert(m.progression.open_pack(m,0,2))
	for item in m.progression.pack_choices: assert(item.id in m.support.RARE)
	m.progression.pack_age = 4
	assert(m.progression.choose_pack(m,0))
	m.progression.active = false
	# First to three round wins ends a stage even when points are lower.
	m.rounds = [2,0]
	m.scores = [80,999]
	m.round_start_scores = [80,999]
	m.round_over = false
	m.finish_round(0,"test")
	assert(m.finished and m.result_winner==0 and m.run.alive)
	var kept: Array = m.support.slots[0].duplicate()
	var cash: int = m.progression.credits[0]
	m.run.continue_stage(g,m)
	assert(m.run.stage==2 and m.run.banked==110 and m.rounds==[0,0])
	assert(m.support.slots[0]==kept and m.slot_limit()==5)
	# When five slots are full, the shop still opens each round.
	m.support.pending = false
	m.support.slots[0] = [0,1,2,3,4]
	m.progression.active = false
	m.support.offer(m)
	assert(m.progression.active)
	m.run.stage = 4
	# Added combinations only appear after their stage unlock.
	var twin: Dictionary = m.Rules.special_pattern(m,0,[0,0,0,1,1,1],"pairs")
	assert(twin.name=="TWIN TRINITY" and twin.points==90)
	m.run.stage = 1
	assert(m.Rules.special_pattern(m,0,[0,0,0,1,1,1],"pairs").get("name","")!="TWIN TRINITY")
	# Losing ends the run, deletes resume state and records score.
	m.run.stage = 2
	m.run.save_run(m)
	m.rounds = [0,2]
	m.round_number = 3
	m.round_over = false
	m.progression.recorded = false
	m.finish_round(1,"test")
	assert(not m.run.alive and not FileAccess.file_exists(m.run.path))
	assert(m.profile.best_run>=110 and m.profile.last_run_stage==2)
	for path in [m.run.path,m.run.path+".tmp",m.profile.path]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS: pack tiers, staged unlocks, atomic save/resume, paid choices, best-of-five, retained build, full-slot shop and game over")
	quit()
