extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var records: Array = []
	var wins := [0,0]
	var round_totals := [0,0,0,0,0]
	var joker_stats: Array = []
	for data in Meld.new().support.DATA: joker_stats.append({"name":data[1],"held_matches":0,"wins":0})
	for match_id in 500:
		var m = Meld.new()
		m.random.seed = 2026102500+match_id
		m.match_powers = true
		m.passive_joker = [match_id%3,match_id%3]
		for round_index in 5:
			m.round_number = round_index+1
			m.next_round()
			m.support.offer(m)
			assert(m.support.pending and m.support.offers.size()==3)
			m.support.chosen = m.support.auto_pick(m,0,m.support.offers)
			m.support.finish_pick(m)
			assert(m.support.slots[0].size()==round_index+1 and m.support.slots[1].size()==round_index+1)
			while not m.round_over:
				var owner: int = m.side
				var move: Dictionary = m.best_move(owner)
				if move.indices.is_empty(): assert(m.draw_one(owner))
				else: assert(m.play(owner,move.indices,move.target))
				var count: int = m.stock.size()+m.hands[0].size()+m.hands[1].size()+m.discarded.size()
				for meld in m.melds: count += meld.ids.size()
				assert(count==69)
			assert(m.turns==[10,10])
			round_totals[round_index] += m.round_scores[0]+m.round_scores[1]
			if round_index<4:
				for owner in 2:
					var family: String = m.upgrade_offers[0]
					for candidate in m.upgrade_offers:
						if m.family_plays[owner].get(candidate,0)>m.family_plays[owner].get(family,0): family = candidate
					m.upgrades[owner][family] = m.upgrades[owner].get(family,0)+1
		var winner: int = m.match_winner()
		if winner>=0: wins[winner] += 1
		for owner in 2:
			for id in m.support.slots[owner]:
				joker_stats[id].held_matches += 1
				joker_stats[id].wins += int(winner==owner)
		records.append({"seed":2026102500+match_id,"winner":winner,"points":m.scores,"rounds":m.rounds,"jokers":m.support.slots})
		if match_id%50==49: print("Completed ",match_id+1," / 500")
	var report := {"matches":500,"rounds":2500,"turns":50000,"wins":wins,"average_round_score_per_side":round_totals.map(func(x): return float(x)/1000),"method":"500 seeded games, both sides use the same hand-aware random draft policy and greedy best-score play; weighted Common/Uncommon/Rare three offers (8:4:1 per card), one new Joker each round, 1 to 5 slots; upgrades chosen by most-played available family. Joker win rates are observational, not isolated causal strength.","jokers":joker_stats,"records":records}
	var file := FileAccess.open("res://reports/joker-progression-500.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	file.close()
	print("PASS: 500 matches / 2500 rounds / 50000 turns; 1-to-5 progression, card conservation, turn limits. Wins: ",wins)
	print("Average round scores: ",report.average_round_score_per_side)
	quit()
