@tool
extends Node3D

enum conductivetype {
	Electricity,
	Fire,
	Ice
}

@export var ConductiveType: conductivetype = conductivetype.Electricity:
	set(value):
		ConductiveType = value
		_update_visibility()

var is_electricity: bool = false
var is_fire: bool = false
var is_ice: bool = false
var _mat: ORMMaterial3D
var _reset_timer: Timer
var _electricity_node: Node3D
var _fire_node: Node3D
var _ice_node: Node3D
var _is_setup_done: bool = false

func _ready() -> void:
	_reset_timer = Timer.new()
	_reset_timer.wait_time = 15.0
	_reset_timer.one_shot = true
	add_child(_reset_timer)
	_reset_timer.timeout.connect(_on_reset_timer_timeout)

	_electricity_node = get_node_or_null("Electricity")
	_fire_node = get_node_or_null("Fire")
	_ice_node = get_node_or_null("Ice")

	_is_setup_done = true
	_update_visibility()

func _get_mesh() -> MeshInstance3D:
	var nodes = get_tree().get_nodes_in_group("conductive_mesh")
	if nodes.size() == 0:
		push_error("No node in group 'conductive_mesh'!")
		return null
	return nodes[0] as MeshInstance3D

func _setup_material() -> void:
	var mesh = _get_mesh()
	if mesh == null:
		return
	var original: ORMMaterial3D = load("res://Player/Grabpack/Hands/Conductive.tscn::ORMMaterial3D_2v7mq")
	if original == null:
		push_error("Could not load material!")
		return
	_mat = original.duplicate()
	mesh.set_surface_override_material(0, _mat)

func _set_uv(offset_x: float) -> void:
	if _mat == null:
		return
	_mat.uv1_scale = Vector3(0.27, 0.49, 1.0)
	_mat.uv1_offset = Vector3(offset_x, 0.315, 0.0)

func _reset_uv() -> void:
	if _mat == null:
		return
	_mat.uv1_scale = Vector3(0.27, 0.49, 1.0)
	_mat.uv1_offset = Vector3(-0.005, 0.315, 0.0)
	is_electricity2 = false
	is_fire2 = false
	is_ice2 = false

func _get_default_offset_x() -> float:
	match ConductiveType:
		conductivetype.Electricity:
			return -0.503
		conductivetype.Fire:
			return -0.748
		conductivetype.Ice:
			return -1.253
	return 0.0

func _update_visibility() -> void:
	if not _is_setup_done:
		return
	if _electricity_node == null or _fire_node == null or _ice_node == null:
		push_error("Element node(s) missing!")
		return
	match ConductiveType:
		conductivetype.Electricity:
			is_electricity = true
			is_fire = false
			is_ice = false
			_electricity_node.show()
			_fire_node.hide()
			_ice_node.hide()
		conductivetype.Fire:
			is_fire = true
			is_electricity = false
			is_ice = false
			_electricity_node.hide()
			_fire_node.show()
			_ice_node.hide()
		conductivetype.Ice:
			is_ice = true
			is_electricity = false
			is_fire = false
			_electricity_node.hide()
			_fire_node.hide()
			_ice_node.show()

func _on_reset_timer_timeout() -> void:
	_reset_uv()

var is_electricity2: bool = false
var is_fire2: bool = false
var is_ice2: bool = false

func _on_hand_grab_grabbed(hand: bool) -> void:
	if hand and Grabpack.right_hand.current_hand_node.name == "ConductiveHand":
		_setup_material()
		if is_electricity:
			is_electricity2 = true
			is_fire2 = false
			is_ice2 = false
			_set_uv(-0.503)
			$Electrical_Attacthed.play()
			$Heat_Attatched.stop()
			$Chilled_Attatched.stop()
		elif is_fire:
			is_fire2 = true
			is_electricity2 = false
			is_ice2 = false
			_set_uv(-0.748)
			$Heat_Attatched.play()
			$Electrical_Attacthed.stop()
			$Chilled_Attatched.stop()
		elif is_ice:
			is_ice2 = true
			is_fire2 = false
			is_electricity2 = false
			_set_uv(-1.253)
			$Chilled_Attatched.play()
			$Electrical_Attacthed.stop()
			$Heat_Attatched.stop()
		_reset_timer.start()
