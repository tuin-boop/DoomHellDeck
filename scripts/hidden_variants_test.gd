extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
 var m = Meld.new()
 m.next_round()
 var j = m.support
 assert(j.DATA.size()==260)
 assert(j.BASE_IDS.size()==52)
 for base in j.BASE_IDS:
  var tiers := []
  for id in j.VARIANT_BASE:
   if j.base_id(id)==base: tiers.append(j.VARIANT_TIER[id])
  tiers.sort()
  assert(tiers==[1,2,3,4])
 for owner in 2:
  for id in range(58,260):
   j.reset()
   j.slots[owner] = [id]
   var base: int = j.base_id(id)
   assert(j.has(owner,base))
   m.round_scores[owner] = 0
   m.round_scores[1-owner] = 100
   m.hands[owner] = [0,0,1,2,8]
   m.turns[owner] = 9
   m.melds = [{"starter":1-owner}]
   j.stats[owner].last = "run"
   j.stats[owner].barrel = 2
   j.stats[owner].sleep = 8
   j.stats[owner].campfire_ready = true
   j.stats[owner].edition_draw_ready = true
   var c := {"gain":10,"kind":"set","name":"test"}
   var plain: Dictionary = j.score(m,owner,[0,0],c,true)
   j.editions[owner][id] = 2
   var upgraded: Dictionary = j.score(m,owner,[0,0],c,true)
   assert(upgraded.gain>=plain.gain)
   j.score(m,owner,[0,0],c,true,true)
   for event in plain.events: assert(event.id==id)
   j.on_draw(owner)
   j.progress(owner,id)
   j.tooltip_sections(id,owner,2)
 # A trigger is required, and impossible generic conditions are adapted.
 assert(j.variant_bonus(208,{"extension":false})==3)
 j.reset()
 j.slots[0] = [145] # Mythic Barrel, two remaining plays until explosion.
 j.stats[0].barrel = 0
 var first: Dictionary = j.score(m,0,[0,0,0],{"gain":10,"kind":"set"},false,true)
 assert(first.bonus==0)
 j.score(m,0,[0,0,0],{"gain":10,"kind":"set"},false,true)
 assert(j.score(m,0,[0,0,0],{"gain":10,"kind":"set"},false,true).bonus==32)
 j.reset()
 m.run.enabled = true
 m.round_number = 2
 var observed := {}
 for stage in [1,2,4,10,20]:
  m.run.stage = stage
  m.random.seed = 9876
  var count := 0
  for i in 2000:
   for id in j.draft_offers(m,0):
    assert(j.available(m,id))
    if j.VARIANT_BASE.has(id): count += 1
  observed[stage] = count
 assert(observed[1]==0)
 assert(observed[2]<observed[4] and observed[4]<observed[10] and observed[10]<observed[20])
 print("PASS: 52 bases, 208 hidden variants, both owners, editions, charge triggers. Variant offers per 6000: ",observed)
 quit()
