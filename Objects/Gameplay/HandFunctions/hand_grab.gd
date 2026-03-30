@tool
extends Area3D
class_name HandGrab

enum hands {
	Both,
	OneAtATime,
	Left,
	Right
}

@export var enabled: bool = true
@export var update_every_frame: bool = false
@export var affect_position: bool = true
@export var affect_rotation: bool = true
@export var relative_to_grab_point: bool = false
@export var stop_hand: bool = true
@export var grab_animation: String = "normal"
@export var grab_marker: Marker3D
@export var only_usable_by: hands = hands.Both
@export var usable_multiple_times: bool = false
@export var usable_while_retracting: bool = false
@export var display_editor_preview: bool = false

signal grabbed(hand: bool)
signal pulled(hand: bool)
signal let_go(hand: bool)

var grabbed_left: bool = false
var grabbed_right: bool = false
var pulling_left: bool = false
var pulling_right: bool = false

var grabL: bool = false
var grabR: bool = false

var both_hand: bool = true
var only_hand: bool = false
var one_at_once: bool = false

func _ready():
	if not Engine.is_editor_hint() and grab_marker.has_node("PreviewHand"):
		grab_marker.get_node("PreviewHand").queue_free()
	connect("area_entered", Callable(hand_grabbed))
	connect("area_exited", Callable(hand_released))
	if only_usable_by == hands.Both:
		both_hand = true
	elif only_usable_by == hands.OneAtATime:
		both_hand = true
		one_at_once = true
	else:
		both_hand = false
		only_hand = only_usable_by == hands.Right

func _process(_delta):
	if Engine.is_editor_hint():
		if display_editor_preview:
			if not grab_marker.has_node("PreviewHand"):
				var new_preview_hand = preload("res://Objects/Gameplay/preview_hand.tscn").instantiate()
				grab_marker.add_child(new_preview_hand)
			
			if grab_marker.has_node("PreviewHand"):
				if grab_marker.get_node("PreviewHand").cur_anim != grab_animation:
					grab_marker.get_node("PreviewHand").play(grab_animation)
		else:
			if grab_marker.has_node("PreviewHand"):
				grab_marker.get_node("PreviewHand").queue_free()
	if enabled and not Engine.is_editor_hint():
		if grabbed_left:
			if update_every_frame:
				update_hand_position(false)
			if Grabpack.left_hand.pulling and not pulling_left:
				pulled.emit(false)
				pulling_left = true
			if (Grabpack.left_hand.hand_retracting and not usable_while_retracting) or Grabpack.left_hand.hand_attached:
				grabbed_left = false
				pulling_left = false
				emit_signal("let_go", false)
				grabL = false
		if grabbed_right:
			if update_every_frame:
				update_hand_position(true)
			if Grabpack.right_hand.pulling and not pulling_right:
				pulled.emit(true)
				pulling_right = true
			if (Grabpack.right_hand.hand_retracting and not usable_while_retracting) or Grabpack.right_hand.hand_attached:
				grabbed_right = false
				pulling_right = false
				emit_signal("let_go", true)
				grabR = false

func hand_grabbed(area):
	if enabled:
		if area.is_in_group("LeftHandArea") or area.is_in_group("LeftHandCorrecter"):
			if not Grabpack.left_hand.hand_attached and (both_hand or not only_hand) and not (grabR and one_at_once) and not (Grabpack.left_hand.hand_changed_point if not usable_multiple_times else 0.0 == 1.0):
				if not area.is_in_group("LeftHandArea"):
					if area.is_in_group("LeftHandCorrecter") and not relative_to_grab_point:
						Grabpack.left_hand.hand_grab_point = grab_marker.global_position
						return
					else:
						return
				if Grabpack.left_hand.holding_object: return
				emit_signal("grabbed", false)
				if relative_to_grab_point: 
					grab_marker.global_position = Grabpack.left_hand.global_position
					grab_marker.global_rotation = Grabpack.left_hand.global_rotation
				update_hand_position(false)
				grabL = true
		if area.is_in_group("RightHandArea") or area.is_in_group("RightHandCorrecter"):
			if not Grabpack.right_hand.hand_attached and (both_hand or only_hand) and not (grabL and one_at_once) and not (Grabpack.right_hand.hand_changed_point if not usable_multiple_times else 0.0 == 1.0):
				if not area.is_in_group("RightHandArea"):
					if area.is_in_group("RightHandCorrecter") and not relative_to_grab_point:
						Grabpack.right_hand.hand_grab_point = grab_marker.global_position
						return
					else:
						return
				if Grabpack.right_hand.holding_object: return
				emit_signal("grabbed", true)
				if relative_to_grab_point: 
					grab_marker.global_position = Grabpack.right_hand.global_position
					grab_marker.global_rotation = Grabpack.right_hand.global_rotation
				update_hand_position(true)
				grabR = true
func hand_released(_area):
	pass
	#if enabled:
		#if area.is_in_group("LeftHandArea") and grabL and (both_hand or not only_hand):
			#grabbed_left = false
			#pulling_left = false
			#emit_signal("let_go", false)
			#grabL = false
		#elif area.is_in_group("RightHandArea") and grabR and (both_hand or only_hand):
			#grabbed_right = false
			#pulling_right = false
			#emit_signal("let_go", true)
			#grabR = false

func update_hand_position(hand: bool):
	if hand:
		grabbed_right = true
		if affect_position:
			if usable_while_retracting:
				Grabpack.right_hand.position = grab_marker.global_position
			Grabpack.right_position(grab_marker.global_position)
		if affect_rotation:
			Grabpack.right_rotation(grab_marker.global_rotation)
		if stop_hand:
			Grabpack.right_cancel_auto()
		Grabpack.animate_right(grab_animation)
	else:
		grabbed_left = true
		if affect_position:
			if usable_while_retracting:
				Grabpack.left_hand.position = grab_marker.global_position
			Grabpack.left_position(grab_marker.global_position)
		if affect_rotation:
			Grabpack.left_rotation(grab_marker.global_rotation)
		if stop_hand:
			Grabpack.left_cancel_auto()
		Grabpack.animate_left(grab_animation)

func release_grabbed():
	if grabbed_left:
		Grabpack.left_retract()
	if grabbed_right:
		Grabpack.right_retract()

func _enter_tree():
	if get_child_count() == 0:
		var new_collision: CollisionShape3D = CollisionShape3D.new()
		new_collision.name = "CollisionShape3D"
		add_child(new_collision)
		new_collision.owner = get_tree().edited_scene_root
		
		var new_marker: Marker3D = Marker3D.new()
		new_marker.name = "HandPositionMarker"
		add_child(new_marker)
		new_marker.owner = get_tree().edited_scene_root
		grab_marker = new_marker

func stop_grabbing():
	grabbed_left = false
	pulling_left = false
	grabL = false
	grabbed_right = false
	pulling_right = false
	grabR = false
