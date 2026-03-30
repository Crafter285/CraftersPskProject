extends Node3D

signal broken

func _ready() -> void:
	$Glass/PressureMachanic.show()

func _on_pressure_machanic_power_75() -> void:
	break_glass()

func _on_pressure_machanic_power_100() -> void:
	break_glass()

func break_glass():
	$Glass.queue_free()
	$GlassBreakSound.play()
	broken.emit()
