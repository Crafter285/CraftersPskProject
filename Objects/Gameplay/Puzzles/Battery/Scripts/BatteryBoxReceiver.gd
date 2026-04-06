extends Node3D

@export var start_with_battery: bool = false

signal completed

func _ready() -> void:
	if start_with_battery == true:
		if has_node("Area3D"):
			$Area3D.queue_free()
		$SM_Battery_Large_A_mo.show()
		completed.emit()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("BatteryBox"):
		$SM_Battery_Large_A_mo.show()
		completed.emit()
		body.queue_free()
