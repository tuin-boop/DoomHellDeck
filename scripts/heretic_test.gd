extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 var m = g.hell_meld
 m.profile.path = "user://heretic-test-profile.cfg"
 m.run.path = "user://heretic-test-run.cfg"
 m.start(g)
 var fire := -1
 var energy := -1
 for monster in m.POOL:
  if m.card_data(monster).type=="FIRE": fire = monster
  if m.card_data(monster).type=="ENERGY": energy = monster
 assert(fire>=0 and energy>=0)
 for owner in 2:
  for id in range(270,275):
   m.support.reset()
   m.support.slots[owner] = [id]
   m.support.editions[owner][id] = 2
   m.round_scores[owner] = 0
   m.round_scores[1-owner] = 100
   m.support.stats[owner].last = "run"
   var result: Dictionary = m.support.score(m,owner,[fire,energy,fire],{"gain":20,"kind":"set"},true)
   assert(result.bonus==[16,19,21,24,28][id-270])
   assert(m.support.score(m,owner,[1,1],{"gain":10,"kind":"set"},true).bonus==0)
   assert(m.support.score(m,owner,[fire,fire],{"gain":10,"kind":"set"},true).bonus==0)
   assert(m.support.score(m,owner,[energy,energy],{"gain":10,"kind":"set"},true).bonus==0)
   for event in result.events: assert(event.id==id)
   assert(m.support.has(owner,270))
 assert(m.support.tooltip_sections(270,-1,0).size()==1)
 m.support.pending = false
 m.progression.open_shop(m)
 m.progression.credits[0] = 30
 m.progression.offers = [{"id":270,"edition":0,"price":7,"sold":false},{"id":272,"edition":0,"price":12,"sold":false},{"id":274,"edition":0,"price":18,"sold":false}]
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/heretic-preview.png")
 m.run.enabled = false
 print("PASS: The Heretic, four variants, both owners, inactive triggers, Golden upgrade, event identity and rendering")
 quit()
