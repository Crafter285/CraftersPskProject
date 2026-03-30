extends Node3D

@onready var hand_grab = $HandGrab

@export var hand_scene: PackedScene
@export var play_collect_sound: bool = true
@export var hand_index: int = -1
@export var replace_hand_at_index: bool = false

signal collected

func collect():
	hand_grab.release_grabbed()
	if play_collect_sound:
		Grabpack.player.sound_manager.collect()
	if hand_index < 0: Grabpack.add_hand(hand_scene)
	else: 
		if replace_hand_at_index: Grabpack.remove_hand_index(hand_index, false, false)
		Grabpack.add_hand(hand_scene, hand_index)
	collected.emit()
	
	queue_free()

func _on_hand_grab_let_go(_hand):
	collect()
func _on_basic_interaction_player_interacted():
	collect()
