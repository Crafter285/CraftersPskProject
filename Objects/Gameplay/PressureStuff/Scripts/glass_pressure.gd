extends Node3D

signal broken

func _ready() -> void:
	$Glass/PressureMachanic.show()

func _on_pressure_machanic_power_75(amount: float) -> void:
	break_glass()

func _on_pressure_machanic_power_100(amount: float) -> void:
	break_glass()

func break_glass():
	if not is_instance_valid($Glass):
		return
	$Glass.queue_free()
	$GlassBreakSound.play()
	broken.emit()
