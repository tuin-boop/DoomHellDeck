extends Node
## Independent voices preserve weapon tails, explosions, and monster cries.
const Cards = preload("res://scripts/cards.gd")
const ATTACK := {148:"DSPUNCH",0:"DSFIRSHT",1:"DSPISTOL",2:"DSSGTATK",3:"DSSHOTGN",4:"DSSKLATK",5:"DSFIRSHT",6:"DSFIRSHT",7:"DSVILATK",8:"DSRLAUNC",12:"DSPLASMA",13:"DSFIRSHT",14:"DSSGTATK",15:"DSSHOTGN",16:"DSFIRSHT",17:"DSSKEATK",18:"DSMANATK",19:"DSPLASMA",20:"DSSKLATK",21:"DSSHOTGN",22:"DSDSHTGN",23:"DSPISTOL",24:"DSBOSPIT"}
const DEATH := {148:["DSOOF"],0:["DSBGDTH1","DSBGDTH2"],1:["DSPODTH1","DSPODTH2","DSPODTH3"],2:["DSSGTDTH"],3:["DSPODTH1","DSPODTH2","DSPODTH3"],4:["DSSKLDTH"],5:["DSCACDTH"],6:["DSBRSDTH"],7:["DSVILDTH"],8:["DSCYBDTH"],12:["DSPLDETH"],13:["DSPLDETH"],14:["DSSGTDTH"],15:["DSPODTH1","DSPODTH2","DSPODTH3"],16:["DSKNTDTH"],17:["DSSKEDTH"],18:["DSMANDTH"],19:["DSBSPDTH"],20:["DSPEDTH"],21:["DSSPIDTH"],22:["DSPLDETH"],23:["DSSSDTH"],24:["DSBOSDTH"]}
const PAIN := {148:"DSOOF",1:"DSPOPAIN",3:"DSPOPAIN",7:"DSVIPAIN",12:"DSPLPAIN",13:"DSPLPAIN",15:"DSPOPAIN",18:"DSMNPAIN",20:"DSPEPAIN",22:"DSPLPAIN",23:"DSPOPAIN",24:"DSBOSPN"}
var sounds: Dictionary = {}
var monster_sounds: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var last_played: Dictionary = {}
var next_voice := 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	for i in 16:
		var voice := AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)

func play(key: String, volume := -10.0) -> bool:
	if not sounds.has(key) or voices.is_empty():
		return false
	# Coalesce simultaneous splash hits, but preserve subsequent burst shots.
	var now := Time.get_ticks_msec()
	if now-int(last_played.get(key,-1000)) < 45:
		return false
	last_played[key] = now
	var voice: AudioStreamPlayer = voices[next_voice]
	for candidate in voices:
		if not candidate.playing:
			voice = candidate
			break
	next_voice = (voices.find(voice)+1)%voices.size()
	voice.stop()
	voice.stream = sounds[key]
	voice.volume_db = volume
	voice.play()
	return true

func monster(id: int, event: String) -> void:
	var base := Cards.base_id(id)
	var choices: Array = monster_sounds.get(Cards.DATA[id].art,{}).get(event,[])
	if not choices.is_empty():
		play(choices[rng.randi_range(0,choices.size()-1)],-8 if event=="attack" else -13)
		return
	if event == "attack":
		var kind: String = Cards.DATA[id].type
		var fallback: String = ATTACK.get(base,"DSFIRSHT")
		if Cards.DATA[id].has("actor"):
			fallback = {"BULLET":"DSSHOTGN","ENERGY":"DSPLASMA","ICE":"DSPLASMA","FIRE":"DSFIRSHT","ROCKET":"DSRLAUNC","MELEE":"DSPUNCH"}.get(kind,fallback)
		play(fallback,-8)
	elif event == "pain":
		play(PAIN.get(base,"DSDMPAIN"),-15)
	else:
		var death_choices: Array = DEATH.get(base,["DSPLDETH"])
		var available: Array = death_choices.filter(func(key): return sounds.has(key))
		if not available.is_empty():
			play(available[rng.randi_range(0,available.size()-1)],-10)
		else:
			play("DSDMPAIN",-12)

func impact(kind: String) -> void:
	play({"ICE":"DSFIRXPL","ROCKET":"DSRXPLOD","FIRE":"DSFIRXPL","ENERGY":"DSFIRXPL","MELEE":"DSPUNCH"}.get(kind,""),-13)

func _exit_tree() -> void:
	for voice in voices:
		voice.stop()
		voice.stream = null
