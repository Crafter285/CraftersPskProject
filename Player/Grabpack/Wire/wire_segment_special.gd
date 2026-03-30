extends Area3D

var first: bool = false
var last: bool = false
var static_pos: Vector3 = Vector3.ZERO
var look_to: Vector3 = Vector3.ZERO

var for_hand: bool = false

func _enter_tree() -> void:
	if first:
		if not for_hand: 
			Grabpack.left_hand.wire_container.end_wire()
		else:
			Grabpack.right_hand.wire_container.end_wire()

func _process(_delta: float) -> void:
	if first:
		$MeshInstance3D.mesh.bottom_radius = 0.016
		if not for_hand:
			global_position = Grabpack.left_hand.wire_container.wire_origin.global_position
		else:
			global_position = Grabpack.right_hand.wire_container.wire_origin.global_position
	else:
		global_position = static_pos
	if last:
		if not for_hand:
			look_to = Grabpack.left_hand.wire_container.wire_point.global_position
		else:
			look_to = Grabpack.right_hand.wire_container.wire_point.global_position
	
	look_at(look_to)
	scale.z = global_transform.origin.distance_to(look_to)
