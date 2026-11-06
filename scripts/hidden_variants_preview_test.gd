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
 m.run.path = "user://hidden-variant-test.cfg"
 m.run.stage = 8
 m.support.slots[0] = [145,259]
 m.support.editions[0] = {145:2}
 m.support.stats[0].barrel = 2
 m.run.save_run(m)
 assert(m.run.resume(g,m))
 assert(m.support.slots[0]==[145,259] and m.support.stats[0].barrel==2)
 assert(m.support.edition_of(0,145)==2)
 m.support.pending = false
 m.progression.open_shop(m)
 m.progression.credits[0] = 20
 m.progression.offers = [{"id":145,"edition":0,"price":14,"sold":false},{"id":259,"edition":0,"price":14,"sold":false},{"id":109,"edition":0,"price":14,"sold":false}]
 m.progression.preview_pack = -1
 m.progression.preview_tier = 1
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/hidden-variants-preview.png")
 m.support.library = true
 m.support.page = 5
 m.progression.active = false
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/base-only-collection.png")
 m.run.enabled = false
 DirAccess.remove_absolute(ProjectSettings.globalize_path(m.run.path))
 print("PASS: pack artwork preview rendered")
 quit()

