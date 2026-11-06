extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 for mode in 2:
  g.frontend.open_tutorial(g,mode,false)
  var count: int = g.frontend.LESSONS[mode].size()
  assert(count==(3 if mode==0 else 9))
  for page in count:
   assert(g.frontend.tutorial_page==page)
   g.frontend.tutorial_started_at = g.clock-2.7
   await process_frame
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://captures/tutorial-%d-%d.png" % [mode,page])
   g.frontend.tutorial_click(g,Vector2(1050,740))
  assert(g.modal=="home")
 print("PASS: both tutorials, all pages render, navigation and final Done")
 g.queue_free()
 await process_frame
 quit()
