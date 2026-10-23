extends Node2D
var game
var title := ""
var body := ""
var key := ""
var age := 0.0
var last_key := ""
func _ready() -> void:
	z_index = 100
func reset() -> void:
	title = ""
	body = ""
	key = ""
func offer(rect: Rect2, heading: String, explanation: String) -> void:
	if rect.has_point(game.get_global_mouse_position()):
		title = heading
		body = explanation
		key = str(rect)+heading
func _process(delta: float) -> void:
	if key!=last_key:
		age = 0
		last_key = key
	else: age += delta
	queue_redraw()
func _draw() -> void:
	if body=="" or age<0.4: return
	var lines: Array[String] = []
	var line := ""
	for paragraph in body.split("\n"):
		line = ""
		for word in paragraph.split(" "):
			if game.font.get_string_size(line+word,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x>365:
				lines.append(line)
				line = ""
			line += word+" "
		if line!="": lines.append(line)
	if lines.size()>32:
		lines.resize(32)
		lines[31] = "More combinations available with these cards."
	var height := 62+lines.size()*23
	var mouse: Vector2 = game.get_global_mouse_position()
	var pos := Vector2(clampf(mouse.x+20,10,1035),clampf(mouse.y+24,10,930-height))
	draw_rect(Rect2(pos+Vector2(4,5),Vector2(395,height)),Color(0,0,0,0.6))
	draw_rect(Rect2(pos,Vector2(395,height)),Color("101e22"))
	draw_rect(Rect2(pos,Vector2(395,height)),Color("edb665"),false,2)
	var heading: String = title.left(34)
	draw_string(game.font,pos+Vector2(15,28),heading,HORIZONTAL_ALIGNMENT_LEFT,-1,18,Color("ffd482"))
	for i in lines.size(): draw_string(game.font,pos+Vector2(15,55+i*23),lines[i],HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("e5ebdf"))
func button_help(text: String) -> String:
	var lookup := {
	"HELL DECK":"Tactical battles with heroes, weapons and squads. Choose a built deck or random cards next.",
	"HELL MELD":"Five rounds of monster combinations. Ten turns each; highest round score wins. Draft personal support Jokers, extend the centre or draw and pass.",
	"JOKER COLLECTION":"Browse all support Jokers. Hover each card for its exact effect. Your personal Jokers stay active throughout the match.",
	"MATCH POWERS":"Inspect the shared Match Bonus, enhanced cards, your hand upgrades, and your personal Joker effects.",
	"COMBINATIONS":"Illustrated examples of every combination. This guide does not solve your hand.",
	"FIELD GUIDE":"Illustrated examples of every combination. This guide does not solve your hand.",
	"PLAY SELECTION":"Commit your selected cards. They must form a new combination or extend the centre. Invalid attempts keep your cards.",
	"DRAW / PASS":"Take one card, clear the centre and end your turn. You may do this even if you have a legal play.",
	"SORT HAND":"Reorder your hand by monster identity and clear your selection.",
	"CLEAR SELECTION":"Deselect all cards without playing them.",
	"CHOOSE UPGRADE":"Choose one of three combo families to earn +5 extra points per play for the rest of this match.",
	"OPTIONS":"Change master volume, fullscreen and battle presentation.",
	"BUILT DECK":"Start a battle using your selected saved deck.",
	"RANDOM CARDS":"Start a battle with freshly randomized decks for both sides.",
	"DECK BUILDER":"Create or edit a 20-card deck within its points budget.",
	"CHOOSE HERO":"Choose your hero and their special ability.",
	"MAIN MENU":"Return to the game-mode menu. An unfinished match asks for confirmation before ending.",
	"LEAVE / MAIN MENU":"End this match and return to the main menu. You cannot resume it.",
	"KEEP PLAYING":"Close the warning and continue your current match.",
	"PLAY AGAIN":"Begin a fresh five-round match. Match upgrades and powers reset.",
	"PAUSE":"Pause the music without changing the current song.",
	"PLAY":"Start or resume radio music.",
	"NEXT":"Play the next song using the selected radio mode, or move to the next guide page.",
	"STOP":"Stop radio playback. Music stays off until you play it again.",
	"PLAY ALBUM IN ORDER":"Play the selected album in track order, looping back to its first song at the end.",
	"SHUFFLE THIS ALBUM":"Choose random songs only from the selected album, avoiding immediate repeats.",
	"SHUFFLE ALL MUSIC":"Choose from all installed music, avoiding immediate repeats.",
	"QUIT":"Close the game.",
	"RADIO / F8":"Open Hell Radio. Choose albums, tracks, shuffle and music volume. F8 also opens it during gameplay.",
	"F8":"Hell Radio: music controls and album selection. You can also press F8.",
	"BACK / F8":"Return to the previous screen while music continues.",
	"BACK TO TABLE":"Close this panel and return to your cards.",
	"PREVIOUS":"View the previous guide page.",
	"BACK":"Return to the previous menu.",
	"BACK TO MAIN MENU":"Return to the game-mode selection screen."
	}
	var label := text.trim_prefix("* ")
	if lookup.has(label): return lookup[label]
	if game.modal=="hell_meld" and game.hell_meld.power_panel:
		if game.hell_meld.round_over:
			for family in game.hell_meld.FAMILY_NAMES:
				if game.hell_meld.FAMILY_NAMES[family]==label: return game.hell_meld.FAMILY_HELP[family]+" Earn +5 extra points each time you play or extend this family. Stacks for the rest of this match."
	if label=="+" or label=="-": return "Adjust volume. Radio volume is separate from the game's master volume." if game.modal=="radio" else "Adjust the master sound volume."
	if "ALBUMS" in label: return "Browse another page of albums. Click an album to start listening."
	if "TRACKS" in label: return "Browse another page of tracks in the selected album. Click a song to play it."
	if game.modal=="radio": return "Select this album or song to play it. Music continues after closing the radio."
	if "FULLSCREEN" in label: return "Toggle between fullscreen and a window."
	if "BATTLE VIEW" in label: return "Toggle the cinematic side-view combat animations."
	if "DECK" in label: return "Manage this deck. A playable deck needs 20 cards within its points budget."
	return "Select this option. Grey controls need their requirements met before they can be used."
