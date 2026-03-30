extends RigidBody3D

@export var axle_offset: Vector3 = Vector3.ZERO
@export var gear_type_idx: int = 0

@onready var item_holdable: HoldableItem = $ItemHoldable
@onready var hand_grab: HandGrab = $HandGrab
@onready var main_collision: CollisionShape3D = $CollisionShape3D

var in_axle: bool = false
var axle: StaticBody3D = null

func _on_hand_grab_let_go(hand):
	if hand: if Grabpack.right_hand.holding_object: return
	if not hand: if Grabpack.left_hand.holding_object: return
	if in_axle:
		axle.release_gear()
		in_axle = false
		axle = null
	hand_grab.release_grabbed()
	hand_grab.enabled = false
	item_holdable.start_hold(hand)
	hand_grab.update_every_frame = false

func _on_item_holdable_let_go():
	hand_grab.enabled = true
	hand_grab.update_every_frame = true

func enable_gear():
	collision_layer |= 1  # Enable layer 1
	collision_mask |= 1   # Enable mask 1
	freeze = false
func disable_gear():
	if item_holdable.holding:
		
		item_holdable.stop_hold(item_holdable.hold_hand)
	collision_layer &= ~1  # Disable layer 1
	collision_mask &= ~1   # Disable mask 1
	freeze = true
