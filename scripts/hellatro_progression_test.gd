extends SceneTree
const Meld = preload("res://scripts/hell_meld.gd")
const Editions = preload("res://scripts/joker_editions.gd")
func _initialize() -> void:
	run.call_deferred()
func run() -> void:
	var m = Meld.new()
	m.support.slots = [[47],[]]
	assert(m.Rules.special_pattern(m,0,[0,5,6],"run").name=="RIFT MARCH")
	assert(m.Rules.special_pattern(m,1,[0,5,6],"run").is_empty())
	assert(m.Rules.special_pattern(m,0,[0,6,8],"run").is_empty())
	m.support.slots = [[48],[]]
	assert(m.Rules.special_pattern(m,0,[0,8,21],"team").points==35)
	assert(m.Rules.special_pattern(m,1,[0,8,21],"team").is_empty())
	assert(m.Rules.special_pattern(m,0,[0,0,8],"team").is_empty())
	m.support.slots = [[49],[]]
	assert(m.Rules.special_pattern(m,0,[0,7,3],"type").name=="PRISM GATHERING")
	assert(m.Rules.special_pattern(m,1,[0,7,3],"type").is_empty())
	assert(m.Rules.special_pattern(m,0,[0,0,3],"type").is_empty())
	var wild: Dictionary = m.Rules.special_pattern(m,0,[-1,7,3],"type")
	assert(not wild.is_empty() and wild.has("resolved_ids"))
	for boss in 3:
		assert(m.Rules.boss_loss(boss,3,2,false,true)==2)
		assert(m.Rules.boss_loss(boss,30,3,true,false)==0)
	m.support.slots = [[0,12],[]]
	m.support.editions = [{0:2,12:1},{}]
	var preview: Dictionary = m.support.score(m,0,[0],{"gain":10,"kind":"set"},true)
	assert(preview.gain==25,"Joker +5, Mime +5, Golden +2, Bloodstained +3")
	assert(preview==m.support.score(m,0,[0],{"gain":10,"kind":"set"},true,true))
	assert(m.support.score(m,1,[0],{"gain":10,"kind":"set"},true).bonus==0)
	var context := {"extension":true,"count":4,"changed":true,"behind":true,"fire":4}
	var bonuses := [0,3,2,4,4,4,6,0,6]
	for edition in 9: assert(Editions.bonus(edition,context)==bonuses[edition])
	m = Meld.new()
	m.progression.enabled = true
	m.progression.recorded = true
	m.random.seed = 1234
	m.next_round()
	m.support.offer(m)
	m.support.chosen = m.support.offers[0]
	m.support.finish_pick(m)
	var shop = m.progression
	assert(shop.active and shop.credits[0]==8 and m.scores==[0,0])
	assert(not m.draw_one(m.side) and not m.play(m.side,[0,1],-1),"Shop blocks both sides")
	assert(not shop.buy(m,0),"Full slot cannot be overwritten")
	var cash: int = shop.credits[0]
	assert(shop.sell(m,0,0) and shop.credits[0]>cash)
	shop.credits[0] = 30
	assert(shop.buy(m,0))
	cash = shop.credits[0]
	assert(not shop.buy(m,0) and shop.credits[0]==cash,"No duplicate purchase")
	assert(shop.open_pack(m,1))
	shop.pack_age = 2
	assert(shop.choose_pack(m,0) and shop.apply_edition>0)
	# Apply through actual input handler, using a lightweight audio stub.
	m.support.editions[0][m.support.slots[0][0]] = shop.apply_edition
	shop.apply_edition = -1
	shop.pack_kind = -1
	assert(not shop.open_pack(m,1),"One edition pack per shop")
	assert(shop.open_pack(m,2))
	shop.pack_age = 2
	var family: String = shop.pack_choices[0]
	assert(shop.choose_pack(m,0) and m.upgrades[0][family]==1)
	assert(shop.reroll(m))
	shop.finish(m)
	assert(not shop.active and m.scores==[0,0])
	m = Meld.new()
	m.boss = 0
	m.modifier = -1
	m.relic = -1
	m.support.slots = [[0],[]]
	m.support.editions[0][0] = 2
	m.hands = [[0,0],[1,1]]
	m.side = 0
	m.mutation_last[0] = "set"
	preview = m.evaluate(0,[0,1])
	assert(preview.gain==9 and preview.boss_penalty==8)
	assert(m.play(0,[0,1],-1))
	assert(m.round_scores[0]==preview.gain and m.progression.recap.best[0].gain==preview.gain)
	# Isolated profile: unlock once, persist selection, never touch the player's save.
	m.profile.path = "user://hellatro-progression-test.cfg"
	m.profile.loaded = true
	m.profile.entries = JSON.parse_string(FileAccess.get_file_as_string("res://assets/card_backs/catalogue.json"))
	m.progression.enabled = true
	m.scores = [1100,900]
	m.result_winner = 0
	m.progression.recap.families[0] = {"set":1,"pairs":1,"type":1,"run":1,"team":1}
	m.progression.recap.draws[0] = 5
	m.progression.recap.extensions[0] = 10
	m.progression.finalize(m)
	assert(m.profile.unlocked.has("scream_king") and m.profile.unlocked.has("sleepy_mancubus") and m.profile.unlocked.has("pirate_cacodemon"))
	m.progression.finalize(m)
	assert(m.profile.matches==1,"Finalize is idempotent")
	m.profile.selected = "scream_king"
	m.profile.save()
	var reload_profile = preload("res://scripts/hellatro_profile.gd").new()
	reload_profile.path = m.profile.path
	reload_profile.ensure_loaded()
	assert(reload_profile.selected=="scream_king" and reload_profile.wins==1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(m.profile.path))
	print("PASS: rule Jokers, wild resolution, editions, boss penalties, shop economy, packs, recap and profile persistence")
	quit()
