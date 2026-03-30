extends StaticBody3D

@onready var animation = $Animation
@onready var press_sound = $PressSound

signal pressed

func _on_hand_grab_grabbed(_hand):
	animation.play("press")
	press_sound.play()
	pressed.emit()

func _on_basic_interaction_player_interacted():
	animation.play("press")
	press_sound.play()
	pressed.emit()
