extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var victories := [0,0,0]
	var total_points := [0,0]
	var bosses := 0
	var edition_triggers := 0
	var rule_plays := 0
	for game in 100:
		var m = Meld.new()
		m.random.seed = 2026102600+game
		m.progression.enabled = true
		m.progression.recorded = true
		m.match_powers = true
		m.passive_joker = [game%3,game%3]
		m.next_round()
		m.support.offer(m)
		while not m.finished:
			assert(m.support.pending)
			m.support.chosen = m.support.auto_pick(m,0,m.support.offers)
			m.support.finish_pick(m)
			assert(m.progression.active)
			m.progression.cpu_shop(m,0)
			m.progression.finish(m)
			assert(not m.progression.active)
			if m.boss>=0: bosses += 1
			while not m.round_over:
				var owner: int = m.side
				var move: Dictionary = m.best_move(owner)
				if move.indices.is_empty(): assert(m.draw_one(owner))
				else:
					var expected: Dictionary = m.evaluate(owner,move.indices)
					assert(m.play(owner,move.indices,move.target))
					if "RIFT" in m.banner or "RECRUITED" in m.banner or "PRISM" in m.banner: rule_plays += 1
					for event in m.announcement.support_events:
						if not str(event.text).begins_with("+") and event.amount>0 and not str(event.text).begins_with("x"): edition_triggers += 1
				var cards: int = m.stock.size()+m.hands[0].size()+m.hands[1].size()+m.discarded.size()
				for meld in m.melds: cards += meld.ids.size()
				assert(cards==69 and m.progression.credits[0]>=0 and m.progression.credits[1]>=0)
			assert(m.turns==[10,10])
			for owner in 2:
				assert(m.support.slots[owner].size()<=mini(5,m.round_number))
			if not m.finished: m.choose_upgrade(m.random.randi_range(0,2))
		assert(m.round_history.size()==5 and m.progression.funded_round==5)
		for owner in 2:
			var total := 0
			for row in m.round_history: total += row.points[owner]
			assert(total==m.scores[owner])
			total_points[owner] += total
		victories[m.result_winner if m.result_winner>=0 else 2] += 1
		if (game+1)%20==0: print("Completed ",game+1," matches")
	var report := {"matches":100,"rounds":500,"turns":10000,"wins":victories,"points":total_points,"boss_rounds":bosses,"edition_triggers":edition_triggers,"rule_joker_plays":rule_plays,"policy":"Same greedy scoring and shop policy for both sides; random player route choice; no profile writes"}
	var file := FileAccess.open("res://reports/progression-100-matches.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	assert(bosses==200)
	print("PASS: ",JSON.stringify(report))
	quit()
