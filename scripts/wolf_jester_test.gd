extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 var m = g.hell_meld
 m.profile.path = "user://wolf-test-profile.cfg"
 m.run.path = "user://wolf-test-run.cfg"
 m.start(g)
 for owner in 2:
  for id in range(260,265):
   m.support.reset()
   m.support.slots[owner] = [id]
   m.support.editions[owner][id] = 2
   m.round_scores[owner] = 0
   m.round_scores[1-owner] = 100
   m.support.stats[owner].last = "run"
   var result: Dictionary = m.support.score(m,owner,[1,1,1],{"gain":20,"kind":"set"},true)
   assert(result.bonus==[19,22,24,27,31][id-260])
   assert(m.support.score(m,owner,[1,1],{"gain":10,"kind":"set"},true).bonus==0)
   for event in result.events: assert(event.id==id)
   assert(m.support.has(owner,260))
 assert(m.support.tooltip_sections(260,-1,0).size()==1)
 m.support.pending = false
 m.progression.open_shop(m)
 m.progression.credits[0] = 30
 m.progression.offers = [{"id":260,"edition":0,"price":7,"sold":false},{"id":262,"edition":0,"price":12,"sold":false},{"id":264,"edition":0,"price":18,"sold":false}]
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/wolf-jester-preview.png")
 m.run.enabled = false
 print("PASS: Wolf Jester, four variants, both owners, inactive triggers, Golden upgrade, event identity and rendering")
 quit()
