extends Node3D

@export var conductive_panel: Node3D
@export var freeze_duration: float = 1.0

const gel = preload("res://Objects/Gameplay/ConductiveStuff/Textures/PoppyGel.tres")
const frozengel = preload("res://Objects/Gameplay/ConductiveStuff/Textures/FrozenPoppyGel.tres")
const gelblend_shader = preload("res://Objects/Gameplay/ConductiveStuff/Shaders/GelBlend.gdshader")

signal frozen
signal pressured

var is_frozen: bool = false
var _tween: Tween

func _ready() -> void:
	$PressureMachanic.show()
	$PressureMachanic.disable()

func _on_hand_grab_grabbed(hand: bool) -> void:
	if hand and Grabpack.right_hand.current_hand_node.name == "ConductiveHand":
		if conductive_panel.is_ice2 == true:
			$HandGrab.queue_free()
			conductive_panel._reset_uv()
			$Chilled_Release.play()
			_tween_gel_alpha()

func _tween_gel_alpha() -> void:
	var mat: ShaderMaterial = $PoppyGels/SM_Patch_F_mo.get_active_material(0).next_pass as ShaderMaterial
	if mat == null:
		push_error("No ShaderMaterial found on next_pass of SM_Patch_F_mo")
		return

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(
		func(value: float): mat.set_shader_parameter("current_alpha", value),
		mat.get_shader_parameter("current_alpha"),
		0.63,
		freeze_duration
	)
	await _tween.finished

	is_frozen = true
	frozen.emit()
	$PressureMachanic.enable()

func _on_pressure_machanic_power_100(amount: float) -> void:
	$BreakSFX.play()
	pressured.emit()
	$PoppyGels.queue_free()
	$PressureMachanic.queue_free()
