@tool
extends Node3D
class_name CardboardCutout

@export var voicelines: Array[AudioStream]

@onready var button: StaticBody3D = $Button
@onready var audio_stream_player: AudioStreamPlayer3D = $AudioStreamPlayer

var velocity = 0.0
var current_line: int = 0

func _ready() -> void:
	button.connect("pressed", Callable(used))

func _process(delta: float) -> void:
	if not is_equal_approx(rotation_degrees.x, 0.0):
		var target_rotation = 0.0
		var stiffness =2.0
		var damping = 0.95
		
		var force = (target_rotation - rotation_degrees.x) * stiffness
		velocity += force * delta
		velocity *= damping

		rotation_degrees.x += velocity

func used():
	velocity = 2.0
	rotation_degrees.x = 2.0
	audio_stream_player.stream = voicelines[current_line]
	audio_stream_player.play()
	current_line += 1
	if current_line > voicelines.size()-1:
		current_line = 0

func _enter_tree() -> void:
	if get_child_count() < 1:
		var new_button = preload("res://Objects/Gameplay/Pressable/button.tscn").instantiate()
		new_button.name = "Button"
		add_child(new_button)
		new_button.owner = get_tree().edited_scene_root
		var new_audio = AudioStreamPlayer3D.new()
		new_audio.name = "AudioStreamPlayer"
		add_child(new_audio)
		new_audio.owner = get_tree().edited_scene_root
