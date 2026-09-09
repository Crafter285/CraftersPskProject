extends Node3D

enum conductivetype {
	Electric,
	Fire,
	Ice
}

@export var ConductiveType: conductivetype = conductivetype.Electric
@export var is_Conductive_source: bool = false
@export var enabled: bool = true
@export var one_time_use: bool = true
@export var plays_sound: bool = true

var type: int = 0
var ono: bool = false

var _mat: ORMMaterial3D
var _reset_timer: Timer
var _electricity_node: Node3D
var _fire_node: Node3D
var _ice_node: Node3D
var _is_setup_done: bool = false

signal electric_released
signal fire_released
signal ice_released
signal electric_grabbed
signal fire_grabbed
signal ice_grabbed

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

	match ConductiveType:
		conductivetype.Electric:
			type = 1
		conductivetype.Fire:
			type = 2
		conductivetype.Ice:
			type = 3

func _process(_delta: float) -> void:
	$HandGrab.enabled = enabled

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

func _get_default_offset_x() -> float:
	match ConductiveType:
		conductivetype.Electric:
			return -0.503
		conductivetype.Fire:
			return -0.748
		conductivetype.Ice:
			return -1.253
	return 0.0

func _on_reset_timer_timeout() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.reset_uv()

func _on_hand_grab_grabbed(hand: bool) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	if ono == true:
		return

	var hand_node = Grabpack.right_hand.current_hand_node
	if hand_node.name != "Conductivehand" and hand_node.name != "ConductiveHand":
		return

	if is_Conductive_source == true:
		_setup_material()
		player.conductive_mat = _mat 
		if type == 1:
			hand_node.electra()
			player.conductive_has_elec = true
			player.conductive_has_fire = false
			player.conductive_has_ice = false
			_set_uv(-0.503)
			if one_time_use == true:
				ono = true
			if plays_sound == true:
				$electric_grabbed.play()
			electric_grabbed.emit()
		elif type == 2:
			hand_node.fire()
			player.conductive_has_fire = true
			player.conductive_has_elec = false
			player.conductive_has_ice = false
			_set_uv(-0.748)
			if one_time_use == true:
				ono = true
			if plays_sound == true:
				$fire_grabbed.play()
			fire_grabbed.emit()
		elif type == 3:
			hand_node.ice()
			player.conductive_has_ice = true
			player.conductive_has_fire = false
			player.conductive_has_elec = false
			_set_uv(-1.253)
			if one_time_use == true:
				ono = true
			if plays_sound == true:
				$ice_grabbed.play()
			ice_grabbed.emit()
	else:
		if type == 1 and player.conductive_has_elec == true:
			player.reset_uv()
			if one_time_use == true:
				ono = true
			if plays_sound == true:
				$electric_released.play()
			electric_released.emit()
		elif type == 2 and player.conductive_has_fire == true:
			player.reset_uv()
			if one_time_use == true:
				ono = true
			if plays_sound == true:
				$fire_released.play()
			fire_released.emit()
		elif type == 3 and player.conductive_has_ice == true:
			player.reset_uv()
			if one_time_use == true:
				ono = true
			if plays_sound == true:
				$ice_released.play()
			ice_released.emit()
