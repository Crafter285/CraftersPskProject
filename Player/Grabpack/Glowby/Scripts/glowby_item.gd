extends Node3D

@export var play_collect_sound: bool = true

@onready var hand_grab = $HandGrab

signal collected

func _on_hand_grab_grabbed(hand: bool) -> void:
	collect()

func _on_basic_interaction_player_interacted() -> void:
	collect()

func collect():
	if play_collect_sound == true:
		Grabpack.player.sound_manager.collect()

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.glowby_collected = true
		player.start_with_glowby = true

	collected.emit()
	queue_free()
