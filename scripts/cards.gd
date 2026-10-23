extends RefCounted

const BASE_DATA := [
	{"name":"IMP", "art":"TROO", "cost":1, "atk":2, "hp":3, "type":"FIRE", "rarity":0, "ability":"Fireball / +1 vs Pinky", "weak":"BULLET", "resist":"FIRE"},
	{"name":"ZOMBIEMAN", "art":"POSS", "cost":1, "atk":2, "hp":4, "type":"BULLET", "rarity":0, "ability":"Cheap, dependable blocker", "weak":"FIRE", "resist":""},
	{"name":"PINKY", "art":"SARG", "cost":2, "atk":3, "hp":6, "type":"MELEE", "rarity":0, "ability":"Thick hide / resists bullets", "weak":"FIRE", "resist":"BULLET"},
	{"name":"SHOTGUN GUY", "art":"SPOS", "cost":2, "atk":3, "hp":4, "type":"BULLET", "rarity":0, "ability":"Scatter / 1 adjacent damage", "weak":"FIRE", "resist":""},
	{"name":"LOST SOUL", "art":"SKUL", "cost":1, "atk":3, "hp":2, "type":"MELEE", "rarity":0, "ability":"Glass cannon / fire resistant", "weak":"ENERGY", "resist":"FIRE"},
	{"name":"CACODEMON", "art":"HEAD", "cost":3, "atk":2, "hp":4, "type":"ENERGY", "rarity":1, "ability":"Shield: blocks first hit; against a counter, absorbs 1 damage.", "weak":"BULLET", "resist":"FIRE"},
	{"name":"BARON OF HELL", "art":"BOSS", "cost":4, "atk":3, "hp":6, "type":"ENERGY", "rarity":1, "ability":"Bulwark / fire resistant", "weak":"ROCKET", "resist":"FIRE"},
	{"name":"ARCH-VILE", "art":"VILE", "cost":4, "atk":2, "hp":5, "type":"FIRE", "rarity":2, "ability":"3 Souls: revive / 2-turn cooldown", "weak":"ROCKET", "resist":"FIRE"},
	{"name":"CYBERDEMON", "art":"CYBR", "cost":6, "atk":5, "hp":8, "type":"ROCKET", "rarity":3, "ability":"Rockets / 2 adjacent damage", "weak":"ENERGY", "resist":"BULLET"},
	{"name":"BFG 9000", "art":"BFUG", "cost":7, "atk":0, "hp":0, "type":"ENERGY", "rarity":2, "board_damage":4, "exhaust":true, "ability":"Charge / 4 damage to all enemies. Exhaust: once per copy each match.", "weak":"", "resist":""},
	{"name":"MEDIKIT", "art":"", "cost":1, "atk":0, "hp":0, "type":"EVENT", "rarity":0, "exhaust":true, "ability":"Restore 6 Health. Exhaust: once per copy each match.", "weak":"", "resist":""},
	{"name":"SOUL HARVEST", "art":"SKUL", "cost":1, "atk":0, "hp":0, "type":"EVENT", "rarity":1, "ability":"Gain 3 Souls", "weak":"", "resist":""},
	{"name":"JOHN CARMACK", "art":"CARMACK", "cost":4, "atk":2, "hp":6, "type":"ENERGY", "rarity":3, "ability":"On play: shield adjacent allies. Blocks a hit or absorbs 1 counter damage; no stacking.", "weak":"ROCKET", "resist":"ENERGY"},
	{"name":"JOHN ROMERO", "art":"ROMERO", "cost":4, "atk":3, "hp":5, "type":"FIRE", "rarity":3, "ability":"Soul architect: his kills grant 1 extra Soul.", "weak":"BULLET", "resist":"FIRE"},
	{"name":"SPECTRE", "art":"SARG", "cost":2, "atk":3, "hp":3, "type":"MELEE", "rarity":1, "ambush":true, "ability":"Ambush: attacks on the turn it is summoned.", "weak":"FIRE", "resist":"BULLET"},
	{"name":"CHAINGUNNER", "art":"CPOS", "cost":2, "atk":2, "hp":3, "type":"BULLET", "rarity":0, "strikes":2, "ability":"Double burst: attacks twice each combat phase.", "weak":"FIRE", "resist":""},
	{"name":"HELL KNIGHT", "art":"BOS2", "cost":3, "atk":3, "hp":5, "type":"ENERGY", "rarity":0, "ability":"Frontline bruiser. Resists Fire damage.", "weak":"ROCKET", "resist":"FIRE"},
	{"name":"REVENANT", "art":"SKEL", "cost":4, "atk":4, "hp":4, "type":"ROCKET", "rarity":1, "seeking":true, "ability":"Homing rocket: targets the nearest enemy if its own lane is clear.", "weak":"BULLET", "resist":""},
	{"name":"MANCUBUS", "art":"FATT", "cost":5, "atk":3, "hp":8, "type":"FIRE", "rarity":1, "splash":1, "ability":"Flame barrage: 1 splash damage to adjacent enemy lanes.", "weak":"ENERGY", "resist":"FIRE"},
	{"name":"ARACHNOTRON", "art":"BSPI", "cost":4, "atk":2, "hp":5, "type":"ENERGY", "rarity":2, "strikes":2, "ability":"Plasma repeater: attacks twice each combat phase.", "weak":"ROCKET", "resist":"BULLET"},
	{"name":"PAIN ELEMENTAL", "art":"PAIN", "cost":4, "atk":1, "hp":5, "type":"FIRE", "rarity":1, "death_spawn":4, "ability":"On death: leaves a Lost Soul in its lane. The Soul must wait a turn.", "weak":"ENERGY", "resist":"FIRE"},
	{"name":"SPIDER MASTERMIND", "art":"SPID", "cost":7, "atk":2, "hp":10, "type":"BULLET", "rarity":3, "strikes":3, "ability":"Super chaingun: attacks three times each combat phase.", "weak":"ROCKET", "resist":"BULLET"},
	{"name":"DOOMGUY", "art":"PLAY", "cost":5, "atk":3, "hp":6, "type":"BULLET", "rarity":3, "armor":1, "ability":"Combat armor: reduces non-counter hits by 1, minimum 1.", "weak":"FIRE", "resist":""},
	{"name":"WOLFENSTEIN SS", "art":"SSWV", "cost":2, "atk":2, "hp":4, "type":"BULLET", "rarity":0, "on_play_souls":1, "ability":"Secret stash: gain 1 Soul when played.", "weak":"FIRE", "resist":""},
	{"name":"ICON OF SIN", "art":"BBRN", "cost":7, "atk":2, "hp":12, "type":"ENERGY", "rarity":3, "ability":"Hell gate: summon up to two Imps into empty lanes when played. They wait a turn.", "weak":"ROCKET", "resist":"FIRE"}
]
const STARTER := [0,0,0,1,1,2,2,3,3,4,5,14,15,15,16,16,17,18,10,11]
# Affordable openings with Dead Patrol, Night Hunt, Hellfire Battery and bruiser squads.
const SQUAD_STARTER := [1,1,3,3,15,15,2,2,14,14,0,0,5,5,16,18,6,22,9,10]
const MONSTERS := [0,1,2,3,4,5,6,7,8,14,15,16,17,18,19,20,21,23,24]
const ELITE_NAMES := ["EMBERFANG","GRAVE PATROL","IRONJAW","BUCKSHOT REAPER","CINDER WRAITH","STORM EYE","HELLWARDEN","PYRE PRIEST","SIEGEBREAKER","NIGHTSTALKER","LEADSTORM","OBSIDIAN KNIGHT","BONE HUNTER","FURNACE TYRANT","VOLTWEAVER","SOUL MATRON","IRON WIDOW","BUNKER WARDEN","GATEKEEPER"]
const MYTHIC_NAMES := ["ASH SOVEREIGN","THE UNDYING","WORLD EATER","DOOM HARVESTER","ETERNAL FLAME","VOID MAW","CRIMSON KING","DEATH REBORN","APOCALYPSE ENGINE","THE UNSEEN","BULLET HELL","KNIGHT OF RUIN","DEATHSEEKER","INFERNO COLOSSUS","NEXUS WEAVER","SOUL ECLIPSE","THE OVERMIND","LAST BATTALION","THE FINAL SIN"]
const PACK = preload("res://scripts/monster_roster.gd")
const LEGACY_SIZE := 82
const WOLF = preload("res://scripts/wolf_roster.gd")
const CATALOG_SIZE := 155
static var DATA: Array = build_levels()

