@tool
extends Node

@warning_ignore("unused_private_class_variable")
@export_tool_button("Fix Rotations") var _fix := fix_rotations
@export var animation_player: AnimationPlayer
@export var anim_name: String
@export var track_name: String = ""
@export var node: Node3D
@export var y_default: float = -180
@export var z_default: float = 180
@warning_ignore("unused_private_class_variable")
@export_tool_button("Fix Positions") var _pfix := fix_positions
@export var position_offset: Vector3
@export var animation_track: String  = ""

func fix_rotations():
	if not animation_player:
		push_error("No AnimationPlayer assigned!")
		return
	if not anim_name or not animation_player.has_animation(anim_name):
		push_error("Animation name invalid or not found!")
		return

	var animation: Animation = animation_player.get_animation(anim_name)

	print("🧭 Checking rotation tracks in '%s'..." % anim_name)
	var track: int
	for i in range(animation.get_track_count() - 1, -1, -1):
		if str(animation.track_get_path(i)) == track_name: track = i
	print(track)
	
	for i in animation.track_get_key_count(track):
		var key_value: Vector3 = animation.track_get_key_value(track, i)
		if animation.track_get_key_value(track, i).y < deg_to_rad(y_default-200.0):
			key_value.y += deg_to_rad(360.0)
		elif animation.track_get_key_value(track, i).y > deg_to_rad(y_default+200.0):
			key_value.y -= deg_to_rad(360.0)
		if animation.track_get_key_value(track, i).z < deg_to_rad(z_default-200.0):
			key_value.z += deg_to_rad(360.0)
		elif animation.track_get_key_value(track, i).z > deg_to_rad(z_default+200.0):
			key_value.z -= deg_to_rad(360.0)
		print(key_value)
		animation.track_set_key_value(track, i, key_value)
	#var key_count = animation.track_get_key_count(track_index)
#
	#for i in range(1, key_count):
		#var rot: Vector3 = animation.track_get_key_value(track_index, i)
		#var fixed_rot = rot
#
		#for axis in ["x", "y", "z"]:
			#var diff = rad2deg(fixed_rot[axis]) - rad2deg(prev_rot[axis])
#
			## Detect wrap-around (e.g. jump from -179° to 179°)
			#if diff > threshold_degrees:
				#fixed_rot[axis] -= deg2rad(360.0)
			#elif diff < -threshold_degrees:
				#fixed_rot[axis] += deg2rad(360.0)
#
		#if fixed_rot != rot:
			#animation.track_set_key_value(track_index, i, fixed_rot)
			#print("    🔧 Fixed keyframe", i, ":", rot, "→", fixed_rot)
#
		#prev_rot = fixed_rot

	print("✅ Rotation cleanup complete!")
func fix_positions():
	if not animation_player:
		push_error("No AnimationPlayer assigned!")
		return
	if not anim_name or not animation_player.has_animation(anim_name):
		push_error("Animation name invalid or not found!")
		return

	var animation: Animation = animation_player.get_animation(anim_name)

	var track: int
	for i in range(animation.get_track_count() - 1, -1, -1):
		if str(animation.track_get_path(i)) == animation_track: track = i
	print(track)
	
	for i in animation.track_get_key_count(track):
		var key_value: Vector3 = animation.track_get_key_value(track, i)
		key_value+=position_offset
		print(key_value)
		animation.track_set_key_value(track, i, key_value)
	#var key_count = animation.track_get_key_count(track_index)
#
	#for i in range(1, key_count):
		#var rot: Vector3 = animation.track_get_key_value(track_index, i)
		#var fixed_rot = rot
#
		#for axis in ["x", "y", "z"]:
			#var diff = rad2deg(fixed_rot[axis]) - rad2deg(prev_rot[axis])
#
			## Detect wrap-around (e.g. jump from -179° to 179°)
			#if diff > threshold_degrees:
				#fixed_rot[axis] -= deg2rad(360.0)
			#elif diff < -threshold_degrees:
				#fixed_rot[axis] += deg2rad(360.0)
#
		#if fixed_rot != rot:
			#animation.track_set_key_value(track_index, i, fixed_rot)
			#print("    🔧 Fixed keyframe", i, ":", rot, "→", fixed_rot)
#
		#prev_rot = fixed_rot

	print("✅ Rotation cleanup complete!")
