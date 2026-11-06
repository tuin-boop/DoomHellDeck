extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var rounds_played := 0
	var stages_cleared := 0
	var deepest := 1
	var scores: Array = []
	var joker_stats := {}
	for id in Meld.new().support.DATA.size(): joker_stats[id] = {"name":Meld.new().support.DATA[id][1],"plays":0,"points":0,"triggers":0}
	var stage_results := {}
	for game in 500:
		var m = Meld.new()
		m.profile.path = "user://endless-sim-profile.cfg"
		m.profile.loaded = true
		m.run.path = "user://endless-sim-run.cfg"
		m.run.enabled = true
		m.random.seed = 2026102700+game
		m.progression.enabled = true
		m.progression.recorded = true
		m.match_powers = true
		m.passive_joker = [game%3,game%3]
		m.next_round()
		m.support.offer(m)
		while m.run.alive and m.run.stage<=8:
			if m.support.pending:
				m.support.chosen = m.support.auto_pick(m,0,m.support.offers)
				m.support.finish_pick(m)
			assert(m.progression.active)
			m.progression.cpu_shop(m,0)
			m.progression.finish(m)
			while not m.round_over:
				var owner: int = m.side
				var move: Dictionary = m.best_move(owner)
				if move.indices.is_empty(): assert(m.draw_one(owner))
				else:
					var before: int = m.scores[owner]
					var expected: int = m.evaluate(owner,move.indices).gain
					assert(m.play(owner,move.indices,move.target))
					for id in m.support.slots[owner]: joker_stats[id].plays += 1
					for event in m.announcement.support_events:
						if event.get("amount",0)>0:
							joker_stats[event.id].points += event.amount
							joker_stats[event.id].triggers += 1
					var award := 30 if m.round_over and m.round_award_owner==owner else 0
					assert(m.scores[owner]-before==m.announcement.gain+award,"Committed score matches the displayed gain")
					if not m.support.has(owner,3): assert(m.scores[owner]-before==expected+award,"Deterministic preview and commit agree")
				var count: int = m.stock.size()+m.hands[0].size()+m.hands[1].size()+m.discarded.size()
				for meld in m.melds: count += meld.ids.size()
				assert(count==69 and m.turns[0]<=10 and m.turns[1]<=10)
			rounds_played += 1
			for owner in 2:
				assert(m.progression.credits[owner]>=0 and m.support.slots[owner].size()<=m.slot_limit())
			if m.finished:
				for owner in 2:
					var total := 0
					for row in m.round_history: total += row.points[owner]
					assert(total==m.scores[owner])
				if not stage_results.has(m.run.stage): stage_results[m.run.stage] = [0,0,0]
				stage_results[m.run.stage][m.result_winner if m.result_winner>=0 else 2] += 1
				if m.result_winner==0: stages_cleared += 1
				if m.result_winner==1: break
				m.run.continue_stage({"ended":false},m)
				m.progression.recorded = true
				deepest = maxi(deepest,m.run.stage)
			else: m.choose_upgrade(m.random.randi_range(0,2))
		scores.append(m.run.score(m))
		if (game+1)%10==0: print("Completed ",game+1," endless runs")
	for path in ["user://endless-sim-run.cfg","user://endless-sim-run.cfg.tmp","user://endless-sim-profile.cfg"]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var report := {"runs":500,"jokers":joker_stats,"stage_results":stage_results,"rounds":rounds_played,"stages_cleared":stages_cleared,"deepest_stage":deepest,"scores":scores,"policy":"Same greedy move and standard shop policy, random player route. Max 8 stages; CPU pressure enabled."}
	FileAccess.open("res://reports/variants-endless-500.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("PASS: ",JSON.stringify(report))
	quit()