static func build_levels() -> Array:
	var catalog := build_catalog()
	var result: Array = []
	for level in range(1,11):
		for source in catalog.size():
			var card: Dictionary = catalog[source].duplicate(true)
			card.source_id = source
			card.base_id = card.get("base_id",source)
			card.level = level if card.hp > 0 else 1
			if card.hp > 0 and level > 1:
				card.atk += mini(1 if card.get("strikes",1)>1 else 3,int((level-1)/3))
				card.hp += int(level/2)
				card.cost = mini(8,card.cost+int(level/4))
				if level >= 5:
					card.extra_resist = "ENERGY" if card.resist == "BULLET" else "BULLET"
					card.ability += " Veteran: also resists "+card.extra_resist+"."
				if level == 10:
					card.name = "PRISM " + card.name
					card.ability += " Prism strike: +1 damage against units."
			result.append(card)
	return result

static func leveled_id(id: int, level: int) -> int:
	var source: int = DATA[id].source_id
	return source if DATA[source].hp == 0 else source+(clampi(level,1,10)-1)*CATALOG_SIZE

static func build_catalog() -> Array:
	var result: Array = BASE_DATA.duplicate(true)
	for tier in [1,4,5]:
		for index in MONSTERS.size():
			var id: int = MONSTERS[index]
			var card: Dictionary = BASE_DATA[id].duplicate(true)
			card.base_id = id
			card.rarity = tier
			if tier == 1:
				card.name = "WARDED " + card.name
				card.cost = mini(8,card.cost+1)
				card.hp += 1
				card.starting_shield = true
				card.ability = "Warded: blocks first hit; against a counter, absorbs 1 damage. " + card.ability
			elif tier == 4:
				card.name = ELITE_NAMES[index]
				card.cost = mini(8,card.cost+2)
				card.hp += 1
				card.armor = 1
				card.ability = "Elite armor: non-counter hits deal 1 less (minimum 1). " + card.ability
			else:
				var inherited: String = "" if card.has("strikes") else card.ability
				card.name = MYTHIC_NAMES[index]
				card.cost = mini(8,card.cost+2)
				card.soul_cost = 2
				card.hp += 1
				card.strikes = card.get("strikes",1)+1
				card.ability = "Mythic: %d attacks per combat phase. " % card.strikes + inherited
			result.append(card)
	result.append_array(PACK.DATA.duplicate(true))
	result.append_array(WOLF.DATA.duplicate(true))
	result.append({"name":"DAISY", "art":"DAISY", "actor":"Daisy", "cost":2, "atk":1, "hp":2, "type":"MELEE", "rarity":2, "ambush":true, "starting_shield":true, "ability":"Lucky foot: blocks first hit; counters consume the shield for 1 less damage. Ambush: attacks this turn. Bunny Guard squad with Doomguy.", "weak":"FIRE", "resist":""})
	result.append({"name":"PLASMA GUN", "art":"PLAS", "cost":4, "atk":4, "hp":0, "type":"ENERGY", "rarity":1, "targeted":true, "exhaust":true, "projectile":"PLSS", "ability":"Choose any monster: deal 4 damage. Shields and armour apply. No counterattack. Exhaust: once per copy each match.", "weak":"", "resist":""})
	result.append({"name":"PISTOL","art":"PIST","cost":2,"atk":2,"hp":0,"type":"BULLET","rarity":0,"targeted":true,"exhaust":true,"projectile":"","weapon_shots":1,"weapon_splash":0,"weapon_sound":"DSPISTOL","ability":"Choose any monster: deal 2 damage. Shields and armour apply. No counter. Exhaust: once per copy each match.","weak":"","resist":""})
	result.append({"name":"SHOTGUN","art":"SHOT","cost":3,"atk":3,"hp":0,"type":"BULLET","rarity":0,"targeted":true,"exhaust":true,"projectile":"","weapon_shots":1,"weapon_splash":0,"weapon_sound":"DSSHOTGN","ability":"Choose any monster: deal 3 damage. Shields and armour apply. No counter. Exhaust: once per copy each match.","weak":"","resist":""})
	result.append({"name":"SUPER SHOTGUN","art":"SGN2","cost":5,"atk":6,"hp":0,"type":"BULLET","rarity":1,"targeted":true,"exhaust":true,"projectile":"","weapon_shots":1,"weapon_splash":0,"weapon_sound":"DSDSHTGN","ability":"Choose any monster: deal 6 damage. Shields and armour apply. No counter. Exhaust: once per copy each match.","weak":"","resist":""})
	result.append({"name":"CHAINGUN","art":"MGUN","cost":5,"atk":1,"hp":0,"type":"BULLET","rarity":1,"targeted":true,"exhaust":true,"projectile":"","weapon_shots":5,"weapon_splash":0,"weapon_sound":"DSPISTOL","ability":"Choose any monster: 5 hits of 1 damage. Shields and armour apply. No counter. Exhaust: once per copy each match.","weak":"","resist":""})
	result.append({"name":"ROCKET LAUNCHER","art":"LAUN","cost":6,"atk":5,"hp":0,"type":"ROCKET","rarity":1,"targeted":true,"exhaust":true,"projectile":"MISL","weapon_shots":1,"weapon_splash":2,"weapon_sound":"DSRLAUNC","ability":"Choose any monster: deal 5 damage. Adjacent monsters take 2. Shields and armour apply. No counter. Exhaust: once per copy each match.","weak":"","resist":""})
	# Extra durability for pack units and armor; overlapping categories do not stack.
	for id in result.size():
		if result[id].hp>0 and (id >= LEGACY_SIZE or result[id].get("armor",0) > 0):
			result[id].hp += 1
	return result

