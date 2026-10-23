extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const IDS := [9,149,150,151,152,153,154]

static func is_weapon(id: int) -> bool:
	return Cards.DATA[id].get("targeted",false) or id==9

# The same hit schedule drives previews, AI scoring and live damage.
static func schedule(id: int, lane: int) -> Array:
	var data: Dictionary = Cards.DATA[id]
	var result: Array = []
	if id==9:
		for i in 4: result.append({"lane":i,"damage":data.board_damage})
		return result
	for shot in int(data.get("weapon_shots",1)): result.append({"lane":lane,"damage":data.atk})
	if data.get("weapon_splash",0)>0:
		for i in [lane-1,lane+1]:
			if i>=0 and i<4: result.append({"lane":i,"damage":data.weapon_splash})
	return result

static func preview(id: int, row: Array, lane: int) -> Dictionary:
	var copy: Array = row.duplicate(true)
	var originals: Array = copy.duplicate()
	var loss := [0,0,0,0]
	var kills := 0
	var shields := 0
	for shot in schedule(id,lane):
		var target: Dictionary = copy[shot.lane]
		if target.is_empty() or not is_same(target,originals[shot.lane]): continue
		if target.shield:
			target.shield = false
			shields += 1
			continue
		var before: int = target.hp
		Cards.receive_damage(target,shot.damage)
		loss[shot.lane] += before-maxi(0,target.hp)
		if target.hp<=0:
			kills += 1
			var data: Dictionary = Cards.DATA[target.id]
			copy[shot.lane] = Cards.unit(data.death_spawn,true) if data.has("death_spawn") else {}
	return {"row":copy,"loss":loss,"kills":kills,"shields":shields}

static func score(id: int, row: Array, lane: int) -> float:
	if id!=9 and (lane<0 or lane>=4 or row[lane].is_empty()): return -999.0
	var result := preview(id,row,lane)
	var value: float = result.shields*1.2-Cards.DATA[id].cost*1.25-0.8
	for i in 4:
		value += result.loss[i]*0.85
		if not row[i].is_empty() and not is_same(result.row[i],row[i]) and row[i].hp<=result.loss[i]:
			value += 2.5+Cards.DATA[row[i].id].atk*0.5
	return value

static func best(hand: Array, row: Array, energy: int) -> Dictionary:
	var choice := {"id":-1,"lane":-1,"score":0.0}
	for id in hand:
		if not is_weapon(id) or Cards.DATA[id].cost>energy: continue
		for lane in ([-1] if id==9 else [0,1,2,3]):
			var value := score(id,row,lane)
			if value>choice.score: choice = {"id":id,"lane":lane,"score":value}
	return choice
