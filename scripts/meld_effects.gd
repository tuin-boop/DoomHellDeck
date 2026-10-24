extends RefCounted
var voxels: Array = []
func _init() -> void:
	voxels = JSON.parse_string(FileAccess.get_file_as_string("res://assets/gibs/voxels.json"))
func gain_shown(m) -> float:
	if m.announcement.is_empty(): return 0.0
	var a: Dictionary = m.announcement
	var value: float = (a.gain-a.get("support_bonus",0))*smoothstep(0,1,clampf((m.banner_age-0.97)/0.65,0,1))
	var events: Array = a.get("support_events",[])
	for i in events.size():
		var time: float = m.banner_age-1.7-i*m.JOKER_BEAT
		if time<0: break
		var before: float = a.gain-a.get("support_bonus",0) if i==0 else events[i-1].get("total",value)
		value = lerpf(before,float(events[i].get("total",before)),smoothstep(0,1,clampf(time/0.65,0,1)))
	return value
func round_values(m) -> Array:
	var values: Array = [float(m.round_scores[0]),float(m.round_scores[1])]
	if not m.announcement.is_empty() and m.banner_age<m.reveal_duration():
		values[m.announcement.owner] -= m.announcement.gain-gain_shown(m)
	return values

func bar_share(values: Array, owner: int) -> float:
	# Both bars share the current round's combined score, so either player's
	# scoring changes both fills instead of pinning the leader near full.
	var total := maxf(0,float(values[0]))+maxf(0,float(values[1]))
	return maxf(0,float(values[owner]))/total if total>0 else 0.0

func draw(g,m) -> void:
	var values: Array = round_values(m)
	for owner in 2:
		var x := 18 if owner==0 else 1325
		var box := Rect2(x,570,98,260)
		g.draw_rect(box,Color("190c10"))
		g.draw_rect(box,Color("a44736"),false,2)
		m.centered_at(g,"YOU" if owner==0 else "CPU",Vector2(x+49,594),18,g.INK)
		m.centered_at(g,str(roundi(values[owner])),Vector2(x+49,632),28,g.ORANGE)
		var h := 130*bar_share(values,owner)
		g.draw_rect(Rect2(x+32,650,34,130),Color("341417"))
		g.draw_rect(Rect2(x+32,780-h,34,h),Color("d72427"))
		g.draw_line(Vector2(x+32,780-h),Vector2(x+66,780-h),Color("ff9175"),3)
		m.centered_at(g,"ROUND",Vector2(x+49,809),12,g.MUTED)
		if m.turns[owner]==9 and values[owner]<=values[1-owner]:
			m.centered_at(g,"NEED +%d" % (int(values[1-owner]-values[owner])+1),Vector2(x+49,853),12,Color(1,0.3+0.2*sin(g.clock*6),0.2))
	if m.announcement.is_empty(): return
	var a: Dictionary = m.announcement
	var t: float = m.banner_age-0.72
	if t<0 or m.banner_age>=m.reveal_duration(): return
	var strength := clampf(float(a.gain)/80,0.3,1.5)
	var types: Array = []
	for id in a.get("ids",[]):
		var kind: String = m.card_data(id).type
		if not types.has(kind): types.append(kind)
	if t<1.5:
		var fade := 1-t/1.5
		if types.has("FIRE"):
			for scar in 8: g.draw_circle(Vector2(600+scar*34,460+sin(scar*2.3)*25),20,Color(0.12,0.025,0.01,fade*0.65))
		for i in int(18*strength):
			var angle := i*2.399
			var pos := Vector2(720,430)+Vector2(cos(angle)*1.7,sin(angle))*t*(130+i%5*35)
			if types.has("FIRE"):
				g.draw_circle(pos+Vector2(0,-t*80),3+i%4,Color(1,0.25+0.08*(i%5),0.02,fade))
			if types.has("ENERGY"):
				g.draw_polyline(PackedVector2Array([pos,pos+Vector2(12,-15),pos+Vector2(5,-23),pos+Vector2(24,-32)]),Color(0.3,0.8,1,fade),2)
			if not types.has("FIRE") and not types.has("ENERGY"): g.draw_rect(Rect2(pos,Vector2(4,4)),Color(1,0.7,0.2,fade))
		if types.has("ROCKET"): g.draw_arc(Vector2(720,430),40+t*230,0,TAU,64,Color(1,0.5,0.1,fade),5*fade)
		if a.kind=="team":
			for i in mini(3,a.get("ids",[]).size()): m.draw_card(g,a.ids[i],Vector2(540+i*180,470-15*sin(t*3)),Vector2(100,140))
		if a.get("overtake",false):
			g.draw_arc(Vector2(720,430),60+t*160,0,TAU,48,Color(1,0.85,0.25,fade),4)
			m.centered_at(g,"LEAD TAKEN!",Vector2(720,705),24,Color(1,0.85,0.25,fade))
	if g.gibs_enabled and a.get("gibs",false) and t<1.9:
		for i in 6:
			var pos := Vector2(720,440)+Vector2((i-2.5)*90*t,-220*t+180*t*t)
			var angle := t*(i%3+2)
			var points: Array = voxels[i]
			for point in points:
				var px: float = point[0]*cos(angle)-point[1]*sin(angle)
				var py: float = point[2]+(point[0]*sin(angle)+point[1]*cos(angle))*0.35
				g.draw_rect(Rect2(pos+Vector2(px,py)*2,Vector2(2.5,2.5)),Color(point[3]/255.0,point[4]/255.0,point[5]/255.0,clampf((1.9-t)/0.4,0,1)))
	var events: Array = a.get("support_events",[])
	var jt: float = m.banner_age-1.7
	if jt>=0 and jt<events.size()*m.JOKER_BEAT:
		var index := int(jt/m.JOKER_BEAT)
		var phase: float = fmod(jt,m.JOKER_BEAT)/m.JOKER_BEAT
		var start := Vector2(720,550)
		var end := Vector2(67 if a.owner==0 else 1374,630)
		var nodes := PackedVector2Array()
		for i in 20:
			var f := i/19.0
			nodes.append(start.lerp(end,f)+Vector2(0,sin(f*PI)*-90+sin(f*30+g.clock*15)*4))
		g.draw_polyline(nodes,Color(1,0.72,0.2,0.5),3)
		var p: Vector2 = start.lerp(end,phase)+Vector2(0,-sin(phase*PI)*90)
		g.draw_circle(p,7,Color("ffe594"))
		m.centered_at(g,events[index].text,p+Vector2(0,-20),17,Color("ffe594"))
func draw_tally(g,m) -> void:
	if m.round_award_owner<0: return
	var winner: int = m.round_award_owner
	var t: float = m.result_age
	var totals: Array = m.scores.duplicate()
	totals[winner] -= 30
	var added := roundi(30*smoothstep(0,1,clampf((t-0.65)/0.9,0,1)))
	totals[winner] += added
	m.centered_at(g,"ROUND POINTS   YOU %d  /  CPU %d" % m.round_scores,Vector2(975,450),18,g.INK)
	if t<2.8: m.centered_at(g,("YOU" if winner==0 else "CPU")+" +%d ROUND WIN" % added,Vector2(975,295),26+int(12*maxf(0,1-absf(t-1.55)/0.25)),Color("ffdb79"))
