extends Node

@export var root_path : NodePath
@onready var hover: AudioStreamPlayer = $Hover
@onready var forward: AudioStreamPlayer = $Forward
@onready var backward: AudioStreamPlayer = $Backward
@onready var forward_2: AudioStreamPlayer = $Forward2

func _ready() -> void:
	assert(root_path != null, "Empty root path for UI Sounds!")
	
	#connect signals to sfx
	install_sounds(get_node(root_path))
 #or i is MenuButton or i is CheckButton

func install_sounds(node: Node) -> void:
	for i in node.get_children():
		if "on_arrow" in i:
			if i is Button:
				i.mouse_entered.connect( func(): ui_sfx_play("hover", i))
				i.pressed.connect( func(): ui_sfx_play("select", i, 1 if i.name.contains("SF2") else (2 if i.name.contains("SF3") else (-1 if i.name.contains("NSF") else 0))))
			
			#repeat
			install_sounds(i)

func ui_sfx_play(sound : StringName, button_node: Button, variation: int = 0) -> void:
	if sound == "select":
		if button_node.on_arrow != 0: return
		
		if variation == 0: forward.play()
		elif variation == 1: forward_2.play()
		elif variation == 2: backward.play()
		elif variation == -1: return
		
		return
	if hover.get_playback_position() > 0.08 or not hover.playing: 
		hover.stop()
		hover.play()
