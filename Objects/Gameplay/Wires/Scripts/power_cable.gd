extends Node
class_name CablePower

@export var power_on_time: float = 1.5
@export var power_off_time: float = 0.3
@export var powered: bool = false
@export var puzzle: NodePath
@export var powerable_on: bool = true
@export var power_on_signal: String = ""
@export var powerable_off: bool = true
@export var power_off_signal: String = ""
@export var cable_mesh_node: MeshInstance3D
@export var toggle: bool = false
@export var toggle_signal: String = ""
@export var cable_disabler: NodePath

const CABLE_POWER_RES = preload("res://Objects/Gameplay/Wires/VFX/Upgraded_cable_power_res.tres")
var material: ShaderMaterial = null
signal cable_powered
signal cable_off
signal cable_interrupted
var uses_signals: bool = false
var active_tweens: Array = []
var _fully_powered: bool = false

func _ready():
	if cable_mesh_node != null:
		cable_mesh_node.set_surface_override_material(0, CABLE_POWER_RES.duplicate())
		material = cable_mesh_node.get_active_material(0).duplicate()
		cable_mesh_node.set_surface_override_material(0, material)
		material.set_shader_parameter("transition", 0.0)
		material.set_shader_parameter("red_fade", 1.0)
	if powerable_on and power_on_signal != "":
		get_node(puzzle).connect(power_on_signal, Callable(self, "power_on"))
	if powerable_off and power_off_signal != "":
		get_node(puzzle).connect(power_off_signal, Callable(self, "power_off"))
	if toggle and toggle_signal != "":
		get_node(puzzle).connect(toggle_signal, Callable(self, "toggle_power"))
	uses_signals = true
	if powered:
		_fully_powered = true
		material.set_shader_parameter("transition", 1.0)
	if cable_disabler and not (cable_disabler as NodePath).is_empty():
		var disabler = get_node(cable_disabler) as CableDisabler
		if disabler != null:
			disabler.setup(self)

func _kill_tweens():
	for t in active_tweens:
		if t and t.is_valid():
			t.kill()
	active_tweens.clear()

func _get_disabler() -> CableDisabler:
	if cable_disabler and not (cable_disabler as NodePath).is_empty():
		return get_node(cable_disabler) as CableDisabler
	return null

func toggle_power():
	if powered:
		power_off()
	else:
		power_on()

func power_on():
	var disabler = _get_disabler()
	if disabler != null and disabler.is_disabled():
		powered = true
		return
	powered = true
	_fully_powered = false
	_kill_tweens()
	if material == null:
		return
	cable_mesh_node.set_surface_override_material(0, material)
	var current = material.get_shader_parameter("transition")
	material.set_shader_parameter("red_fade", 1.0)
	var tween = create_tween()
	tween.tween_method(func(v): material.set_shader_parameter("transition", v), current, 1.0, power_on_time)
	tween.finished.connect(func():
		_fully_powered = true
		if uses_signals:
			cable_powered.emit()
	, CONNECT_ONE_SHOT)
	active_tweens.append(tween)

func power_off():
	var disabler = _get_disabler()
	if disabler != null and disabler.is_disabled():
		powered = false
		_fully_powered = false
		return
	powered = false
	if material == null:
		return
	if uses_signals:
		if _fully_powered:
			cable_off.emit()
		else:
			cable_interrupted.emit()
	_fully_powered = false
	var current = material.get_shader_parameter("transition")
	_kill_tweens()
	cable_mesh_node.set_surface_override_material(0, material)
	material.set_shader_parameter("red_fade", 1.0)
	var tween = create_tween()
	tween.tween_method(func(v): material.set_shader_parameter("transition", v), current, 0.0, power_off_time)
	active_tweens.append(tween)
