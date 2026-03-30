extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	Game.set_objective("Follow The Very Obvious Fucking Path")


func _on_keypad_code_success() -> void:
	Game.end()


func _on_jump_pad_player_jumped() -> void:
	Grabpack.right_disable()


func _on_event_trigger_triggered() -> void:
	Grabpack.unequip_gasmask()
