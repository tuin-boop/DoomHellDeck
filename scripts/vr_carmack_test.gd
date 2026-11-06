extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 var m = g.hell_meld
 m.profile.path = "user://vr-carmack-test-profile.cfg"
 m.run.path = "user://vr-carmack-test-run.cfg"
 m.start(g)
 var energy := -1
 for monster in m.POOL:
  if m.card_data(monster).type=="ENERGY": energy = monster; break
 assert(energy>=0)
 for owner in 2:
  for id in range(265,270):
   m.support.reset()
   m.support.slots[owner] = [id]
   m.support.editions[owner][id] = 2
   m.round_scores[owner] = 0
   m.round_scores[1-owner] = 100
   m.support.stats[owner].last = "run"
   var result: Dictionary = m.support.score(m,owner,[energy,energy,energy],{"gain":20,"kind":"set"},true)
   assert(result.bonus==[16,19,21,24,28][id-265])
   assert(m.support.score(m,owner,[1,1],{"gain":10,"kind":"set"},true).bonus==0)
   m.support.stats[owner].last = "set"
   assert(m.support.score(m,owner,[energy],{"gain":10,"kind":"set"},true).bonus==0)
   m.support.stats[owner].last = ""
   assert(m.support.score(m,owner,[energy],{"gain":10,"kind":"set"},false).bonus==0)
   for event in result.events: assert(event.id==id)
   assert(m.support.has(owner,265))
 assert(m.support.tooltip_sections(265,-1,0).size()==1)
 m.support.pending = false
 m.progression.open_shop(m)
 m.progression.credits[0] = 30
 m.progression.offers = [{"id":265,"edition":0,"price":7,"sold":false},{"id":267,"edition":0,"price":12,"sold":false},{"id":269,"edition":0,"price":18,"sold":false}]
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/vr-carmack-preview.png")
 m.progression.active = false
 m.profile.ensure_loaded()
 for back in ["helmet_doomguy","carmack_code"]:
  assert(back in m.profile.unlocked)
  assert(ResourceLoader.exists(m.profile.entry_for(back).texture))
 m.profile.open = true
 m.profile.page = (m.profile.entries.size()-1)/5
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/new-helmet-carmack-backs.png")
 m.run.enabled = false
 print("PASS: VR Carmack and two card backs, four variants, both owners, inactive triggers, Golden upgrade, event identity and rendering")
 quit()
