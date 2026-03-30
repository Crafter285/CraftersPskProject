extends Area3D

@export var Hand_Name: String = "RedHand"

signal lost_hand

func _ready() -> void:
	body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("Player") or body.name == "Player":
		Grabpack.remove_hand(Hand_Name)
		lost_hand.emit()
