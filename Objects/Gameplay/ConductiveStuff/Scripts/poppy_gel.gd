extends Node3D

@export var conductive_machanic: Node3D
@export var pressure_machanic: Node3D
@export var mesh: MeshInstance3D
@export var freeze_duration: float = 1.0

const gel = preload("res://Objects/Gameplay/ConductiveStuff/Textures/PoppyGel.tres")
const frozengel = preload("res://Objects/Gameplay/ConductiveStuff/Textures/FrozenPoppyGel.tres")

signal frozen
signal pressured

var is_frozen: bool = false
var _tween: Tween
var _frozen_overlay: MeshInstance3D

func _ready() -> void:

	pressure_machanic.enabled = false

	conductive_machanic.is_Conductive_source = false
	conductive_machanic.enabled = true
	conductive_machanic.one_time_use = true

	mesh.set_surface_override_material(0, gel)
	_setup_frozen_overlay()

	conductive_machanic.ice_released.connect(_on_ice_released)
	pressure_machanic.power_100.connect(_on_pressure_machanic_power_100)

func _setup_frozen_overlay() -> void:
	if mesh == null:
		push_error("No mesh assigned in inspector")
		return

	_frozen_overlay = MeshInstance3D.new()
	_frozen_overlay.mesh = mesh.mesh
	_frozen_overlay.transform = mesh.transform
	mesh.get_parent().add_child(_frozen_overlay)

	var overlay_mat = frozengel.duplicate()
	overlay_mat.albedo_color.a = 0.0
	overlay_mat.render_priority = 1 
	_frozen_overlay.set_surface_override_material(0, overlay_mat)

func _tween_gel_alpha() -> void:
	if _frozen_overlay == null:
		push_error("Frozen overlay was never set up on this mesh")
		return

	var overlay_mat = _frozen_overlay.get_surface_override_material(0)
	if overlay_mat == null:
		push_error("Frozen overlay has no material")
		return

	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(overlay_mat, "albedo_color:a", 1.0, freeze_duration)
	await _tween.finished

	is_frozen = true
	frozen.emit()

	if is_instance_valid(pressure_machanic):
		pressure_machanic.enabled = true

func _on_pressure_machanic_power_100(_value) -> void:
	$BreakSFX.play()
	pressured.emit()
	mesh.queue_free()
	if is_instance_valid(_frozen_overlay):
		_frozen_overlay.queue_free()
	await get_tree().create_timer(2).timeout
	if is_instance_valid(pressure_machanic):
		pressure_machanic.queue_free()

func _on_ice_released() -> void:
	_tween_gel_alpha()
	await get_tree().create_timer(2).timeout
	if is_instance_valid(conductive_machanic):
		conductive_machanic.queue_free()
