extends SceneTree
const Game = preload("res://scripts/main.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var g = Game.new()
 root.add_child(g)
 AudioServer.set_bus_mute(0,true)
 await process_frame
 g.set_process(false)
 g.ui_help.set_process(false)
 var sections: Array = g.hell_meld.support.tooltip_sections(13,-1,7)
 assert(sections.size()==3)
 assert(sections[2].text=="TOTAL: +16 points")
 assert(g.hell_meld.support.tooltip_sections(3,-1,0).size()==1)
 g.ui_help.title = "REVENANT BOXER"
 g.ui_help.body = "rich"
 g.ui_help.sections = sections
 g.ui_help.age = 1.0
 g.ui_help.queue_redraw()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://captures/boxer-frozen-tooltip.png")
 print("PASS: concise tooltip sections, Frozen total, no-upgrade tooltip")
 g.queue_free()
 await process_frame
 quit()
