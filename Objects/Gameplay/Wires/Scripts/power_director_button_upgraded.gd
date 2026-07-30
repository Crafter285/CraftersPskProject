@tool
extends StaticBody3D

@onready var animation = $Animation
@onready var press_sound = $PressSound

## If off there is only 2 outputs, when on 3 outputs
@export var has_max_outputs: bool = true:
	set(value):
		has_max_outputs = value
		_update_visibility()

## If true, remembers which wire was active when box powers off
@export var remember_state: bool = true

enum WireSlot {Wire1 = 1, Wire2 = 2, Wire3 = 3}

@export_group("Wire Settings")
@export var power_on_time: float = 1.5
@export var power_off_time: float = 0.3
## Which wire is active when box powers on for the first time
@export var powered_cable_slot: WireSlot = WireSlot.Wire1:
	set(value):
		powered_cable_slot = value
		_check_compatibility()

@export_subgroup("Input")
## If true, skips the input wire animation (use when input wire is shared with another box output)
@export var skip_input_animation: bool = false
## The node that sends power (scanner, other box, etc)
@export var input_puzzle: NodePath
## Signal name for power on
@export var input_on_signal: String = ""
## Signal name for power off
@export var input_off_signal: String = ""
## The mesh for the incoming wire
@export var input_wire_mesh: MeshInstance3D

@export_subgroup("Wire1")
@export var output_mesh_1: MeshInstance3D

@export_subgroup("Wire2")
@export var output_mesh_2: MeshInstance3D

@export_subgroup("Wire3")
@export var output_mesh_3: MeshInstance3D

signal pressed
signal wire1_on
signal wire1_off
signal wire2_on
signal wire2_off
signal wire3_on
signal wire3_off
signal wire1_interrupted
signal wire2_interrupted
signal wire3_interrupted

const CABLE_POWER_RES = preload("res://Objects/Gameplay/Wires/VFX/Upgraded_cable_power_res.tres")
var mat_input: ShaderMaterial = null
var mat1: ShaderMaterial = null
var mat2: ShaderMaterial = null
var mat3: ShaderMaterial = null
var current_slot: int = 1
var last_slot: int = -1
var box_powered: bool = false
var is_powering_on: bool = false
var is_switching: bool = false
var active_tweens: Array = []
var _slot_fully_powered: bool = false

func _ready() -> void:
	if not Engine.is_editor_hint():
		$SM_PowerDirectingBoxPlug_A/Label3D1.hide()
		$SM_PowerDirectingBoxPlug_A2/Label3D2.hide()
		$SM_PowerDirectingBoxPlug_A3/Label3D3.hide()
		$SM_PowerDirectingBoxPlug_A4/Label3D4.hide()

		if input_wire_mesh != null and not skip_input_animation:
			input_wire_mesh.set_surface_override_material(0, CABLE_POWER_RES.duplicate())
			mat_input = input_wire_mesh.get_active_material(0).duplicate()
			input_wire_mesh.set_surface_override_material(0, mat_input)
			mat_input.set_shader_parameter("transition", 0.0)
			mat_input.set_shader_parameter("red_fade", 1.0)

		_set_black_mat(output_mesh_1)
		_set_black_mat(output_mesh_2)
		_set_black_mat(output_mesh_3)

		if output_mesh_1 != null:
			mat1 = CABLE_POWER_RES.duplicate()
			mat1.set_shader_parameter("transition", 0.0)
			mat1.set_shader_parameter("red_fade", 1.0)
		if output_mesh_2 != null:
			mat2 = CABLE_POWER_RES.duplicate()
			mat2.set_shader_parameter("transition", 0.0)
			mat2.set_shader_parameter("red_fade", 1.0)
		if output_mesh_3 != null:
			mat3 = CABLE_POWER_RES.duplicate()
			mat3.set_shader_parameter("transition", 0.0)
			mat3.set_shader_parameter("red_fade", 1.0)

		if input_puzzle and not input_puzzle.is_empty():
			var node = get_node(input_puzzle)
			print("[", name, "] input_puzzle resolved to: ", node, " | on_signal='", input_on_signal, "' off_signal='", input_off_signal, "'")
			if input_on_signal != "":
				if not node.is_connected(input_on_signal, _on_input_powered):
					node.connect(input_on_signal, _on_input_powered)
			if input_off_signal != "":
				if not node.is_connected(input_off_signal, _on_input_off):
					node.connect(input_off_signal, _on_input_off)
		else:
			print("[", name, "] WARNING: input_puzzle NodePath is empty!")

		if not is_connected("pressed", _on_pressed):
			pressed.connect(_on_pressed)

	_check_compatibility()
	_update_visibility()

