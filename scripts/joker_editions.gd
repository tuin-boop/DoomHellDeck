extends RefCounted
# Editions are independent, small additive bonuses. No gameplay RNG during drawing.
const DATA := [
	["STANDARD","", "87998d"],
	["BLOODSTAINED","+3 on every extension.","e6454e"],
	["GOLDEN","+2 on every scoring play.","ffda68"],
	["PLASMA","+1 per card played, capped at +5.","6ce8ff"],
	["HOLOGRAPHIC","+4 when changing your previous scoring family.","ce8fff"],
	["HAUNTED","+4 while behind in round points before playing.","a6efce"],
	["INFERNAL","+2 per Fire monster played, capped at +6.","ff934f"],
	["FROZEN","+4 when playing exactly two cards.","bbebff"],
	["VOID","+6 when playing four or more cards.","ba79ff"]
]
static func roll(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(1,DATA.size()-1) if rng.randf()<0.3 else 0
static func bonus(edition: int, c: Dictionary) -> int:
	match edition:
		1: return 3 if c.extension else 0
		2: return 2
		3: return mini(5,c.count)
		4: return 4 if c.changed else 0
		5: return 4 if c.behind else 0
		6: return mini(6,c.fire*2)
		7: return 4 if c.count==2 else 0
		8: return 6 if c.count>=4 else 0
	return 0
static func draw(g, bounds: Rect2, edition: int, time: float) -> void:
	if edition<=0 or edition>=DATA.size(): return
	var color := Color(DATA[edition][2])
	if edition==4: color = Color.from_hsv(fposmod(time*0.12,1),0.5,1)
	g.draw_rect(bounds.grow(-2),Color(color,0.6+0.3*sin(time*3)),false,2)
	g.draw_rect(Rect2(Vector2(bounds.position.x+5,bounds.end.y-51),Vector2(bounds.size.x-10,19)),Color("101619"))
	g.label_at(Vector2(bounds.position.x+8,bounds.end.y-37),DATA[edition][0],maxi(8,mini(13,int(bounds.size.x*0.063))),color)
	for i in 9:
		var x: float = bounds.position.x+8+fposmod(i*31.0,bounds.size.x-16)
		var y: float = bounds.position.y+48+fposmod(time*25+i*37,bounds.size.y-70)
		match edition:
			1:
				var length := 3+fposmod(time*8+i*3,14)
				g.draw_line(Vector2(x,bounds.end.y-32),Vector2(x,bounds.end.y-32+length),Color(color,0.8),2)
			2:
				var alpha := maxf(0,sin(time*3+i))
				g.draw_line(Vector2(x-3,y),Vector2(x+3,y),Color(color,alpha),1)
				g.draw_line(Vector2(x,y-3),Vector2(x,y+3),Color(color,alpha),1)
			3:
				g.draw_polyline(PackedVector2Array([Vector2(bounds.position.x+3,y),Vector2(bounds.position.x+9,y+5),Vector2(bounds.position.x+3,y+12)]),Color(color,0.7),2)
			4: g.draw_line(Vector2(bounds.position.x+5,y),Vector2(bounds.end.x-5,y),Color(color,0.12),3)
			5: g.draw_circle(Vector2(x,y),3+sin(time*2+i)*2,Color(color,0.18))
			6: g.draw_rect(Rect2(x,bounds.end.y-10-fposmod(time*35+i*17,bounds.size.y-55),2,5),Color(color,0.6))
			7:
				g.draw_line(Vector2(x,y-3),Vector2(x,y+3),Color(color,0.5),1)
				g.draw_line(Vector2(x-3,y),Vector2(x+3,y),Color(color,0.5),1)
			8:
				var angle: float = time*0.6+i*TAU/9
				var p := bounds.get_center()+Vector2(cos(angle)*bounds.size.x*0.43,sin(angle)*bounds.size.y*0.43)
				g.draw_circle(p,2,Color(color,0.8))
