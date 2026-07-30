extends Node
class_name CableDisabler

@export var power_on_time: float = 1.5
@export var power_off_time: float = 0.3
@export var start_disabled: bool = false
@export var puzzle: NodePath
@export var disable_signal: String = ""
@export var enable_signal: String = ""

signal cable_disabled
signal cable_enabled

var active_tweens: Array = []
var _disabled: bool = false
var _snapshot: float = 0.0
var _cable_power: CablePower = null

func _ready():
	if puzzle and not (puzzle as NodePath).is_empty():
		var node = get_node(puzzle)
		if disable_signal != "":
			node.connect(disable_signal, Callable(self, "disable"))
		if enable_signal != "":
			node.connect(enable_signal, Callable(self, "enable"))

func _kill_tweens():
	for t in active_tweens:
		if t and t.is_valid():
			t.kill()
	active_tweens.clear()

func is_disabled() -> bool:
	return _disabled

func setup(cable: CablePower):
	_cable_power = cable
	if start_disabled:
		_disabled = true
		_snapshot = 0.0
		_set_black_mat()

func disable():
	if _disabled or _cable_power == null or _cable_power.material == null:
		return
	_cable_power._kill_tweens()
	_snapshot = _cable_power.material.get_shader_parameter("transition")
	_disabled = true
	_kill_tweens()
	if _cable_power.uses_signals and _cable_power._fully_powered:
		_cable_power.cable_off.emit()
	_set_black_mat()
	cable_disabled.emit()

func enable():
	if not _disabled or _cable_power == null or _cable_power.material == null:
		return
	_disabled = false
	_kill_tweens()
	var mat = _cable_power.material
	var mesh = _cable_power.cable_mesh_node
	mesh.set_surface_override_material(0, mat)
	mat.set_shader_parameter("red_fade", 1.0)
	mat.set_shader_parameter("transition", _snapshot)
	if _cable_power.powered:
		var remaining_time = _cable_power.power_on_time * (1.0 - _snapshot)
		var tween = create_tween()
		tween.tween_method(func(v): mat.set_shader_parameter("transition", v), _snapshot, 1.0, remaining_time)
		tween.finished.connect(func():
			_cable_power._fully_powered = true
			if _cable_power.uses_signals:
				_cable_power.cable_powered.emit()
			cable_enabled.emit()
		, CONNECT_ONE_SHOT)
		active_tweens.append(tween)
	else:
		var remaining_time = _cable_power.power_off_time * _snapshot
		var tween = create_tween()
		tween.tween_method(func(v): mat.set_shader_parameter("transition", v), _snapshot, 0.0, remaining_time)
		tween.finished.connect(func():
			cable_enabled.emit()
		, CONNECT_ONE_SHOT)
		active_tweens.append(tween)

func _set_black_mat():
	if _cable_power == null or _cable_power.cable_mesh_node == null:
		return
	var black = StandardMaterial3D.new()
	black.albedo_color = Color(0, 0, 0)
	black.emission_enabled = false
	_cable_power.cable_mesh_node.set_surface_override_material(0, black)
