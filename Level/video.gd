extends Node3D

func _on_grabpack_item_collected() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.grabpackbluehandtype.Ch4

func _on_console_lever_2_pulled_down() -> void:
	$ElevatorCh3.Start()

func _on_area_3d_body_entered(body: Node3D) -> void:
	Grabpack.blue_hand_type(2)
	await get_tree().create_timer(0.3).timeout
	Grabpack.remove_hand("ConductiveHand")
	Grabpack.remove_hand_index(1, false)
	Grabpack.add_hand(preload("res://Player/Grabpack/Hands/greenCh5.tscn"),1)
	Grabpack.remove_hand("PressureHand")
	Grabpack.remove_hand_index(2, false)
	Grabpack.add_hand(preload("res://Player/Grabpack/Hands/purpleCh5.tscn"),2)
	Grabpack.remove_hand("OldRedHand")
	Grabpack.remove_hand_index(0, false)
	Grabpack.add_hand(preload("res://Player/Grabpack/Hands/redCh5.tscn"),0)
