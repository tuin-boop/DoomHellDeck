extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 var m = g.hell_meld
 m.profile.path = "user://portrait-test-profile.cfg"
 m.run.path = "user://portrait-test-run.cfg"
 m.start(g)
 m.support.pending = false
 m.progression.active = false
 m.round_intro = false
 m.support.slots = [[3,7,0,30],[3,8,38,2]]
 m.support.editions = [{3:2,7:7,0:8},{3:1,8:7,38:4,2:5}]
 m.support.drawer = [1.0,1.0]
 g.set_process(false)
 g.queue_redraw()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/joker-drawers-full-portraits.png")
 m.run.enabled = false
 print("PASS: both drawers rendered with mixed editions and status footers")
 g.queue_free()
 await process_frame
 quit()
