extends Node3D

@export var Glass_cracked: bool = true

var Charge_Amount: float = 0.0

signal broken

func  _ready() -> void:
	if Glass_cracked == true:
		$Glass/MeshInstance3D.show()
		$Glass/PressureMachanic.enabled = true
	elif Glass_cracked == false:
		$Glass/MeshInstance3D.hide()
		$Glass/PressureMachanic.enabled = false

func _process(delta: float) -> void:
	if not is_instance_valid($Glass):
		return

	Charge_Amount = $Glass/PressureMachanic.charge / $Glass/PressureMachanic.max_charge

	if Charge_Amount > 0.50:
		$Glass/MeshInstance3D.hide()
		$Glass/MeshInstance3D2.show()
	
	if Charge_Amount > 0.75:
		$Glass/MeshInstance3D2.hide()
		$Glass/MeshInstance3D3.show()

func _on_pressure_machanic_power_75(amount: float) -> void:
	break_glass()

func _on_pressure_machanic_power_100(amount: float) -> void:
	break_glass()

func crack_glass():
	$Glass/MeshInstance3D.show()
	$Glass/PressureMachanic.enabled = true

func break_glass():
	if not is_instance_valid($Glass):
		return
	$Glass.queue_free()
	$GlassBreakSound.play()
	$BrokenGlass.show()
	broken.emit()
