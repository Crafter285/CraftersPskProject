extends Node3D

enum grabpacktype {
	grabpack_1 = 1,
	grabpack_2_Ch4 = 2,
	grabpack_2_with_watch = 3,
	old_grabber = 4,
	grabpack_2_Ch5 = 5
}

@onready var hand_grab = $HandGrab

@export var grabpack_number: grabpacktype = grabpacktype.grabpack_1
@export var play_collect_sound: bool = true

signal collected

func collect():
	collected.emit()
	hand_grab.release_grabbed()
	if play_collect_sound:
		Grabpack.player.sound_manager.collect()
	Grabpack.switch_grabpack(grabpack_number)
	
	queue_free()

func _on_hand_grab_let_go(_hand):
	collect()
func _on_basic_interaction_player_interacted():
	collect()
