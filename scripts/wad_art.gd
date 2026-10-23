extends RefCounted
## Reads indexed Doom patch sprites directly from a user's local IWAD.
var textures: Dictionary = {}
var font_glyphs: Dictionary = {}
var sounds: Dictionary = {}
var attack_textures: Dictionary = {}
var effect_textures: Dictionary = {}
var side_textures: Dictionary = {}
var side_attack_textures: Dictionary = {}
var side_effect_textures: Dictionary = {}
var monster_sounds: Dictionary = {}

func load_selected_pack(manifest_path := "res://assets/monsters/manifest.json") -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	for key in manifest:
		var entry: Dictionary = manifest[key]
		for kind in ["idle","attack","side","side_attack"]:
			var frames: Array[Texture2D] = []
			for path in entry[kind]:
				frames.append(load(path))
			if kind=="idle": textures[key] = frames
			elif kind=="attack": attack_textures[key] = frames
			elif kind=="side": side_textures[key] = frames
			else: side_attack_textures[key] = frames
		if entry.has("projectile_effect"):
			var effect: Dictionary = entry.projectile_effect
			var suffix: String = str(key).trim_prefix("MMM_")
			for kind in ["flight","flight_side","impact","impact_side"]:
				var frames: Array[Texture2D] = []
				for path in effect[kind]: frames.append(load(path))
				var effect_key := ("MMM_SHOT_" if kind.begins_with("flight") else "MMM_HIT_")+suffix
				if kind.ends_with("side"): side_effect_textures[effect_key] = frames
				else: effect_textures[effect_key] = frames
		monster_sounds[key] = {}
		for event in entry.sounds:
			monster_sounds[key][event] = []
			for path in entry.sounds[event]:
				if not sounds.has(path):
					sounds[path] = load(path)
				monster_sounds[key][event].append(path)
# Front-facing attack poses: https://github.com/id-Software/DOOM/blob/master/linuxdoom-1.10/info.c
const ATTACK_POSES := {"TROO":"EFG","POSS":"EFE","SPOS":"EFE","SARG":"EFG","HEAD":"BCD","SKUL":"CD","BOSS":"EFG","BOS2":"EFG","VILE":"GHIJKLMNOP","CYBR":"EF","PLAY":"EF","CPOS":"EF","SKEL":"JK","FATT":"GHI","BSPI":"AGH","PAIN":"DEF","SPID":"AGH","SSWV":"EFG"}
const EFFECT_POSES := {"BAL1":"ABCDE","BAL2":"ABCDE","BAL7":"ABCDE","PLSS":"AB","PLSE":"ABCDE","MISL":"ABCD","FATB":"AB","MANF":"AB","APLS":"AB","APBX":"ABCDE","FIRE":"ABCDEFGH","PUFF":"ABCD","BFE1":"ABCDEF"}
var status := "No WAD loaded â€¢ procedural silhouettes active"

