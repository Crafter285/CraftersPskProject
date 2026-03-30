extends Node3D

const WIRE_SEGMENT_ONLY = preload("res://Player/Grabpack/Wire/wire_segment_only.tscn")

@export var hand: bool = false
@export var hand_container: Node3D
@export var wire_origin: Marker3D
@export var wire_point: Marker3D
@export var wire_fake: Marker3D

var max_wire_length: float = 60.0
var last_segment: Area3D = null
var last_return: Vector3 = Vector3.ZERO
var first_segment: Area3D = null

func get_wire_length():
	#if get_child_count() > 0:
		#var child = get_child(0)
		#var distance = child.position.distance_to(child.hand_node.position)
		#var length = distance / max_wire_length
		#return length
	#return 0.0
	var length = 0.0
	for i in get_child_count():
		var child = get_child(i)
		var distance = child.scale.z
		length += distance / max_wire_length
	return length
func get_wire_distance():
	#if get_child_count() > 0:
		#var child = get_child(0)
		#var distance = child.position.distance_to(child.hand_node.position)
		#var length = distance / max_wire_length
		#return length
	#return 0.0
	var length = 0.0
	for i in get_child_count():
		var child = get_child(i)
		var distance = child.scale.z
		length += distance
	return length
func get_wire_second():
	if first_segment:
		return first_segment.next_node.global_position
	
	return hand_container.global_position

func start_wire():
	var only_segment = WIRE_SEGMENT_ONLY.instantiate()
	only_segment.hand_node = hand_container
	only_segment.next_node = wire_point
	only_segment.origin_node = wire_origin
	only_segment.visible = false
	only_segment.get_node("MeshInstance3D").mesh.bottom_radius = 0.016
	if hand:
		only_segment.get_node("MeshInstance3D").set_surface_override_material(0, preload("res://Player/Grabpack/Wire/WireMaterialRight.tres"))
	else:
		only_segment.get_node("MeshInstance3D").set_surface_override_material(0, preload("res://Player/Grabpack/Wire/WireMaterialLeft.tres"))
	only_segment.hand = hand
	add_child(only_segment)
	first_segment = only_segment
	last_segment = only_segment

func add_segment(previous, next, point):
	var new_segment = WIRE_SEGMENT_ONLY.instantiate()
	add_child(new_segment)
	
	if hand:
		new_segment.get_node("MeshInstance3D").set_surface_override_material(0, preload("res://Player/Grabpack/Wire/WireMaterialRight.tres"))
	else:
		new_segment.get_node("MeshInstance3D").set_surface_override_material(0, preload("res://Player/Grabpack/Wire/WireMaterialLeft.tres"))
	new_segment.hand = hand
	new_segment.hand_node = hand_container
	new_segment.origin_node = previous
	new_segment.next_node = next
	if next is Marker3D:
		last_segment = new_segment
	new_segment.point = point
	new_segment.global_position = point
	new_segment.look_at(next.global_position)
	new_segment.force_update_transform()
	
	if next is Area3D:
		next.origin_node = new_segment
	
	#Save Angle:
	
	new_segment.angle = 0.0
	
	return new_segment

func remove_segment(segment, previous, last):
	if previous is Area3D:
		previous.next_node = last
	if last is Area3D:
		last.origin_node = previous
	segment.queue_free()

func get_retract_path():
	if not last_segment:
		if get_child_count() == 1:
			return hand_container.hand_fake.global_position
		return last_return
	if hand_container.position.distance_to(last_segment.position) < 0.2:
		if get_child_count() == 1:
			hand_container.global_position = hand_container.hand_fake.global_position
			return hand_container.hand_fake.global_position
		remove_segment(last_segment, last_segment.origin_node, last_segment.next_node)
		last_segment = null
		return hand_container.hand_fake.global_position
	else:
		#if last_segment.origin_node is Marker3D:
			#return wire_fake.global_position
		return last_segment.position
		#last_return = last_segment.position
func end_wire():
	for i in get_child_count():
		get_child(i).queue_free()
	first_segment = null
	last_segment = null
