extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = load("res://scripts/main.gd").new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 var m = g.hell_meld
 m.start(g)
 var small := -1
 var large := -1
 for monster in m.POOL:
  if m.card_data(monster).cost<=2: small = monster
  else: large = monster
 for owner in 2:
  for id in range(275,280):
   m.support.reset()
   m.support.slots[owner] = [id]
   m.round_scores[owner] = 0
   m.round_scores[1-owner] = 100
   m.support.stats[owner].last = "run"
   var result: Dictionary = m.support.score(m,owner,[small,small,large],{"gain":20,"kind":"set"},true)
   assert(result.bonus==[10,13,15,18,22][id-275])
   assert(m.support.score(m,owner,[small,large],{"gain":10,"kind":"set"},true).bonus==0)
   assert(m.support.score(m,owner,[large,large],{"gain":10,"kind":"set"},true).bonus==0)
   for event in result.events: assert(event.id==id)
   assert(m.support.has(owner,275))
 assert(m.support.BASE_IDS.has(275))
 assert(not m.support.BASE_IDS.has(276))
 m.run.enabled = false
 print("PASS: Farmer Caco and four variants, both owners, trigger boundaries and event identity")
 quit()