func _kill_tweens():
	for t in active_tweens:
		if t and t.is_valid():
			t.kill()
	active_tweens.clear()

func _set_black_mat(mesh: MeshInstance3D):
	if mesh == null:
		return
	var black = StandardMaterial3D.new()
	black.albedo_color = Color(0, 0, 0)
	black.emission_enabled = false
	mesh.set_surface_override_material(0, black)

func _set_red(mat: ShaderMaterial, mesh: MeshInstance3D):
	if mat == null or mesh == null:
		return
	mat.set_shader_parameter("transition", 0.0)
	mat.set_shader_parameter("red_fade", 0.0)
	mesh.set_surface_override_material(0, mat)
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("red_fade", v), 0.0, 1.0, 0.5)
	active_tweens.append(tween)

func _tween_to_red(mat: ShaderMaterial, mesh: MeshInstance3D, from: float = 1.0):
	if mat == null or mesh == null:
		return
	mat.set_shader_parameter("red_fade", 1.0)
	mesh.set_surface_override_material(0, mat)
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("transition", v), from, 0.0, power_off_time)
	active_tweens.append(tween)

func _tween_to_blue(mat: ShaderMaterial, mesh: MeshInstance3D, from: float = 0.0):
	if mat == null or mesh == null:
		return null
	mat.set_shader_parameter("red_fade", 1.0)
	mesh.set_surface_override_material(0, mat)
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("transition", v), from, 1.0, power_on_time)
	active_tweens.append(tween)
	return tween

func _tween_to_black(mat: ShaderMaterial, mesh: MeshInstance3D, from: float):
	if mat == null or mesh == null:
		return
	mat.set_shader_parameter("red_fade", 1.0)
	mesh.set_surface_override_material(0, mat)
	var tween = create_tween()
	tween.tween_method(func(v): mat.set_shader_parameter("transition", v), from, 0.0, power_off_time)
	tween.finished.connect(func():
		_set_black_mat(mesh)
	, CONNECT_ONE_SHOT)
	active_tweens.append(tween)

func _emit_wire_on(slot: int):
	match slot:
		1: wire1_on.emit()
		2: wire2_on.emit()
		3: wire3_on.emit()

func _emit_wire_off(slot: int):
	match slot:
		1: wire1_off.emit()
		2: wire2_off.emit()
		3: wire3_off.emit()

func _emit_wire_interrupted(slot: int):
	match slot:
		1: wire1_interrupted.emit()
		2: wire2_interrupted.emit()
		3: wire3_interrupted.emit()

func _on_input_powered():
	print("[", name, "] _on_input_powered called | box_powered=", box_powered, " is_powering_on=", is_powering_on)
	if is_powering_on or box_powered:
		return
	is_powering_on = true
	box_powered = true
	_slot_fully_powered = false
	_kill_tweens()

	if remember_state and last_slot != -1:
		current_slot = last_slot
	else:
		current_slot = int(powered_cable_slot)

	if skip_input_animation:
		is_powering_on = false
		_set_red(mat1, output_mesh_1)
		_set_red(mat2, output_mesh_2)
		_set_red(mat3, output_mesh_3)
		_power_on_slot(current_slot)
	else:
		var cur_input = mat_input.get_shader_parameter("transition") if mat_input != null else 0.0
		var tween = _tween_to_blue(mat_input, input_wire_mesh, cur_input)
		if tween:
			tween.finished.connect(func():
				is_powering_on = false
				_set_red(mat1, output_mesh_1)
				_set_red(mat2, output_mesh_2)
				_set_red(mat3, output_mesh_3)
				_power_on_slot(current_slot)
			, CONNECT_ONE_SHOT)

