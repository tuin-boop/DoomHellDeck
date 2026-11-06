extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
 var m = Meld.new()
 m.next_round()
 var c := {"gain":10,"kind":"set"}
 for owner in 2:
  m.support.reset()
  m.support.slots[owner] = [50]
  assert(m.support.score(m,owner,[1],c,true).bonus==12)
  assert(m.support.score(m,owner,[1],c,false).bonus==0)
  m.support.slots[owner] = [51]
  m.hands[owner] = [1,1,1]
  assert(m.support.score(m,owner,[1,1,1],c,false).bonus==30)
  m.support.slots[owner] = [52]
  m.support.editions[owner] = {52:2}
  assert(m.support.score(m,owner,[0],c,false,true).bonus==0)
  assert(m.support.score(m,owner,[1],c,false,true).bonus==0)
  m.support.begin_round()
  assert(m.support.score(m,owner,[0],c,false).bonus==24)
  assert(m.support.score(m,owner,[0],c,false,true).bonus==24)
  m.support.slots[owner] = [53]
  assert(m.support.score(m,owner,[0],c,false,true).bonus==0)
  for i in 3:
   assert(m.support.score(m,owner,[0],c,true,true).bonus==(40 if i==2 else 0))
 var ctx := {"count":3,"types":3,"changed":false,"overtake":false}
 assert(m.support.fixed_bonus(54,ctx)==0)
 ctx.changed = true
 assert(m.support.fixed_bonus(54,ctx)==14)
 ctx.count = 4
 ctx.types = 4
 assert(m.support.fixed_bonus(55,ctx)==20)
 ctx.overtake = true
 assert(m.support.fixed_bonus(55,ctx)==30)
 m.run.enabled = true
 for stage in [1,2,3,4,8]:
  m.run.stage = stage
  assert(m.support.available(m,50)==(stage>=2))
  assert(m.support.available(m,51)==(stage>=4))
 assert(m.support.rarity(51)=="LEGENDARY")
 assert(m.progression.price(m,51,0)==14)
 print("PASS: variants, inactive triggers, both players, charge carry, Golden activation, stage gates and pricing")
 quit()
