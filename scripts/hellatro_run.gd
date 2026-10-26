extends RefCounted
# Explicit Variant-only snapshots; no scenes, resources or executable objects in saves.
const MELD_KEYS := ["boss","previous_boss","round_award_owner","round_history","round_start_scores","match_powers","upgrades","family_plays","passive_joker","enhancements","power_panel","upgrade_offers","upgrade_pending","route_offers","next_route","extension_chain","mutation_last","modifier","relic","relic_used","drew_this_round","hands","stock","melds","scores","rounds","turns","round_number","side","discarded","discovered","round_over","result_winner","finished","message","round_message","round_scores","round_intro","round_intro_age"]
const SUPPORT_KEYS := ["slots","stats","drained","pending","offers","chosen","swap_slot","editions","offer_editions","last_table_family"]
const SHOP_KEYS := ["enabled","active","credits","funded_round","offers","rerolls","packs_bought","pack_kind","pack_choices","pack_tier","apply_edition","message","recorded","earned_backs","new_record","recap"]
var path := "user://hellatro_run.cfg"
var enabled := false
var stage := 1
var banked := 0
var alive := true
var timer := 0.0
var last_hash := 0
func begin(active: bool) -> void:
	enabled = active
	stage = 1
	banked = 0
	alive = true
	last_hash = 0
func score(m) -> int: return banked+int(m.scores[0])
func slot_limit(m) -> int: return mini(5,(stage-1)*5+m.round_number) if enabled else mini(5,m.round_number)
func available() -> bool:
	return FileAccess.file_exists(path)
func snapshot(obj, keys: Array) -> Dictionary:
	var data := {}
	for key in keys: data[key] = obj.get(key)
	return data.duplicate(true)
func restore(obj, data: Dictionary, keys: Array) -> void:
	for key in keys:
		if data.has(key): obj.set(key,data[key])
func save_run(m) -> void:
	if not enabled or not alive: return
	var data := {"version":1,"stage":stage,"banked":banked,"rng":m.random.state,"meld":snapshot(m,MELD_KEYS),"support":snapshot(m.support,SUPPORT_KEYS),"shop":snapshot(m.progression,SHOP_KEYS)}
	var signature := hash(data)
	if signature==last_hash: return
	var cfg := ConfigFile.new()
	cfg.set_value("run","state",data)
	if cfg.save(path+".tmp")==OK:
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(path+".tmp"),ProjectSettings.globalize_path(path))==OK: last_hash = signature
	m.profile.ensure_loaded()
	if score(m)>m.profile.best_run:
		m.profile.best_run = score(m)
		m.profile.save()
func autosave(g,m,delta: float) -> void:
	if not enabled or not alive or g.modal!="hell_meld": return
	timer += delta
	if timer<0.5: return
	timer = 0
	save_run(m)
func resume(g,m) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(path)!=OK: return false
	var data = cfg.get_value("run","state",{})
	if not data is Dictionary or data.get("version",0)!=1 or not data.has("meld"): return false
	# start initializes transient state; the saved authoritative state is restored below.
	m.start(g)
	enabled = true
	alive = true
	stage = int(data.stage)
	banked = int(data.banked)
	restore(m,data.meld,MELD_KEYS)
	restore(m.support,data.support,SUPPORT_KEYS)
	restore(m.progression,data.shop,SHOP_KEYS)
	m.random.state = data.rng
	m.progression.pack_age = 4.0
	m.progression.preview_pack = -1
	m.progression.recap_open = false
	m.support.draft_age = 5.0
	m.guide = false
	m.selected.clear()
	m.announcement.clear()
	m.banner_age = 99.0
	m.result_age = 99.0
	m.draw_flights.clear()
	m.flights.clear()
	m.sound_cues.clear()
	m.cpu_wait = 1.35
	m.finale.choose_picture(m.result_winner)
	g.ended = m.finished
	last_hash = 0
	return true
func stage_end(m) -> void:
	if not enabled: return
	m.profile.ensure_loaded()
	m.profile.best_run = maxi(m.profile.best_run,score(m))
	m.profile.last_run_score = score(m)
	m.profile.last_run_stage = stage
	if m.result_winner==0:
		m.profile.highest_stage = maxi(m.profile.highest_stage,stage+1)
	elif m.result_winner==1:
		alive = false
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	m.profile.save()
func continue_stage(g,m) -> void:
	if not enabled or not m.finished or m.result_winner==1: return
	banked += int(m.scores[0])
	if m.result_winner==0: stage += 1
	m.scores = [0,0]
	m.rounds = [0,0]
	m.round_number = 1
	m.round_history.clear()
	m.finished = false
	m.progression.recorded = false
	m.progression.funded_round = 0
	m.progression.recap_open = false
	m.progression.earned_backs.clear()
	m.next_route.clear()
	m.power_panel = false
	m.upgrade_pending = false
	g.ended = false
	m.next_round()
	m.support.offer(m)
	save_run(m)
func pressure() -> int: return (stage-1)*3 if enabled else 0
func combo_bonus(ids: Array, extension: bool) -> int:
	if not enabled or stage<2: return 0
	return (stage-1)*2 if (extension or ids.size()>=4) else 0
