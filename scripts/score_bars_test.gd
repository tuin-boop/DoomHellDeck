extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
func _initialize() -> void:
	var m = Meld.new()
	m.round_number = 3
	m.scores = [800,400]
	m.round_scores = [20,40]
	var fx = m.effects
	assert(fx.round_values(m)==[20.0,40.0],"Earlier rounds must not affect bars")
	assert(is_equal_approx(fx.bar_share([20,40],0),1.0/3))
	assert(is_equal_approx(fx.bar_share([20,40],1),2.0/3))
	assert(fx.bar_share([40,60],0)<fx.bar_share([40,20],0),"CPU scoring must shrink your share")
	assert(fx.bar_share([40,40],0)==0.5 and fx.bar_share([40,40],1)==0.5)
	assert(fx.bar_share([70,40],0)>fx.bar_share([70,40],1))
	assert(fx.bar_share([0,0],0)==0 and fx.bar_share([0,0],1)==0)
	m.announcement = {"owner":0,"gain":50,"support_bonus":0}
	m.round_scores = [70,40]
	m.banner_age = 0
	assert(fx.round_values(m)==[20.0,40.0])
	m.banner_age = 99
	assert(fx.round_values(m)==[70.0,40.0])
	print("PASS: current-round adaptive score shares, lead changes, ties, zero and reveal timing")
	quit()
