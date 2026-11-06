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
  for id in range(285,290):
   m.support.reset()
   m.support.slots[owner] = [id]
   m.round_scores[owner] = 0
   m.round_scores[1-owner] = 100
   m.support.stats[owner].last = "run"
   var result: Dictionary = m.support.score(m,owner,[small,small,small],{"gain":20,"kind":"set"},true)
   assert(result.bonus==[12,15,17,20,24][id-285])
   for cards in [[small],[small,large],[small,small,large],[small,-1]]:
    assert(m.support.score(m,owner,cards,{"gain":10,"kind":"set"},true).bonus==0)
   assert(m.support.has(owner,285))
 assert(m.support.BASE_IDS.has(285))
 assert(not m.support.BASE_IDS.has(286))
 assert(m.support.DATA.size()==290)
 m.run.enabled = false
 print("PASS: Baby Doomguy, both owners, four variants and trigger boundaries")
 quit()
