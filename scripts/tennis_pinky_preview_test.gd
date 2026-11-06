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
 m.support.pending = false
 m.progression.open_shop(m)
 m.progression.credits[0] = 20
 m.progression.offers = [{"id":56,"edition":0,"price":14,"sold":false},{"id":53,"edition":0,"price":14,"sold":false},{"id":55,"edition":0,"price":14,"sold":false}]
 m.progression.preview_pack = -1
 m.progression.preview_tier = 1
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/tennis-pinky-preview.png")
 m.run.enabled = false
 print("PASS: pack artwork preview rendered")
 quit()