static func by_actor(actor: String) -> int:
	for i in range(LEGACY_SIZE,CATALOG_SIZE):
		if DATA[i].get("actor","")==actor:
			return i
	return -1

static func pack_starter() -> Array:
	var result: Array = []
	for actor in ["HelmetMan","HelmetMan","AkimboZombie","AkimboZombie","TankImp","TankImp","ScientistFreeze","ScientistFreeze","FrozenImp","FrozenImp","HellSquire","HellSquire","TechGunman","Minigunner","CyberKnight","Cryocubus","CyberMancubus"]:
		result.append(by_actor(actor))
	result.append_array([9,10,11])
	return result

static func base_id(id: int) -> int:
	return DATA[id].get("base_id",id)

static func unit(id: int, summoned := false) -> Dictionary:
	return {"id":id, "hp":DATA[id].hp, "shield":base_id(id) == 5 or DATA[id].get("starting_shield",false), "cooldown":0, "ready":not summoned or DATA[id].get("ambush",false)}

static func armor(unit: Dictionary) -> int:
	return 0 if unit.get("suit_broken",false) else int(DATA[unit.id].get("armor",0))

static func art_key(id: int, unit: Dictionary = {}) -> String:
	return DATA[id].get("unarmored_art",DATA[id].art) if unit.get("suit_broken",false) else DATA[id].art

static func receive_damage(unit: Dictionary, amount: int, counter := false) -> int:
	var damage := maxi(1,amount-(0 if counter else armor(unit)))
	var before: int = unit.hp
	unit.hp -= damage
	if DATA[unit.id].get("breakable_suit",false) and not unit.get("suit_broken",false):
		var threshold := ceili(float(DATA[unit.id].hp)/2.0)
		if unit.hp<=threshold:
			unit.hp = threshold
			unit.suit_broken = true
	return before-int(unit.hp)

static func weakness_bonus(kind: String) -> int:
	return 1 if kind in ["FIRE","ROCKET"] else 2

static func damage(attacker: int, defender: int) -> int:
	var attack: Dictionary = DATA[attacker]
	var target: Dictionary = DATA[defender]
	return maxi(1, attack.atk + (weakness_bonus(attack.type) if target.weak == attack.type else 0) - (1 if target.resist == attack.type or target.get("extra_resist","") == attack.type else 0))
