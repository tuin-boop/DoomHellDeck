extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 var m = g.hell_meld
 m.profile.path = "user://pack-art-test-profile.cfg"
 m.run.path = "user://pack-art-test-run.cfg"
 m.start(g)
 for owner in 2:
  m.support.slots[owner] = [57]
  m.support.editions[owner] = {57:2}
  m.round_scores[owner] = 0
  m.round_scores[1-owner] = 50
  assert(m.support.score(m,owner,[0],{"gain":5,"kind":"set"},false).bonus==11)
  assert(m.support.score(m,owner,[0],{"gain":5,"kind":"set"},true).bonus==0)
  m.round_scores[owner] = 50
  assert(m.support.score(m,owner,[0],{"gain":5,"kind":"set"},false).bonus==0)
 var animation = load("res://assets/jokers/helmet_doomguy.tres")
 assert(animation.frames==5)
 assert(is_equal_approx(animation.get_frame_duration(0),0.9))
 m.support.pending = false
 m.progression.open_shop(m)
 m.progression.credits[0] = 20
 m.progression.offers = [{"id":57,"edition":0,"price":14,"sold":false},{"id":53,"edition":0,"price":14,"sold":false},{"id":55,"edition":0,"price":14,"sold":false}]
 m.progression.preview_pack = -1
 m.progression.preview_tier = 1
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/helmet-doomguy-preview.png")
 m.run.enabled = false
 print("PASS: pack artwork preview rendered")
 quit()

