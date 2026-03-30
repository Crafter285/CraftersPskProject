extends Node

var player: CharacterBody3D = null
var grabpack: Node3D = null
var left_hand: Node3D = null
var right_hand: Node3D = null
var item_raycast: RayCast3D = null
var hud: CanvasLayer = null
var sound_manager: Node = null
var selection_wheel: bool = true

func _ready() -> void:
	selection_wheel = true

func reset_objects():
	grabpack = get_tree().get_first_node_in_group("Grabpack")
	player = get_tree().get_first_node_in_group("Player")
	hud = get_tree().get_first_node_in_group("HUD")
	sound_manager = get_tree().get_first_node_in_group("SoundManager")
	
	left_hand = get_tree().get_first_node_in_group("LeftHand")
	right_hand = get_tree().get_first_node_in_group("RightHand")
	
	item_raycast = get_tree().get_first_node_in_group("ItemRaycast")

#Movement Functions
func player_jump(height: float):
	player.external_jump(height)
func set_movable(value: bool):
	player.movable = value
func kill_player(_use_messages: bool = false):
	Game._load_no_screen("res://Interface/Death/death.tscn")
func damage_player(amount: float = 25.0):
	hud.damage.take_damage(amount)

func lower_grabpack():
	grabpack.lower_grabpack()
	if not left_hand.hand_attached: left_hand.retract_hand()
	if not right_hand.hand_attached: right_hand.retract_hand()
func raise_grabpack():
	grabpack.raise_grabpack()
func toggle_grabpack():
	if grabpack.grabpack_lowered:
		grabpack.raise_grabpack()
	else:
		grabpack.lower_grabpack()
func switch_grabpack(grabpack_idx: int):
	grabpack.switch_grabpack(grabpack_idx)
func power_wire(power_material: StandardMaterial3D, power_specific_hand: bool = false, specific_hand: bool = true):
	var wireL = load("res://Player/Grabpack/Wire/WireMaterialLeft.tres")
	var wireR = load("res://Player/Grabpack/Wire/WireMaterialRight.tres")
	if not power_specific_hand:
		wireL.next_pass = power_material
		wireR.next_pass = power_material
		grabpack.wire_powered = true
	else:
		if specific_hand:
			wireR.next_pass = power_material
		else:
			wireL.next_pass = power_material
func dispower_wire(power_specific_hand: bool = false, specific_hand: bool = true):
	var wireL = load("res://Player/Grabpack/Wire/WireMaterialLeft.tres")
	var wireR = load("res://Player/Grabpack/Wire/WireMaterialRight.tres")
	if not power_specific_hand:
		wireL.next_pass = null
		wireR.next_pass = null
		grabpack.wire_powered = false
	else:
		if specific_hand:
			wireR.next_pass = null
		else:
			wireL.next_pass = null

#MASK
func equip_gasmask(give_to_player: bool = false, give_to_player_type: int = 0):
	if give_to_player:
		player.gasmask = true
		player.gasmask_type = give_to_player_type
	hud.gas_mask.equip_mask()
func unequip_gasmask():
	hud.gas_mask.unequip_mask()
func await_unequip_mask():
	if hud.gas_mask.animation_player.is_playing():
		await hud.gas_mask.animation_player.animation_finished
		if not hud.gas_mask.equipped: return
		unequip_gasmask()
	else:
		if not hud.gas_mask.equipped: return
		unequip_gasmask()
func await_equip_mask():
	if hud.gas_mask.animation_player.is_playing():
		await hud.gas_mask.animation_player.animation_finished
		if hud.gas_mask.equipped: return
		equip_gasmask()
	else:
		if hud.gas_mask.equipped: return
		equip_gasmask()
#HAND POSITION FUNCTIONS
func left_position(new_position: Vector3):
	left_hand.hand_grab_point = new_position
	left_hand.hand_changed_point = true
func left_rotation(new_rotation: Vector3):
	left_hand.rotation = new_rotation
	left_hand.hand_changed_point = true
func left_specific_rotation_axis(axis: String, value: float):
	if axis == "x":
		left_hand.rotation.x = value
	elif axis == "y":
		left_hand.rotation.y = value
	elif axis == "z":
		left_hand.rotation.z = value
	left_hand.hand_changed_point = true
func left_transform(new_position: Vector3, new_rotation: Vector3):
	left_hand.hand_grab_point = new_position
	left_hand.rotation = new_rotation
	left_hand.hand_changed_point = true
func left_cancel_auto():
	left_hand.quick_retract = false
	left_hand.timer.stop()
func left_launch():
	left_hand.launch_hand()
func left_retract():
	left_hand.retract_hand()
func animate_left(anim_name: String):
	left_hand.play_animation(anim_name)
func left_seek(time: float):
	left_hand.animation_player.seek(time)
func left_wire_custom(first: bool = false, last: bool = false, look_at: Vector3 = Vector3.ZERO, pos: Vector3 = Vector3.ZERO):
	var new_special_wire = preload("res://Player/Grabpack/Wire/wire_segment_special.tscn").instantiate()
	
	new_special_wire.first = first
	new_special_wire.last = last
	new_special_wire.look_to = look_at
	new_special_wire.static_pos = pos
	
	left_hand.left_wire_special.add_child(new_special_wire)

