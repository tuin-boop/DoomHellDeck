extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	var m = Meld.new()
	print("PARSED ",m.support.DATA.size())
	quit()
