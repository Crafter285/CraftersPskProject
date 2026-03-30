extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var open_sound: AudioStreamPlayer3D = $OpenSound

var open: bool = false

func _on_hand_grab_pulled(_hand: bool) -> void:
	if not open:
		animation_player.play("open")
		open_sound.play()
		open = true
func _on_hand_grab_let_go(_hand: bool) -> void:
	animation_player.stop()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "open":
		open = true
