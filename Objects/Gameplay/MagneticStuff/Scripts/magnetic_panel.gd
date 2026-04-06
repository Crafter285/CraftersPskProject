extends Node3D

@onready var pull_mark = $PullMark

var grabbed: bool = false
var pulling_up: bool = false

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.EMU_Cuffs == true:
			if pulling_up:
				Grabpack.player.global_position = Grabpack.player.global_position.move_toward(pull_mark.global_position, 10.0 * delta)

func _on_hand_grab_grabbed(hand: bool) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.EMU_Cuffs == true:
			grabbed = true
			Grabpack.player.swinging_point = global_position

func _on_hand_grab_let_go(hand: bool) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.EMU_Cuffs == true:
			grabbed = false
			Grabpack.player.swinging = false
			pulling_up = false

func _on_hand_grab_pulled(hand: bool) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.EMU_Cuffs == true:
			pulling_up = true
			if pulling_up:
				Grabpack.player.swinging = true
