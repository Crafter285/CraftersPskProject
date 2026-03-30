extends Node

@onready var player: CharacterBody3D = $".."

signal sound(sound_name: String)

var current_soundpack: String = ""

func toggle_flashlight():
	get_node("flashlight").play()

func step():
	var folder_path: String = str("res://Player/Sound/Movement/", current_soundpack, "/")
	var sound_name: String = ""
	
	if player.is_squeezing:
		sound_name = str("walk",randi_range(1, 6))
	elif player.is_sprinting:
		sound_name = str("run",randi_range(1, 6))
	else:
		sound_name = str("walk",randi_range(1, 6))
	
	var file_name = str(sound_name, ".wav")
	var file_path = str(folder_path, file_name)
	var stream = ResourceLoader.load(file_path) as AudioStream
	play_sound(stream)
	
	sound.emit(sound_name)
func sidlestep():
	var s_path: String = str("sidelStep", randi_range(1, 3))
	get_node(s_path).play()
func collect():
	var sound_node: String = "none"
	
	sound_node = "collect"
	
	get_node(sound_node).play()

func land():
	var sound_node: String = str("res://Player/Sound/Movement/", current_soundpack, "/land", randi_range(1, 3), ".wav")
	var stream = ResourceLoader.load(sound_node) as AudioStream
	play_sound(stream)

func jump():
	var sound_node: String = str("res://Player/Sound/Movement/Jump/jump", randi_range(1, 3), ".wav")
	var stream = ResourceLoader.load(sound_node) as AudioStream
	play_sound(stream)
	sound.emit("jump")

func crouch(type: bool):
	var sound_node: String = str("res://Player/Sound/Movement/Crouch/SW_SFX_Player_Crouch_0", randi_range(1, 3), ".wav")if not type else str("res://Player/Sound/Movement/Crouch/SW_SFX_Player_UnCrouch_0", randi_range(1, 3), ".wav")
	var stream = ResourceLoader.load(sound_node) as AudioStream
	play_sound(stream)
func launch_hand():
	var sound_node: String = "none"
	
	sound_node = str("launch", randi_range(1, 3))
	
	get_node(sound_node).play()
	sound.emit("grabpack")
func retract_hand():
	var sound_node: String = "none"
	
	sound_node = str("retract", randi_range(1, 3))
	
	get_node(sound_node).play()
func switch_hand(type: bool = false):
	var sound_path: String = "none"
	
	if type: sound_path = "switchhand2"
	else: sound_path = "switchhand"
	
	var sound_node: AudioStreamPlayer = get_node(sound_path)
	sound_node.play()
	if type: sound_node.seek(0.37)
	#sound.seek(0.45)
func cable_sound(hand: bool, play: bool):
	var sound_node: String = "none"
	if not hand:
		sound_node = "cableloopleft"
	else:
		sound_node = "cableloopright"
	
	if play:
		get_node(sound_node).play()
	else:
		get_node(sound_node).stop()

func lower_grabpack():
	var sound_node: String = str("res://Player/Sound/Grabpack/SW_SFX_Player_Sidle_Enter_0", randi_range(1, 3), ".wav")
	var stream = ResourceLoader.load(sound_node) as AudioStream
	play_sound(stream)
func raise_grabpack():
	var sound_node: String = str("res://Player/Sound/Grabpack/SW_SFX_Player_Sidle_Exit_0", randi_range(1, 3), ".wav")
	var stream = ResourceLoader.load(sound_node) as AudioStream
	play_sound(stream)

func load_soundpack(pack_folder: String):
	current_soundpack = pack_folder

func puzzle_sfx():
	var sound_node: String = "puzzlecomplete"
	get_node(sound_node).play()
func jingle_sfx():
	var sound_node: String = "puzzlejingle"
	get_node(sound_node).play()

func play_sound(sound_stream: AudioStream):
	var new_sound: QuickSFXNoDir = QuickSFXNoDir.new()
	add_child(new_sound)
	new_sound.stream = sound_stream
	new_sound.play()
