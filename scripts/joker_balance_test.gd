extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const BUILDS = [[0,20,25],[1,4,10],[2,12,29],[3,8,18],[5,19,28],[6,15,24],[7,21,22],[9,14,17],[11,16,26],[13,23,27],[5,30,19],[26,31,25],[32,13,27],[33,21,0],[34,23,22]]
const NAMES = ["Steady points","Enhancements","Bullet business","Draw and luck","Combo variety","Wild apocalypse","Extensions","Boss finish","Fire growth","Pairs contract","Banjo marches","Party feast","Propeller pairs","Carmack optimization","Keen comeback"]
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var results: Array = []
	var records: Array = []
	for i in BUILDS.size(): results.append({"build":NAMES[i],"jokers":BUILDS[i],"games":0,"wins":0,"draws":0,"rounds_won":0,"points":0,"joker_points":0,"scoring_plays":0})
	var pairs: Array = []
	# Circle scheduling spreads the partial final cycle across builds fairly.
	var wheel: Array = range(BUILDS.size())
	if wheel.size()%2==1: wheel.append(-1)
	for rotation in wheel.size()-1:
		for i in int(wheel.size()/2):
			var a: int = wheel[i]
			var b: int = wheel[wheel.size()-1-i]
			if a>=0 and b>=0: pairs.append([a,b])
		wheel.insert(1,wheel.pop_back())
	var schedule: Array = pairs.duplicate(true)
	pairs.clear()
	for i in 250: pairs.append(schedule[i%schedule.size()])
	for pair_index in pairs.size():
		for swap in 2:
			var seats: Array = pairs[pair_index].duplicate()
			if swap==1: seats.reverse()
			var m = Meld.new()
			m.random.seed = 2026102400+pair_index
			m.match_powers = true
			m.support.slots = [BUILDS[seats[0]].duplicate(),BUILDS[seats[1]].duplicate()]
			m.passive_joker = [pair_index%3,pair_index%3]
			for round_index in 5:
				m.round_number = round_index+1
				m.next_round()
				while not m.round_over:
					var owner: int = m.side
					var move: Dictionary = m.best_move(owner)
					if move.indices.is_empty(): assert(m.draw_one(owner))
					else:
						assert(m.play(owner,move.indices,move.target))
						results[seats[owner]].joker_points += m.announcement.support_bonus
						results[seats[owner]].scoring_plays += 1
					var count: int = m.stock.size()+m.hands[0].size()+m.hands[1].size()+m.discarded.size()
					for meld in m.melds: count += meld.ids.size()
					assert(count==69)
				assert(m.turns==[10,10])
				if round_index<4:
					for owner in 2:
						var family: String = m.upgrade_offers[0]
						for candidate in m.upgrade_offers:
							if m.family_plays[owner].get(candidate,0)>m.family_plays[owner].get(family,0): family = candidate
						m.upgrades[owner][family] = m.upgrades[owner].get(family,0)+1
			var winner := -1
			if m.rounds[0]!=m.rounds[1]: winner = 0 if m.rounds[0]>m.rounds[1] else 1
			elif m.scores[0]!=m.scores[1]: winner = 0 if m.scores[0]>m.scores[1] else 1
			for owner in 2:
				var entry: Dictionary = results[seats[owner]]
				entry.games += 1
				entry.wins += int(winner==owner)
				entry.draws += int(winner==-1)
				entry.rounds_won += m.rounds[owner]
				entry.points += m.scores[owner]
			records.append({"pair":pair_index,"swap":swap,"builds":seats,"winner":winner,"rounds":m.rounds,"points":m.scores})
	var file := FileAccess.open("res://reports/joker-balance-500.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"matches":500,"rounds":2500,"method":"250 paired-seed matchups with swapped seats; fixed three-Joker builds; greedy best-score AI, draws only when stuck; upgrades chosen by most-played available family; no drafting.","builds":results,"matches_detail":records},"  "))
	file.close()
	for entry in results: print(entry.build,": ",entry.wins,"/",entry.games," wins; Joker bonus/play ",snappedf(float(entry.joker_points)/maxi(1,entry.scoring_plays),0.1))
	print("PASS: 500 complete matches / 2500 rounds / 50000 turns; card conservation and turn limits")
	quit()

