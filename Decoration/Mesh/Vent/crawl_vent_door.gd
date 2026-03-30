extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var open_sound: AudioStreamPlayer3D = $OpenSound
@onready var vent: StaticBody3D = $SM_Walkable_Vent_Grate_A_mo

var open: bool = false

func _on_hand_grab_pulled(_hand: bool) -> void:
	if not open:
		animation_player.play("open")
		open_sound.play()
func _on_hand_grab_let_go(_hand: bool) -> void:
	animation_player.pause()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if vent.rotation_degrees.z < -90.0:
		open = true
