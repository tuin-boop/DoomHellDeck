extends RefCounted

# Opponent selection never consumes the combat or deck random stream.
const DEFAULT := "graves"
const ROSTER := [
	{"id":"ashfang", "name":"ASHFANG", "kind":"IMP", "portrait":preload("res://assets/commanders/ashfang.png")},
	{"id":"oculus", "name":"OCULUS", "kind":"CACODEMON", "portrait":preload("res://assets/commanders/oculus.png")},
	{"id":"iron_tyrant", "name":"IRON TYRANT", "kind":"CYBERDEMON", "portrait":preload("res://assets/commanders/iron_tyrant.png")},
	{"id":"goremaw", "name":"GOREMAW", "kind":"PINKY", "portrait":preload("res://assets/commanders/goremaw.png")},
	{"id":"graves", "name":"CAPTAIN GRAVES", "kind":"DOOM MARINE", "portrait":preload("res://assets/commanders/graves.png")},
	{"id":"synapse", "name":"SYNAPSE", "kind":"ARACHNOTRON", "portrait":preload("res://assets/commanders/synapse.png")},
	{"id":"tuin", "name":"TUIN", "kind":"SUPPORT", "portrait":preload("res://assets/commanders/tuin.png")},
]

static func valid(id: Variant) -> bool:
	return id is String and ROSTER.any(func(entry): return entry.id == id)

static func entry(id: String) -> Dictionary:
	for commander in ROSTER:
		if commander.id == id: return commander
	return ROSTER[4]

static func opponent(id: String, random: RandomNumberGenerator) -> String:
	var choices := ROSTER.filter(func(commander): return commander.id != id)
	return choices[random.randi_range(0,choices.size()-1)].id
