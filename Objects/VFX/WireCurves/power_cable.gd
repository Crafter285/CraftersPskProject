extends Node
class_name CablePower

@export var powered: bool = false

@export var puzzle: NodePath
@export var powerable_on: bool = true
@export var power_on_signal: String = ""
@export var powerable_off: bool = true
@export var power_off_signal: String = ""
@export var cable_mesh_node: MeshInstance3D
@export var toggle: bool = false
@export var toggle_signal: String = ""

const CABLE_POWER_RES = preload("res://Objects/VFX/WireCurves/cable_power_res.tres")
var material: ShaderMaterial = null

signal cable_powered
signal cable_off

var uses_signals: bool = false

func _ready():
	cable_mesh_node.set_surface_override_material(0, CABLE_POWER_RES)
	material = cable_mesh_node.get_active_material(0).duplicate()
	cable_mesh_node.set_surface_override_material(0, material)
	if powerable_on:
		get_node(puzzle).connect(power_on_signal, Callable(power_on))
	if powerable_off:
		get_node(puzzle).connect(power_off_signal, Callable(power_off))
	if toggle:
		get_node(puzzle).connect(toggle_signal, Callable(toggle_power))
	if powered:
		power_on()
	else:
		power_off()
	uses_signals = true

func toggle_power():
	if powered:
		power_off()
	else:
		power_on()

func power_on():
	material.set_shader_parameter("power_on", 1.0)
	powered = true
	if uses_signals: cable_powered.emit()
func power_off():
	material.set_shader_parameter("power_on", 0.0)
	powered = false
	if uses_signals: cable_off.emit()
