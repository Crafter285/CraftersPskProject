@tool
extends Node3D
enum Cutouttype {
	Huggy,
	Sunflower,
	Mommy,
	Dino,
	Catbee,
	CandyCat,
	BoogieBot,
	Kissy,
	Pj
}
@export var CutoutType: Cutouttype = Cutouttype.Huggy:
	set(value):
		CutoutType = value
		if Engine.is_editor_hint():
			_update_model_visibility()
@export var voice_lines: Array[AudioStream] = []
@export var play_random: bool = false
@export_range(0.0, 1.0) var volume: float = 1.0
var audio_player: AudioStreamPlayer3D
var has_played: bool = false
var current_voice_index: int = 0
signal pressed

func _ready() -> void:
	_update_model_visibility()
	if not Engine.is_editor_hint():
		_cleanup_unused_models()
		audio_player = AudioStreamPlayer3D.new()
		add_child(audio_player)

func _update_model_visibility() -> void:
	var models_node = get_node_or_null("Models")
	if not models_node:
		return
	var selected_model_name = Cutouttype.keys()[CutoutType]
	for child in models_node.get_children():
		if child is Node3D:
			child.visible = (child.name == selected_model_name)

func _cleanup_unused_models() -> void:
	var models_node = get_node_or_null("Models")
	if not models_node:
		return
	var selected_model_name = Cutouttype.keys()[CutoutType]
	for child in models_node.get_children():
		if child.name != selected_model_name:
			child.queue_free()
		else:
			child.visible = true

func get_next_voice_line() -> AudioStream:
	if voice_lines.is_empty():
		return null
	if play_random:
		return voice_lines[randi() % voice_lines.size()]
	else:
		var stream = voice_lines[current_voice_index]
		current_voice_index = (current_voice_index + 1) % voice_lines.size()
		return stream

func play_voice():
	pressed.emit()
	if audio_player:
		var stream_to_play = get_next_voice_line()
		if stream_to_play:
			if audio_player.playing:
				audio_player.stop()
			audio_player.stream = stream_to_play
			audio_player.volume_db = linear_to_db(volume)
			audio_player.play()
			has_played = true

func _on_button_pressed() -> void:
	play_voice()
