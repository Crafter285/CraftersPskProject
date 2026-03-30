extends Node3D

@export var start_point: Node3D  # The object where the rope starts
@export var end_point: Node3D    # The object where the rope ends
@export var rope_mesh: MeshInstance3D  # The visual representation of the rope
@export var max_anchors: int = 5 # Max number of anchor points to avoid infinite loops

var anchors: Array[Vector3]  # List of anchor points

func _process(_delta):
	update_rope()

func update_rope():
	var points = [start_point.global_transform.origin]
	var last_point = start_point.global_transform.origin
	
	# Check for obstacles
	for i in range(anchors.size()):
		if not is_obstacle_between(last_point, anchors[i]):
			anchors.remove_at(i)
			break
		points.append(anchors[i])
		last_point = anchors[i]
	
	# If new obstacle detected, add anchor point
	var obstacle_point = get_obstacle_point(last_point, end_point.global_transform.origin)
	if obstacle_point != Vector3.ZERO and anchors.size() < max_anchors:
		anchors.append(obstacle_point)
	
	points.append(end_point.global_transform.origin)
	update_mesh(points)

func is_obstacle_between(from_pos: Vector3, to_pos: Vector3) -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func get_obstacle_point(from_pos: Vector3, to_pos: Vector3) -> Vector3:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from_pos, to_pos)
	var result = space_state.intersect_ray(query)
	if result:
		return result.position  # Return the collision point to use as an anchor
	return Vector3.ZERO

func update_mesh(points: Array):
	# Clear previous rope segments
	for child in get_children():
		if child is MeshInstance3D:
			remove_child(child)
			child.queue_free()
	
	# Create new rope segments
	for i in range(points.size() - 1):
		var segment = MeshInstance3D.new()
		var mesh = CylinderMesh.new()
		mesh.top_radius = 0.05
		mesh.bottom_radius = 0.05
		mesh.height = (points[i] - points[i + 1]).length()
		segment.mesh = mesh
		
		# Correctly orient the segment along the rope direction
		var direction = (points[i + 1] - points[i]).normalized()
		var mid_point = (points[i] + points[i + 1]) * 0.5
		
		var transform = Transform3D().looking_at(direction)
		transform.origin = mid_point
		
		segment.transform = transform
		
		add_child(segment)
