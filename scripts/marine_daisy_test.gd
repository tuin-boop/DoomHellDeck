extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var g = load("res://scripts/main.gd").new()
	root.add_child(g)
	AudioServer.set_bus_mute(0,true)
	var m = g.hell_meld
	m.start(g)
	m.run.enabled = false
	var ranks := {}
	for monster in m.POOL: ranks[m.card_data(monster).cost] = monster
	var ids := [ranks[1],ranks[3],ranks[5]]
	for owner in 2:
		m.support.reset()
		assert(m.Rules.special_pattern(m,owner,ids,"run").is_empty())
		for id in range(280,285):
			m.support.reset()
			m.support.slots[owner] = [id]
			m.round_scores[owner] = 0
			m.round_scores[1-owner] = 100
			m.support.stats[owner].last = "set"
			var combo = m.Rules.special_pattern(m,owner,ids,"run")
			assert(combo.name=="BUNNY HOP" and combo.points==20)
			combo.gain = 20
			var result = m.support.score(m,owner,ids,combo,true)
			assert(result.bonus==[0,3,5,8,12][id-280])
			for event in result.events: assert(event.id==id)
			assert(m.Rules.special_pattern(m,1-owner,ids,"run").is_empty())
			assert(m.Rules.special_pattern(m,owner,[ranks[1],ranks[3],ranks[5],ranks[7]],"run").points==40)
			assert(m.Rules.special_pattern(m,owner,[ranks[1],ranks[1],ranks[5]],"run").is_empty())
			assert(m.Rules.special_pattern(m,owner,[ranks[1],ranks[3]],"run").is_empty())
			assert(m.Rules.special_pattern(m,owner,[ranks[1],-1,ranks[5]],"run").points==20)
	print("PASS Marine Daisy: ownership, hop ranks, extension, wildcard, four variants and scoring events")
	quit()