func _on_input_off():
	if not box_powered:
		return
	box_powered = false
	is_switching = false
	is_powering_on = false

	if remember_state:
		last_slot = current_slot

	# Always emit the "off" signal so any downstream box listening for it
	# reliably disconnects, even if this slot never finished powering on.
	if _slot_fully_powered:
		_emit_wire_off(current_slot)
	else:
		_emit_wire_interrupted(current_slot)
		_emit_wire_off(current_slot)
	_slot_fully_powered = false

	_kill_tweens()

	for slot in [1, 2, 3]:
		var mat = _get_mat(slot)
		var mesh = _get_mesh(slot)
		if mat != null and mesh != null:
			var cur = mat.get_shader_parameter("transition")
			if cur > 0.0:
				_tween_to_black(mat, mesh, cur)
			else:
				_set_black_mat(mesh)

	if not skip_input_animation and mat_input != null:
		var cur_input = mat_input.get_shader_parameter("transition")
		_tween_to_red(mat_input, input_wire_mesh, cur_input)

func _on_pressed():
	if not box_powered or is_switching:
		return
	is_switching = true

	var leaving_slot = current_slot
	var max_slots = 3 if has_max_outputs else 2
	current_slot = (current_slot % max_slots) + 1
	_slot_fully_powered = false

	_kill_tweens()

	var cur = _get_mat(leaving_slot).get_shader_parameter("transition") if _get_mat(leaving_slot) != null else 1.0
	_tween_to_red(_get_mat(leaving_slot), _get_mesh(leaving_slot), cur)
	_emit_wire_off(leaving_slot)

	_set_red(_get_mat(current_slot), _get_mesh(current_slot))

	_power_on_slot(current_slot)

func _get_mat(slot: int) -> ShaderMaterial:
	match slot:
		1: return mat1
		2: return mat2
		3: return mat3
	return null

func _get_mesh(slot: int) -> MeshInstance3D:
	match slot:
		1: return output_mesh_1
		2: return output_mesh_2
		3: return output_mesh_3
	return null

func _power_on_slot(slot: int):
	var mat = _get_mat(slot)
	var mesh = _get_mesh(slot)
	if mat == null or mesh == null:
		return
	var from = mat.get_shader_parameter("transition")
	var tween = _tween_to_blue(mat, mesh, from)
	if tween:
		tween.finished.connect(func():
			is_switching = false
			_slot_fully_powered = true
			_emit_wire_on(slot)
		, CONNECT_ONE_SHOT)

func _check_compatibility():
	if not has_max_outputs and powered_cable_slot == WireSlot.Wire3:
		push_error("PowerDirectingBox [" + name + "]: has_max_outputs is OFF but powered_cable_slot is Wire3!")
		if not Engine.is_editor_hint():
			call_deferred("_show_error_popup", "Configuration Error on object: " + name + "\n\nhas_max_outputs is OFF (only 2 outputs) but powered_cable_slot is Wire3.\n\nHow to fix: Enable Has Max Outputs or set powered_cable_slot to Wire1 or Wire2.")

func _show_error_popup(message: String):
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var dialog = AcceptDialog.new()
	dialog.title = "Configuration Error"
	dialog.dialog_text = message
	dialog.exclusive = true
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(_quit_now)
	dialog.canceled.connect(_quit_now)

func _quit_now():
	OS.kill(OS.get_process_id())

func _update_visibility():
	if not is_node_ready():
		await ready
	$SM_PowerDirectingBoxPlug_A4.visible = has_max_outputs

func _on_hand_grab_grabbed(_hand):
	animation.play("press")
	press_sound.play()
	pressed.emit()

func _on_basic_interaction_player_interacted():
	animation.play("press")
	press_sound.play()
	pressed.emit()
