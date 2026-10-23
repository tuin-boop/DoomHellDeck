extends RefCounted

# Signed side tilt for immediate-mode cards. Mouse height never changes the pose.
static func pose(center: Vector2, pointer_x: float, hovered: bool, resting_angle := 0.0) -> Transform2D:
	var yaw := clampf(pointer_x,-0.5,0.5) if hovered else 0.0
	var side := Transform2D(Vector2(1.0-absf(yaw)*0.36,yaw*0.22),Vector2(0,1),Vector2.ZERO)
	return Transform2D(resting_angle,center)*side
