extends RefCounted
const Cards = preload("res://scripts/cards.gd")
const Rules = preload("res://scripts/deck_rules.gd")
const Squads = preload("res://scripts/squads.gd")
const STYLES := ["Cheap pressure","Balanced","Monster mix","Shields","Armor","Mythic","Fire","Energy","Rockets","Squad combos"]

static func themed(id: int, style: String) -> bool:
	var card: Dictionary = Cards.DATA[id]
	match style:
		"Cheap pressure": return card.hp>0 and card.cost<=2
		"Monster mix": return id>=Cards.LEGACY_SIZE
		"Shields": return card.get("starting_shield",false) or Cards.base_id(id)==5
		"Armor": return card.get("armor",0)>0
		"Mythic": return card.rarity==5
		"Rare": return card.rarity==1
		"Fire": return card.type=="FIRE" and card.hp>0
		"Energy": return card.type=="ENERGY" and card.hp>0
		"Rockets": return card.type=="ROCKET"
	return false

static func pick(cards: Array, pool: Array, random: RandomNumberGenerator, style: String) -> int:
	var weighted: Array = []
	for id in pool:
		if style=="Rare" and Cards.DATA[id].rarity==5: continue
		if not Rules.issue(cards+[id],[],false).is_empty(): continue
		if Rules.cost(cards)+Rules.points(id)+(19-cards.size())*3>Rules.BUDGET: continue
		var weight := 5 if themed(id,style) else 1
		for repeat in weight: weighted.append(id)
	return -1 if weighted.is_empty() else int(weighted[random.randi_range(0,weighted.size()-1)])

static func fingerprint(cards: Array) -> String:
	var sorted := cards.duplicate()
	sorted.sort()
	return str(sorted)

static func generate(seed_value: int = 2026101700, styles: Array = STYLES) -> Dictionary:
	var result := {}
	var seen := {}
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	var cheap: Array = range(Cards.CATALOG_SIZE).filter(func(id): return Cards.DATA[id].hp>0 and Cards.DATA[id].cost<=2)
	for style in styles:
		for variant in 10:
			var accepted := false
			for attempt in 200:
				var cards: Array = []
				if style=="Squad combos":
					var combo: Dictionary = Squads.COMBOS[random.randi_range(0,Squads.COMBOS.size()-1)]
					for group in combo.groups: cards.append(group[random.randi_range(0,group.size()-1)])
				# Every list gets at least five affordable units for its opening turns.
				for opening in 5:
					var id := pick(cards,cheap,random,style)
					if id>=0: cards.append(id)
				var target := 2 if style=="Mythic" else (10 if style=="Monster mix" else (6 if style=="Rare" else 4))
				if style not in ["Balanced","Squad combos"]:
					var theme_pool: Array = range(Cards.CATALOG_SIZE).filter(func(id): return themed(id,style))
					while cards.filter(func(id): return themed(id,style)).size()<target:
						var id := pick(cards,theme_pool,random,style)
						if id<0: break
						cards.append(id)
					if cards.filter(func(id): return themed(id,style)).size()<target: continue
				while cards.size()<20:
					var id := pick(cards,range(Cards.CATALOG_SIZE),random,style)
					if id<0: break
					cards.append(id)
				if not Rules.issue(cards).is_empty() or seen.has(fingerprint(cards)): continue
				seen[fingerprint(cards)] = true
				result["%s %02d" % [style,variant+1]] = cards
				accepted = true
				break
			assert(accepted,"Could not generate a distinct legal deck: "+style)
	assert(result.size()==styles.size()*10 and seen.size()==styles.size()*10)
	return result
