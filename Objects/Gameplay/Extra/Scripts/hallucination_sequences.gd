extends Node3D

@export_category("Start Hallucination")
@export var fade_time_: float = 1.5
@export var start_fade_out_time: float = 0.3
@export_category("End Hallucination")
@export var fade_time__: float = 1.3
@export var wake_up_fade_time: float = 1.0
@export_category("Settings")
@export var start_Hallucination: bool = true
@export var end_Hallucination: bool = false
@export var Marker3d: Marker3D
@export var area3d: Area3D
@export var one_time_use: bool = true
@export var can_move_in_fade: bool = true
@export_group("Player Settings")
@export_subgroup("Flashlight")
@export var flashlight_: bool = false
@export var flashlight_togglable_: bool = false

@export_subgroup("Gas mask Settings")
enum mask_types {
	Normal = 0,
	Broken = 1
}

@export var gasmask_: bool = false
@export var gasmask_on_: bool = false
@export var gasmask_toggleable_: bool = false
@export var gasmask_type_: mask_types = mask_types.Normal

@export_subgroup("Grabpack Settings")
enum grabpackbluehandtype {
	Ch5 = 2,
	Ch5_old_grabber = 1,
	Ch4 = 0
}

enum grabpacktype {
	none = 0,
	grabpack_1 = 1,
	grabpack_2_Ch4 = 2,
	grabpack_2_with_wath = 3,
	old_grabber = 4,
	grabpack_2_Ch5 = 5
}

@export var grabpack_type: grabpacktype = grabpacktype.none
@export var blue_hand_type: grabpackbluehandtype = grabpackbluehandtype.Ch4
@export var has_glowby_: bool = false
@export var has_magnet_: bool = false
@export var enabled_hands_: Array [PackedScene] = [preload("res://Player/Grabpack/Hands/none.tscn")]

@onready var fade_control = $Node2D/iFadeTransition
@onready var inventory_item: InventoryItem = $InventoryItemGasMask
@onready var inventory_item_2: InventoryItem = $InventoryItemGasMaskBroken

var ono: bool = false
var _running: bool = false

signal passed_out
signal woke_up


func _ready() -> void:
	if area3d == null or Marker3d == null:
		push_error("%s: area3d and Marker3d must both be assigned." % name)
		return
	if start_Hallucination and end_Hallucination:
		push_warning("%s: both start and end are enabled; only 'start' will run." % name)

	fade_control.fade_time = _fade_in_time()
	area3d.body_entered.connect(body_entered)


func _fade_in_time() -> float:
	return fade_time_ if start_Hallucination else fade_time__


func body_entered(body: Node3D) -> void:
	if not body.is_in_group("Player"):
		return
	if ono or _running:
		return
	if not start_Hallucination and not end_Hallucination:
		return
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	_running = true
	if one_time_use:
		ono = true
	await _run_transition(player)
	_running = false


## Shared by the start and end hallucination (they were duplicated before).
func _run_transition(player) -> void:
	var is_start := start_Hallucination
	var fade_in := _fade_in_time()
	var fade_out := start_fade_out_time if is_start else wake_up_fade_time

	if not can_move_in_fade:
		player.movable = false

	fade_control.fade_time = fade_in
	fade_control.empty_to_solid()
	await get_tree().create_timer(fade_in).timeout

	if not gasmask_ and Grabpack.player != null and Grabpack.player.gasmask == true:
		Grabpack.unequip_gasmask_no_sound()

	player.global_transform = Marker3d.global_transform
	player.global_rotation = Marker3d.global_rotation

	fade_control.fade_time = fade_out
	await apply_player_settings()

	if is_start:
		passed_out.emit()
	else:
		woke_up.emit()
	
	if has_glowby_ == true:
		player.glowby_back_to_default = true
		player.glowby_enable_controls = true
	fade_control.solid_to_empty()
	await get_tree().create_timer(fade_out).timeout

	if not can_move_in_fade and is_instance_valid(player):
		player.movable = true
	fade_control.fade_time = fade_in


func apply_player_settings() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return

	player.flashlight = flashlight_
	player.flashlight_togglable = flashlight_togglable_
	player.start_with_glowby = has_glowby_
	player.glowby_back_to_default = true
	if has_glowby_:
		player.glowby_lose = true

	Grabpack.set_grabpack(grabpack_type)
	var right_hand = Grabpack.right_hand
	for i in range(right_hand.hands.size() - 1, -1, -1):
		Grabpack.remove_hand_index(i, false, false)

	var new_hands: Array[PackedScene] = enabled_hands_.duplicate()
	if new_hands.is_empty():
		new_hands.append(preload("res://Player/Grabpack/Hands/none.tscn"))
	var order: Array[PackedScene] = [new_hands[0]]
	var rest: Array[PackedScene] = new_hands.slice(1)
	rest.reverse()
	order.append_array(rest)
	for scene in order:
		Grabpack.add_hand(scene)

	right_hand.awaiting_switch = false
	right_hand.current_hand = 0
	right_hand.hand_queue = 0
	right_hand.set_hand(0)
	Grabpack.blue_hand_type(blue_hand_type)
	player.start_with_Magnet_cuffs = has_magnet_

	await get_tree().create_timer(1.0).timeout

	if Grabpack.player == null:
		return
	Grabpack.player.gasmask_type = gasmask_type_
	Grabpack.player.gasmask_toggleable = gasmask_toggleable_
	if gasmask_:
		if gasmask_type_ == mask_types.Normal:
			inventory_item.add_to_inventory()
		else:
			inventory_item_2.add_to_inventory()
		Grabpack.player.gasmask = true
		if gasmask_on_:
			Grabpack.equip_gasmask_no_sound(true, gasmask_type_)
