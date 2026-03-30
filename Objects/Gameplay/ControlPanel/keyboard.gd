extends StaticBody3D

@onready var basic_interaction: BasicInteraction = $BasicInteraction
@onready var click: AudioStreamPlayer3D = $Click
@onready var hand_grab: HandGrab = $HandGrab

@export var one_time_use: bool = true

var used_board: bool = false

signal pressed

func used():
	if one_time_use and used_board: return
	click.play()
	used_board = true
	pressed.emit()
	if one_time_use:
		basic_interaction.queue_free()

func _on_basic_interaction_player_interacted() -> void:
	used()
func _on_hand_grab_grabbed(_hand: bool) -> void:
	used()