func load_wad(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var bytes := file.get_buffer(file.get_length())
	if bytes.size() < 12 or bytes.slice(0, 4).get_string_from_ascii() not in ["IWAD", "PWAD"]:
		return false
	var count := bytes.decode_u32(4)
	var directory := bytes.decode_u32(8)
	if directory + count * 16 > bytes.size():
		return false
	var lumps := {}
	for i in count:
		var offset := directory + i * 16
		var label := bytes.slice(offset + 8, offset + 16).get_string_from_ascii().strip_edges()
		lumps[label] = [bytes.decode_u32(offset), bytes.decode_u32(offset + 4)]
	if not lumps.has("PLAYPAL"):
		return false
	var palette: int = lumps["PLAYPAL"][0]
	if palette + 768 > bytes.size():
		return false
	# Doom's original red HUD/message alphabet, decoded with transparent pixels.
	for code in range(33,96):
		var glyph_name := "STCFN%03d" % code
		if lumps.has(glyph_name):
			var glyph := decode_patch(bytes,lumps[glyph_name][0],lumps[glyph_name][1],palette)
			if glyph != null: font_glyphs[String.chr(code)] = glyph
	for prefix in ["TROO", "SARG", "POSS", "SPOS", "HEAD", "SKUL", "BOSS", "CYBR", "VILE", "PLAY", "BFUG", "PLAS", "PIST", "SHOT", "SGN2", "MGUN", "LAUN", "CPOS", "BOS2", "SKEL", "FATT", "BSPI", "PAIN", "SPID", "SSWV", "BBRN", "AMMO"]:
		var frames: Array[Texture2D] = []
		for pose in ["A", "B"]:
			for suffix in ["1", "0"]:
				var key: String = prefix + pose + suffix
				if not lumps.has(key):
					for candidate in lumps:
						if candidate.begins_with(key):
							key = candidate
							break
				if lumps.has(key):
					var texture := decode_patch(bytes, lumps[key][0], lumps[key][1], palette)
					if texture != null:
						frames.append(texture)
					break
		textures[prefix] = frames
	# Pistol has no world pickup sprite; use its first-person ready frame.
	if textures.get("PIST",[]).is_empty() and lumps.has("PISGA0"):
		textures["PIST"] = [decode_patch(bytes,lumps.PISGA0[0],lumps.PISGA0[1],palette)]
	for prefix in ATTACK_POSES:
		attack_textures[prefix] = load_frames(bytes,lumps,palette,prefix,ATTACK_POSES[prefix])
		side_textures[prefix] = load_frames(bytes,lumps,palette,prefix,"AB",["3","0","1"])
		side_attack_textures[prefix] = load_frames(bytes,lumps,palette,prefix,ATTACK_POSES[prefix],["3","0","1"])
	for prefix in EFFECT_POSES:
		effect_textures[prefix] = load_frames(bytes,lumps,palette,prefix,EFFECT_POSES[prefix])
		side_effect_textures[prefix] = load_frames(bytes,lumps,palette,prefix,EFFECT_POSES[prefix],["3","0","1"])
	for name in lumps:
		if not name.begins_with("DS"):
			continue
		if lumps.has(name):
			var stream := decode_sound(bytes,lumps[name][0],lumps[name][1])
			if stream != null:
				sounds[name] = stream
	status = "DOOM.WAD connected â€¢ original monster sprites and sounds"
	return true

func load_frames(bytes: PackedByteArray, lumps: Dictionary, palette: int, prefix: String, poses: String, rotations: Array = ["1","0"]) -> Array:
	var frames: Array = []
	for pose in poses:
		var found := false
		for rotation in rotations:
			var key: String = prefix+pose+rotation
			for name in lumps:
				# The second pose/rotation pair in a Doom lump is horizontally mirrored.
				var mirrored: bool = name.begins_with(prefix) and name.length()>=8 and name.substr(6,2)==pose+rotation
				if name.begins_with(key) or mirrored:
					var texture := decode_patch(bytes,lumps[name][0],lumps[name][1],palette)
					if texture != null:
						if mirrored and not name.begins_with(key):
							var pixels := texture.get_image()
							pixels.flip_x()
							texture = ImageTexture.create_from_image(pixels)
						frames.append(texture)
						found = true
					break
			if found:
				break
	return frames

func decode_sound(bytes: PackedByteArray, base: int, length: int) -> AudioStreamWAV:
	if base < 0 or length < 8 or base+length > bytes.size() or bytes.decode_u16(base) != 3:
		return null
	var rate := bytes.decode_u16(base+2)
	var count := bytes.decode_u32(base+4)
	if rate < 4000 or rate > 96000 or count <= 32 or count > length-8:
		return null
	# DMX stores unsigned 8-bit mono PCM with 16 padding samples at each end.
	var pcm := PackedByteArray()
	pcm.resize((count-32)*2)
	for i in count-32:
		pcm.encode_s16(i*2,(int(bytes[base+24+i])-128)*256)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = pcm
	return stream

func decode_patch(bytes: PackedByteArray, base: int, length: int, palette: int) -> Texture2D:
	if base + length > bytes.size() or length < 8:
		return null
	var width := bytes.decode_u16(base)
	var height := bytes.decode_u16(base + 2)
	if width < 1 or width > 1024 or height < 1 or height > 1024 or 8 + width * 4 > length:
		return null
	var picture := Image.create(width, height, false, Image.FORMAT_RGBA8)
	picture.fill(Color.TRANSPARENT)
	for x in width:
		var cursor := base + bytes.decode_u32(base + 8 + x * 4)
		while cursor < base + length and bytes[cursor] != 255:
			if cursor + 3 >= base + length:
				break
			var top: int = bytes[cursor]
			var run: int = bytes[cursor + 1]
			if cursor + run + 4 > base + length:
				break
			for y in run:
				var index: int = palette + int(bytes[cursor + 3 + y]) * 3
				if top + y < height:
					picture.set_pixel(x, top + y, Color8(bytes[index], bytes[index + 1], bytes[index + 2]))
			cursor += run + 4
	return ImageTexture.create_from_image(picture)
