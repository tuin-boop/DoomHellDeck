extends RefCounted
## New collection IDs are appended, preserving all previous deck/save identities.
const DATA := [
	{"name":"MECHA-HITLER", "actor":"MechaHitler", "art":"MMM_MechaHitler", "unarmored_art":"MMM_UnarmoredHitler", "base_id":15, "cost":7, "atk":2, "hp":6, "type":"BULLET", "rarity":3, "strikes":2, "armor":1, "breakable_suit":true, "weak":"ROCKET", "resist":"", "ability":"Double burst. Armor 1. At half Health, suit breaks: discard overflow damage and survive in unarmored form. Once per deployment; reinforcement cannot restore suit."},
	{"name":"DR. SCHABBS", "actor":"Schabbs", "art":"MMM_Schabbs", "base_id":1, "cost":3, "atk":2, "hp":3, "type":"BULLET", "rarity":1, "chill":true, "projectile":"MMM_SHOT_Schabbs", "weak":"FIRE", "resist":"", "ability":"Sedative needle: on an unshielded hit, weaken the enemy by 1 Attack for its next combat phase."},
	{"name":"HANS GROSSE", "actor":"Hans", "art":"MMM_Hans", "base_id":15, "cost":4, "atk":2, "hp":5, "type":"BULLET", "rarity":2, "strikes":2, "weak":"FIRE", "resist":"BULLET", "ability":"Twin chainguns: attacks twice per combat phase. Resists Bullet damage."}
]
