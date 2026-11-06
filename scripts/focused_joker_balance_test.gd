extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const JOKERS := [2,11,14,21,22,28,30,44,52,56]
var rng := RandomNumberGenerator.new()
func _initialize() -> void: run.call_deferred()
func moves(m,owner: int,indices: Array,first: int,out: Array) -> void:
 if not indices.is_empty():
  var c: Dictionary = m.evaluate(owner,indices)
  if not c.is_empty(): out.append({"indices":indices.duplicate(),"combo":c})
 if indices.size()==6: return
 for i in range(first,m.hands[owner].size()): moves(m,owner,indices+[i],i+1,out)
func route_value(m,index: int,joker: int,history: Dictionary) -> float:
 var family: String = m.upgrade_offers[index]
 var route: Dictionary = m.route_offers[index]
 var value := float(history.get(family,0))*5
 var preferred: Array = {2:[5,6],11:[0],14:[2],21:[1,4],22:[5,6],28:[3],30:[3],44:[0],52:[0],56:[1,4]}.get(joker,[])
 if route.modifier in preferred: value += 15
 if route.relic==0 and joker in [21,56]: value += 8
 if route.relic==2 and joker==44: value += 8
 return value
func run() -> void:
 var report := {"rounds":0,"focused_wins":0,"simple_wins":0,"ties":0,"jokers":[],"method":"20 five-round matches, ten Jokers, sides swapped per Joker. Both sides hold the same Joker with Golden. No shops or extra Jokers. Focused policy maximizes immediate total plus 0.5x Joker bonus and chooses synergistic routes/upgrades; simple policy uniformly chooses a legal play, random routes/upgrades. Draw only with no legal play. No CPU pressure. Not a search for optimal play or an isolated Joker-strength comparison."}
 for joker in JOKERS:
  var row := {"name":"","wins":0,"losses":0,"ties":0,"points":[0,0],"joker_points":[0,0],"plays":[0,0]}
  for seat in 2:
   var m = Meld.new()
   m.random.seed = 2026102900+joker
   rng.seed = 2026103000+joker
   m.match_powers = true
   m.run.enabled = false
   m.support.slots = [[joker],[joker]]
   m.support.editions = [{joker:2},{joker:2}]
   var history := [{},{}]
   row.name = m.support.DATA[joker][1]
   for round_index in 5:
    m.round_number = round_index+1
    m.next_round()
    m.support.pending = false
    m.progression.active = false
    while not m.round_over:
     var owner: int = m.side
     var choices: Array = []
     moves(m,owner,[],0,choices)
     if choices.is_empty(): assert(m.draw_one(owner))
     else:
      var pick: Dictionary = choices[rng.randi_range(0,choices.size()-1)]
      if owner==seat:
       var value := -INF
       for choice in choices:
        var v: float = choice.combo.gain+0.5*choice.combo.support_bonus-0.2*choice.indices.size()
        if v>value: value = v; pick = choice
      var family: String = pick.combo.kind
      history[owner][family] = int(history[owner].get(family,0))+1
      assert(m.play(owner,pick.indices,-1 if m.melds.is_empty() else 0))
      var policy := 0 if owner==seat else 1
      row.plays[policy] += 1
      for event in m.announcement.support_events: row.joker_points[policy] += event.get("amount",0)
    report.rounds += 1
    row.points[0] += m.round_scores[seat]
    row.points[1] += m.round_scores[1-seat]
    if m.result_winner==seat: row.wins += 1; report.focused_wins += 1
    elif m.result_winner==1-seat: row.losses += 1; report.simple_wins += 1
    else: row.ties += 1; report.ties += 1
    if round_index<4:
     m.upgrade_offers = ["set","run","team"] if m.upgrade_offers.is_empty() else m.upgrade_offers
     m.make_routes()
     var focused_pick := 0
     for i in m.upgrade_offers.size():
      if route_value(m,i,joker,history[seat])>route_value(m,focused_pick,joker,history[seat]): focused_pick = i
     var simple_pick := rng.randi_range(0,m.upgrade_offers.size()-1)
     var controller := round_index%2
     m.next_route = m.route_offers[focused_pick if controller==seat else simple_pick].duplicate()
     for owner in 2:
      var family: String = m.upgrade_offers[focused_pick if owner==seat else simple_pick]
      m.upgrades[owner][family] = int(m.upgrades[owner].get(family,0))+1
  report.jokers.append(row)
 assert(report.rounds==100)
 FileAccess.open("res://reports/focused-jokers-100-rounds.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print(JSON.stringify(report))
 quit()
