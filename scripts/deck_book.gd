extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const LIMIT := 8
var entries: Array = [{"name":"UAC Starter","cards":Cards.STARTER.duplicate()}]
var active := 0

func unique_name(proposed: String, except := -1) -> String:
	var stem := proposed.strip_edges().replace("\n"," ").replace("\r"," ").substr(0,24)
	if stem.is_empty(): stem = "New Deck"
	var result := stem
	var number := 2
	while true:
		var found := false
		for i in entries.size():
			if i!=except and entries[i].name.to_lower()==result.to_lower(): found = true
		if not found: return result
		result = stem.substr(0,20)+" "+str(number)
		number += 1
	return result

func create(proposed: String, cards: Array) -> int:
	if entries.size()>=LIMIT: return -1
	entries.append({"name":unique_name(proposed),"cards":cards.duplicate()})
	return entries.size()-1

func rename(index: int, proposed: String) -> void:
	entries[index].name = unique_name(proposed,index)

func activate(index: int, owned: Array) -> bool:
	if not Rules.issue(entries[index].cards,owned).is_empty(): return false
	active = index
	return true

func remove(index: int, owned: Array) -> bool:
	if entries.size()==1: return false
	entries.remove_at(index)
	if active>index: active -= 1
	active = mini(active,entries.size()-1)
	ensure_active(owned)
	return true

func ensure_active(owned: Array) -> void:
	if active>=0 and active<entries.size() and Rules.issue(entries[active].cards,owned).is_empty(): return
	for i in entries.size():
		if Rules.issue(entries[i].cards,owned).is_empty():
			active = i
			return
	# Preserve an old over-budget deck as a draft, and provide a playable starter.
	active = create("UAC Starter",Cards.STARTER)

func snapshot() -> Dictionary:
	return {"decks":entries.duplicate(true),"active_deck":active}

func restore(data: Dictionary, legacy: Array, owned: Array) -> void:
	entries = []
	var saved = data.get("decks",[])
	if saved is Array:
		for item in saved.slice(0,LIMIT):
			if not item is Dictionary or not item.get("name") is String or not item.get("cards") is Array: continue
			var cards: Array = item.cards
			if cards.size()>Rules.SIZE: continue
			var valid := true
			for id in cards:
				if not (id is float or id is int) or id!=int(id) or id<0 or id>=Cards.CATALOG_SIZE: valid = false
			if valid: create(item.name,cards.map(func(id): return int(id)))
	if entries.is_empty(): create("My Deck",legacy)
	active = clampi(int(data.get("active_deck",0)),0,entries.size()-1)
	# The compatibility deck always carries the last valid battle deck.
	if not Rules.issue(entries[active].cards,owned).is_empty():
		for i in entries.size():
			if Rules.issue(entries[i].cards,owned).is_empty():
				active = i
				return
		if entries.size()==LIMIT:
			# Keep every saved draft; battle fallback can remain outside the library.
			active = -1
			return
		ensure_active(owned)

func battle_cards() -> Array:
	return entries[active].cards.duplicate() if active>=0 else Cards.STARTER.duplicate()
