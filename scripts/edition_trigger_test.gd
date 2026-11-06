extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const Editions = preload("res://scripts/joker_editions.gd")
func _initialize() -> void:
	var m = Meld.new()
	m.next_round()
	var combo := {"gain":10,"kind":"set"}
	for owner in 2:
		m.support.slots[owner] = [22]
		m.support.editions[owner] = {22:2}
		for i in 3:
			var preview: Dictionary = m.support.score(m,owner,[0,0],combo,false)
			var actual: Dictionary = m.support.score(m,owner,[0,0],combo,false,true)
			assert(preview==actual)
			assert(actual.bonus==(26 if i==2 else 0),"Golden Barrel must wait for explosion")
	m.support.reset()
	m.support.slots[0] = [2]
	for edition in range(1,9):
		m.support.editions[0] = {2:edition}
		assert(m.support.score(m,0,[0,0],combo,false).bonus==0,"Inactive Cowboy cannot grant any edition")
	m.support.editions[0] = {2:3}
	assert(m.support.score(m,0,[1],combo,true).bonus==6,"Plasma counts one NEW Bullet card: Cowboy4 + Plasma2")
	m.support.slots[0] = [47]
	m.support.editions[0] = {47:2}
	assert(m.support.score(m,0,[0,2,3],{"gain":20,"kind":"run"},false).bonus==0)
	assert(m.support.score(m,0,[0,2,3],{"gain":20,"kind":"run","rule_joker":47,"name":"RIFT MARCH"},false).bonus==6)
	m.support.slots[0] = [5]
	m.support.editions[0] = {5:2}
	for i in 3:
		assert(m.support.score(m,0,[0,2,3],{"gain":20,"kind":"run"},false,true).bonus==(6 if i==2 else 0))
	m.support.reset()
	m.support.slots[0] = [18]
	m.support.editions[0] = {18:2}
	assert(m.support.on_draw(0,1)==2)
	assert(m.support.score(m,0,[0,0],combo,false,true).bonus==0,"No actual extra draw means no edition")
	m.support.begin_round()
	m.support.on_draw(0,2)
	assert(m.support.score(m,0,[0,0],combo,false,true).bonus==6)
	assert(m.support.score(m,0,[0,0],combo,false,true).bonus==0,"Stored draw trigger consumed once")
	m.support.reset()
	m.support.slots[0] = [17]
	m.support.editions[0] = {17:2}
	m.turns[0] = 8
	assert(m.support.score(m,0,[0,0],combo,false).bonus==0)
	m.turns[0] = 9
	assert(m.support.score(m,0,[0,0],combo,false).gain==18,"Multiplier trigger receives Golden2 before x1.5")
	print("PASS: both-side Barrel cadence, all inactive editions, Plasma new cards, rule/growth/draw/multiplier triggers")
	quit()