func right_position(new_position: Vector3):
	right_hand.hand_grab_point = new_position
	right_hand.hand_changed_point = true
func right_rotation(new_rotation: Vector3):
	right_hand.rotation = new_rotation
	right_hand.hand_changed_point = true
func right_specific_rotation_axis(axis: String, value: float):
	if axis == "x":
		right_hand.rotation.x = value
	elif axis == "y":
		right_hand.rotation.y = value
	elif axis == "z":
		right_hand.rotation.z = value
	right_hand.hand_changed_point = true
func right_transform(new_position: Vector3, new_rotation: Vector3):
	right_hand.hand_grab_point = new_position
	right_hand.rotation = new_rotation
	right_hand.hand_changed_point = true
func right_cancel_auto():
	right_hand.quick_retract = false
	right_hand.timer.stop()
func right_launch():
	right_hand.launch_hand()
func right_retract():
	right_hand.retract_hand()
func animate_right(anim_name: String):
	right_hand.play_animation(anim_name)
func right_seek(time: float):
	right_hand.seek_animation(time)
func right_disable():
	right_hand.disable_hand()
func right_enable():
	right_hand.enable_hand()
func right_wire_custom(first: bool = false, last: bool = false, look_at: Vector3 = Vector3.ZERO, pos: Vector3 = Vector3.ZERO):
	var new_special_wire = preload("res://Player/Grabpack/Wire/wire_segment_special.tscn").instantiate()
	
	new_special_wire.first = first
	new_special_wire.last = last
	new_special_wire.look_to = look_at
	new_special_wire.static_pos = pos
	new_special_wire.for_hand = true
	
	right_hand.right_wire_special.add_child(new_special_wire)
func hand_check_for_use_as(hand_name: String):
	if right_hand.current_hand_node:
		if right_hand.current_hand_node.name == hand_name: return true
		if right_hand.current_hand_node.has_node("MultiHand"):
			var multi_hand = right_hand.current_hand_node.get_node("MultiHand")
			for i in multi_hand.usable_as_hands.size():
				if multi_hand.usable_as_hands[i] == hand_name:
					return true
	return false

func add_hand(hand_scene: PackedScene, hand_idx: int = -1):
	var hand_instance = hand_scene.instantiate()
	if not hand_instance.has_node("Useless"):
		var inventory_icon: Texture2D = null
		var description = null
		if hand_instance.has_node("HandInventoryIcon"):
			var inventory_item_icon = hand_instance.get_node("HandInventoryIcon")
			inventory_icon = inventory_item_icon.icon
			if inventory_item_icon.has_description:
				description = inventory_item_icon.description
		
		var item_array: Array = [hand_instance.name, inventory_icon]
		if description:
			item_array.append(description)
		Inventory.items_Equipment.append(item_array)
	hand_instance.queue_free()
	if hand_idx < 0: right_hand.hands.append(hand_scene)
	else: right_hand.hands.insert(hand_idx, hand_scene)
	var index: int = hand_idx if hand_idx > -1 else 10
	right_hand.queue_hand_switch(index)
func remove_hand(hand_name: String, replace_with_none: bool = true, auto_fix_hand: bool = true):
	var hand_idx: int = 0
	for i in right_hand.hands.size():
		var hand_instance = right_hand.hands[i].instantiate()
		if hand_instance.name == hand_name:
			hand_idx = i
		hand_instance.queue_free()
	if replace_with_none:
		right_hand.hands[hand_idx] = preload("res://Player/Grabpack/Hands/none.tscn")
	else:
		right_hand.hands.remove_at(hand_idx)
	Inventory.remove_item("items_Equipment", hand_name)
	
	if right_hand.current_hand == hand_idx and auto_fix_hand:
		if replace_with_none:
			right_hand.set_hand(hand_idx)
		else:
			right_hand.set_hand(hand_idx-1)
func remove_hand_index(hand_idx: int, replace_with_none: bool = true, auto_fix_hand: bool = true):
	var hand_name: String = ""
	
	var hand_instance = right_hand.hands[hand_idx].instantiate()
	hand_name = hand_instance.name
	hand_instance.queue_free()
	
	if replace_with_none:
		right_hand.hands[hand_idx] = preload("res://Player/Grabpack/Hands/none.tscn")
	else:
		right_hand.hands.remove_at(hand_idx)
	Inventory.remove_item("items_Equipment", hand_name)
	
	if right_hand.current_hand == hand_idx and auto_fix_hand:
		if replace_with_none:
			right_hand.set_hand(hand_idx)
		else:
			right_hand.set_hand(hand_idx-1)
func get_hand():
	return Grabpack.right_hand.current_hand_node.name
func has_hand(hand_name: String):
	var hand: bool = false
	for i in right_hand.hands.size():
		var hand_instance = right_hand.hands[i].instantiate()
		if hand_instance.name == hand_name: hand = true
		hand_instance.queue_free()
	return hand
func get_hand_idx(hand_name: String):
	var hand_id: int = -1
	for i in right_hand.hands.size():
		var hand_instance = right_hand.hands[i].instantiate()
		if hand_instance.name == hand_name: hand_id = i
		hand_instance.queue_free()
	return hand_id
