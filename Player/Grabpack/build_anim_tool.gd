@tool
extends Node

@export_tool_button("BuildAnim") var _build := build
@export var animation_player: AnimationPlayer
@export var node: Node3D
@export var anim_name: String
@export var interval: float = 0.1   # Time between keyframes in the animation
@export var wait_time: float = 0.1  # Delay (seconds) between adding each keyframe so you can see it happen

func _ready():
	# Make sure we can yield in the editor
	set_process(false)

func build():
	if not animation_player:
		push_error("No AnimationPlayer assigned!")
		return
	if not node:
		push_error("No node assigned!")
		return
	if not anim_name or not animation_player.has_animation(anim_name):
		push_error("Animation name invalid or not found!")
		return

	var animation: Animation = animation_player.get_animation(anim_name)
	# Remove any existing position/rotation tracks for this node
	for i in range(animation.get_track_count() - 1, -1, -1):
		if animation.track_get_path(i) == node.get_path() and (
			animation.track_get_type(i) == Animation.TYPE_POSITION_3D
			or animation.track_get_type(i) == Animation.TYPE_ROTATION_3D
		):
			animation.remove_track(i)

	# Add new tracks
	var pos_track = animation.add_track(Animation.TYPE_POSITION_3D)
	animation.track_set_path(pos_track, node.get_path())

	var rot_track = animation.add_track(Animation.TYPE_POSITION_3D)
	animation.track_set_path(rot_track, node.get_path())

	var anim_length: float = animation.length
	var t := 0.0

	print("🎬 Starting to build keyframes for '%s'..." % anim_name)
	
	await get_tree().create_timer(2.0).timeout
	while t <= anim_length:
		# Record the node's *current* position & rotation in the editor
		var pos = node.position
		var rot = node.rotation

		animation.track_insert_key(pos_track, t, pos)
		animation.track_insert_key(rot_track, t, rot)

		print("🟩 Added keyframe at t=%.2f | pos=%s | rot=%s" % [t, str(pos), str(rot)])

		t += interval
		#if not animation_player.is_playing() and t > interval-0.01:
			#animation_player.play(anim_name)

		# Wait so you can visually see it progress in the editor
		await get_tree().create_timer(wait_time).timeout

	print("✅ Done building keyframes!")
