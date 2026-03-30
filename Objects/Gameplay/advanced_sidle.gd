extends Path3D
class_name PathSidleZone

@export var entrance1: Area3D
@export var entrance2: Area3D

var follow: PathFollow3D
var follow_head: Marker3D

var rotation_speed: float = 5.0
var player_rotation_target: Node3D
var look_at_target: bool = false

var entering: bool = false
var enter_time: float = 0.0
var exiting: bool = false
var exit_time: float = 0.0
var in_sidle: bool = false

func _ready() -> void:
	if not has_node("PathFollow3D"):
		var new_follow: PathFollow3D = preload("res://Objects/Gameplay/path_follow_sidle.tscn").instantiate()
		add_child(new_follow)
		new_follow.name = "PathFollow3D"
	follow = $PathFollow3D
	follow_head = $PathFollow3D/followHead
	entrance1.connect("body_entered", Callable(ent1entered))
	entrance2.connect("body_entered", Callable(ent2entered))

func _physics_process(delta) -> void:
	if entering:
		if not Input.is_action_pressed("forward"):
			Grabpack.set_movable(true)
			look_at_target = false
		if not look_at_target: 
			Grabpack.player.neck.rotation.z = move_toward(Grabpack.player.neck.rotation.z, 0.0, 2.0 * delta)
			if Grabpack.player.neck.rotation.z == 0.0: entering = false
			return
		enter_time += 1.0*delta
		Grabpack.player.neck.rotation.z -= 1.0*delta
		if enter_time > 0.2:
			Grabpack.lower_grabpack()
			Grabpack.player.animation_manager.is_sidel_animation = true
			player_rotation_target = $PathFollow3D/followHead/followHeadLook
			entering = false
			in_sidle = true
	
	if in_sidle:
		var mouse_vel: Vector2 = Input.get_last_mouse_velocity()/400
		follow_head.rotation.y -= mouse_vel.x*delta
		follow_head.rotation.y = clamp(follow_head.rotation.y, -2.5, -0.8)
		follow_head.rotation.x -= mouse_vel.y*delta
		follow_head.rotation.x = clamp(follow_head.rotation.x, -1.5, 0.0)
		Grabpack.player.position = Grabpack.player.position.move_toward(follow.global_position, 2.0*delta)
		if Input.is_action_pressed("forward"):
			#Grabpack.player.animation_manager.walk_animation.play("WalkSidel")
			#Grabpack.player.animation_manager.walk_animation.speed_scale = 1.0
			
			if follow_head.rotation.y > -1.6: follow.progress += 0.6*delta
			else: follow.progress -= 0.6*delta
			
			if follow.progress_ratio > 0.95:
				exit_time = 0.0
				follow.progress -= 1.0*delta
				follow_head.rotation = Vector3.ZERO
				player_rotation_target = $PathFollow3D/followHead/followHeadLook
				in_sidle = false
				exiting = true
			if follow.progress_ratio < 0.05:
				exit_time = 0.0
				follow.progress += 1.0*delta
				follow_head.rotation = Vector3.ZERO
				follow_head.rotation.y += 3.0
				player_rotation_target = $PathFollow3D/followHead/followHeadLook
				in_sidle = false
				exiting = true
		else:
			Grabpack.player.animation_manager.animation_tree.set("parameters/WalkBlend/blend_amount", 0.0)
	
	if exiting:
		if not Input.is_action_pressed("forward"):
			exiting = false
			player_rotation_target = $PathFollow3D/followHead/followHeadLook
			in_sidle = true
		exit_time += 1.0*delta
		if exit_time > 0.3:
			exiting = false
			stop_stare()
			Grabpack.player.animation_manager.is_walking = false
			Grabpack.player.animation_manager.is_sidel_animation = false
			Grabpack.set_movable(true)
			Grabpack.raise_grabpack()
	if look_at_target and player_rotation_target:
		smooth_look_at(player_rotation_target.global_position, delta)

func smooth_look_at(target: Vector3, delta: float):
	var neck = Grabpack.player.neck
	
	var current_transform = neck.global_transform
	var target_direction = (target - current_transform.origin).normalized()

	@warning_ignore("static_called_on_instance")
	var target_basis = Basis.looking_at(target_direction, Vector3.UP)
	
	current_transform.basis = current_transform.basis.orthonormalized().slerp(target_basis, rotation_speed * delta)
	neck.global_transform = current_transform
	neck.scale = Vector3(0.4, 0.4, 0.4)

func stop_stare():
	look_at_target = false
	Grabpack.player.neck.scale = Vector3(0.4, 0.4, 0.4)
	Grabpack.player.neck.position = Vector3(0.0, 1.7, 0.0)
	Grabpack.player.neck.rotation.z = 0.0

func ent1entered(body: Node3D) -> void:
	if in_sidle: return
	if body.is_in_group("Player"):
		Grabpack.set_movable(false)
		Grabpack.player.animation_manager.is_walking = false
		follow_head.rotation_degrees.y = -50
		enter_time = 0.0
		follow.progress_ratio = 0.06
		entering = true
		look_at_target = true
		player_rotation_target = follow_head
func ent2entered(body: Node3D) -> void:
	if in_sidle: return
	if body.is_in_group("Player"):
		Grabpack.set_movable(false)
		Grabpack.player.animation_manager.is_walking = false
		follow_head.rotation_degrees.y = -150
		enter_time = 0.0
		follow.progress_ratio = 0.94
		entering = true
		look_at_target = true
		player_rotation_target = follow_head
