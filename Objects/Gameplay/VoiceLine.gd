extends Area3D

@export_group("Settings")
@export_file("*.wav", "*.ogg", "*.mp3") var voice_path: String = ""
@export_range(0.0, 1.0) var volume: float = 1.0
@export var play_once: bool = true

@export_group("Text")
@export var show_text: bool = true
@export var name_text: String = "Name"
@export var text_content: String = "Text"
@export var name_color: Color = Color.CYAN
@export var text_color: Color = Color.WHITE

var audio_player: AudioStreamPlayer3D
var ui_label: RichTextLabel
var has_played: bool = false

func _ready():
	audio_player = AudioStreamPlayer3D.new()
	add_child(audio_player)
	
	if voice_path != "":
		var audio_stream = load(voice_path)
		if audio_stream:
			audio_player.stream = audio_stream
		else:
			push_error("Failed to load audio file: " + voice_path)
	
	if show_text:
		call_deferred("create_ui")
	
	body_entered.connect(_on_area_3d_body_entered)

func create_ui():
	ui_label = RichTextLabel.new()
	
	var name_hex = name_color.to_html()
	var text_hex = text_color.to_html()
	ui_label.bbcode_enabled = true
	ui_label.text = "[center][color=#" + name_hex + "]" + name_text + "[/color]: [color=#" + text_hex + "]" + text_content + "[/color][/center]"
	
	ui_label.anchor_left = 0.5
	ui_label.anchor_right = 0.5
	ui_label.anchor_top = 1.0
	ui_label.anchor_bottom = 1.0
	ui_label.offset_left = -500
	ui_label.offset_right = 500
	ui_label.offset_top = -150
	ui_label.offset_bottom = -50
	ui_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	ui_label.grow_vertical = Control.GROW_DIRECTION_END
	
	ui_label.add_theme_font_size_override("normal_font_size", 36)
	ui_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	ui_label.add_theme_constant_override("shadow_offset_x", 2)
	ui_label.add_theme_constant_override("shadow_offset_y", 2)
	ui_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	ui_label.add_theme_constant_override("outline_size", 4)
	
	ui_label.fit_content = true
	ui_label.scroll_active = false
	ui_label.z_index = 1000
	ui_label.visible = false
	
	get_tree().root.add_child(ui_label)

func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("Player") or body.name == "Player":
		if play_once and has_played:
			return
		
		play_voice()

func play_voice():
	if audio_player and audio_player.stream:
		audio_player.volume_db = linear_to_db(volume)
		audio_player.play()
		has_played = true
		
		if ui_label and show_text:
			ui_label.visible = true
			await audio_player.finished
			ui_label.visible = false
