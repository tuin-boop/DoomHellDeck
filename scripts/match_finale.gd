extends RefCounted
func duration(m) -> float: return 0.5+m.round_history.size()*2.0+0.8
func done(m) -> bool: return m.result_age>=duration(m)
func totals_at(m, time: float) -> Array:
	var totals := [0.0,0.0]
	for i in m.round_history.size():
		var progress := smoothstep(0,1,clampf((time-0.5-i*2.0)/1.25,0,1))
		for owner in 2: totals[owner] += m.round_history[i].points[owner]*progress
	return totals
func draw(g,m) -> void:
	g.ui_help.reset()
	g.draw_rect(Rect2(0,0,1440,940),Color(0.015,0.02,0.025,0.98))
	var ready := done(m)
	m.draw_result_frame(g,Rect2(460,65,930,820))
	var title := "HELLATRO / FINAL RECKONING"
	if ready: title = "YOU WON!" if m.result_winner==0 else ("YOU LOST!" if m.result_winner==1 else "DRAW")
	m.centered_at(g,title,Vector2(925,130),52 if ready else 30,g.ORANGE)
	m.centered_at(g,"HIGHEST TOTAL POINTS WINS / EQUAL TOTALS DRAW",Vector2(925,160),14,g.MUTED)
	var totals := totals_at(m,m.result_age)
	var ceiling := maxf(1,maxf(m.scores[0],m.scores[1]))
	for owner in 2:
		var x := 650+owner*410
		m.centered_at(g,"YOU" if owner==0 else "CPU",Vector2(x,210),24,g.INK)
		g.draw_rect(Rect2(x-75,250,150,240),Color("341417"))
		var h := 240*clampf(totals[owner]/ceiling,0,1)
		g.draw_rect(Rect2(x-75,490-h,150,h),Color("cf2528"))
		g.draw_line(Vector2(x-75,490-h),Vector2(x+75,490-h),Color("ffae82"),4)
		m.centered_at(g,str(roundi(totals[owner])),Vector2(x,535),36,g.ORANGE)
	for i in m.round_history.size():
		var t: float = m.result_age-0.5-i*2.0
		if t<0: continue
		var row: Dictionary = m.round_history[i]
		var y: int = 577+i*34
		g.label_at(Vector2(505,y),"ROUND %d" % (i+1),15,g.MUTED)
		for owner in 2:
			m.centered_at(g,"+%d%s" % [row.points[owner],"  WIN" if row.winner==owner else ""],Vector2(760+owner*410,y),17,Color("ffdb79") if row.winner==owner else g.INK)
		if g.gibs_enabled and t<1.7:
			for piece in 30:
				var origin := Vector2(650 if piece%2==0 else 1060,360)
				var direction := Vector2.from_angle(piece*2.39996+i*0.7)
				var speed := 180.0+(piece%7)*48.0
				var pos := origin+direction*speed*t+Vector2(0,140*t*t)
				var angle := t*(piece%3+2)
				for point in m.effects.voxels[piece%6]:
					var px: float = point[0]*cos(angle)-point[1]*sin(angle)
					var py: float = point[2]+0.3*(point[0]*sin(angle)+point[1]*cos(angle))
					g.draw_rect(Rect2(pos+Vector2(px,py)*2,Vector2(3,3)),Color(point[3]/255.0,point[4]/255.0,point[5]/255.0,clampf((1.7-t)/0.4,0,1)))
	if ready: draw_celebration(g,m,title)
	draw_collage(g,m)
	if ready:
		m.centered_at(g,"ROUNDS WON  %d : %d" % m.rounds,Vector2(925,770),21,g.INK)
		g.button(Rect2(550,800,340,55),"PLAY AGAIN")
		g.button(Rect2(960,800,340,55),"MAIN MENU")
	else:
		m.centered_at(g,"ROUND POINTS INCLUDE THE +30 WIN BONUS",Vector2(925,770),14,g.MUTED)
		g.button(Rect2(1120,820,220,40),"SKIP COUNT")

func draw_collage(g,m) -> void:
	# Two overlapping rows of cutout portraits rising from the bottom edge.
	for id in m.support.DATA.size():
		var columns: int = ceili(m.support.DATA.size()/2.0)
		var col: int = id%columns
		var row := int(id/columns)
		var arrival := smoothstep(0,1,clampf((m.result_age-id*0.025)/0.5,0,1))
		var path: String = "res://assets/jokers/"+m.support.DATA[id][0]+".png"
		if id==25 and (not m.support.art.has(id) or m.support.art[id]==null) and not g.art.textures.get("AMMO",[]).is_empty():
			m.support.art[id] = g.art.textures["AMMO"][0]
		if not m.support.art.has(id): m.support.art[id] = load(path) if ResourceLoader.exists(path) else null
		var texture = m.support.art[id]
		if texture==null: continue
		var size: Vector2 = texture.get_size()
		var scale: float = minf(150/size.x,155/size.y)
		var center := Vector2(35+col*(1360.0/(columns-1))+row*20,845+row*72+sin(id*2.4)*12+130*(1-arrival))
		g.draw_set_transform_matrix(Transform2D(sin(id*1.7)*0.16,center)*m.support.portrait_pose(id,g.clock,150))
		g.draw_texture_rect(texture,Rect2(-size*scale/2,size*scale),false,Color(1,1,1,arrival))
		g.draw_set_transform(Vector2.ZERO)

func draw_celebration(g,m,title: String) -> void:
	var t: float = m.result_age-duration(m)
	if t<6.0:
		var palette := [Color("ffdf65"),Color("ff6050"),Color("71d6ef"),Color("df8aff"),Color("eee4c9")]
		for i in 150:
			var delay := (i%13)*0.07
			var age := t-delay
			if age<0: continue
			var x := fposmod(i*97.0+sin(age*2+i)*45,1440)
			var y := -40+age*(120+i%9*18)
			var color: Color = palette[i%palette.size()]
			color.a = clampf((6-t)/1.2,0,1)
			g.draw_set_transform(Vector2(x,y),age*3+i)
			g.draw_rect(Rect2(-4,-2,8*maxf(0.2,absf(cos(age*5+i))),5),color)
		g.draw_set_transform(Vector2.ZERO)
	if t<2.4:
		var enter := 1-pow(1-clampf(t/0.25,0,1),3)
		var fade := clampf((2.4-t)/0.5,0,1)
		var tint := Color("ffe16e") if m.result_winner==0 else Color("ff6651")
		g.draw_rect(Rect2(150,340,1140,190),Color(0.02,0.025,0.03,0.96*fade))
		g.draw_line(Vector2(150,340),Vector2(1290,340),Color(tint,fade),4)
		g.draw_line(Vector2(150,530),Vector2(1290,530),Color(tint,fade),4)
		m.centered_at(g,title,Vector2(720,447),int(66+22*(1-enter)),Color(tint,fade))
		m.centered_at(g,"FINAL RESULT",Vector2(720,493),20,Color(1,0.9,0.8,fade))
