extends Area3D

signal lost_grabpack

func _ready() -> void:
	body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("Player") or body.name == "Player":
		Grabpack.switch_grabpack(0)
		lost_grabpack.emit()
