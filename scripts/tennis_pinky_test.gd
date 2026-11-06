extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
 var m = Meld.new()
 m.next_round()
 var combo := {"gain":10,"kind":"set"}
 for owner in 2:
  m.support.reset()
  m.support.slots[owner] = [56]
  m.support.editions[owner] = {56:2}
  m.melds = [{"starter":1-owner}]
  assert(m.support.score(m,owner,[0],combo,true).bonus==13)
  assert(m.support.score(m,owner,[0,0],combo,true).bonus==0)
  assert(m.support.score(m,owner,[0],combo,false).bonus==0)
  m.melds = [{"starter":owner}]
  assert(m.support.score(m,owner,[0],combo,true).bonus==0)
 assert(m.support.available(m,56))
 assert(m.support.rarity(56)=="COMMON")
 print("PASS: Tennis Pinky both sides, Return Serve conditions and conditional Golden edition")
 quit()
