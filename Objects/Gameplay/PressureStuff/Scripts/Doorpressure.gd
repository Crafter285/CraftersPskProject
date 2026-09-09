extends Node3D

@onready var pressure = $PressureMachanic
@onready var audio = $AudioStreamPlayer3D

func _ready() -> void:
	$PressureMachanic.show()
	pressure.power_25.connect(_on_pressure_machanic_power_25)
	pressure.power_50.connect(_on_pressure_machanic_power_50)
	pressure.power_75.connect(_on_pressure_machanic_power_75)
	pressure.power_100.connect(_on_pressure_machanic_power_100)

func _on_pressure_machanic_power_50(amount: float) -> void:
	break_open()

func _on_pressure_machanic_power_75(amount: float) -> void:
	break_open()

func _on_pressure_machanic_power_100(amount: float) -> void:
	break_open()

func _on_pressure_machanic_power_25(amount: float) -> void:
	not_enough()

func break_open():
	audio.play()
	$AnimationPlayer.play("DoorOpen")
	$PressureMachanic.queue_free()

func not_enough():
	audio.play()
	$AnimationPlayer.play("DoorFail")
