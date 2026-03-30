extends StaticBody3D

@onready var camera = $ModelRotateY/ModelRotateX/Camera3D
@onready var hand = $ModelRotateY/ModelRotateX/Hand
@onready var canvas_layer = $CanvasLayer
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var texture_rect = $CanvasLayer/TextureRect
@onready var model_rotate_y = $ModelRotateY
@onready var model_rotate_x = $ModelRotateY/ModelRotateX
@onready var hand_point = $ModelRotateY/ModelRotateX/HandPoint
@onready var wire_container = $WireContainer
@onready var ray_cast_3d = $ModelRotateY/ModelRotateX/RayCast3D

var sens_mod: float = 1.0
var look_dir: Vector2
var using: bool = false

var hand_speed: float = 35.0
var impact_distance:float = 15.0
var hand_using: bool = false
var hand_attached: bool = true
var hand_retracting: bool = false
var hand_travelling: bool = false
var hand_grab_point: Vector3 = Vector3.ZERO
var hand_reached_point: bool = false
var wire_unwrap: bool = false
var wire_wrap: bool = true

func _unhandled_input(event):
	if not using: return
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		model_rotate_y.rotation.y = clamp(model_rotate_y.rotation.y - look_dir.x * Grabpack.player.camera_sens * sens_mod, -0.8, 0.8)
		model_rotate_x.rotation.x = clamp(model_rotate_x.rotation.x + look_dir.y * Grabpack.player.camera_sens * sens_mod, -0.5, 0.5)

func launch_hand():
	if ray_cast_3d.is_colliding():
		hand_grab_point = ray_cast_3d.get_collision_point()
	wire_container.start_wire()
	hand_attached = false
	hand_travelling = true
func retract_hand():
	if hand_attached:
		return
	hand_travelling = false
	hand_reached_point = false
	hand_retracting = true

func _process(delta):
	if hand_attached:
		hand.global_transform = hand_point.global_transform
	else:
		if hand_travelling:
			hand.position = hand.position.move_toward(hand_grab_point, hand_speed * delta)
			if hand.position == hand_grab_point:
				hand_reached_point = true
				hand_travelling = false
		if hand_reached_point:
			if not hand_grab_point == hand.position:
				hand_travelling = true
				hand_reached_point = false
			else:
				hand.position = hand_grab_point
		if hand_retracting:
			var next_point = wire_container.get_retract_path()
			if next_point is bool:
				hand.position = hand_point.global_position
			else:
				hand.position = hand.position.move_toward(next_point, hand_speed * delta)
			hand.look_at(hand_point.global_transform.origin)
			hand.rotation_degrees.y += 180
			if hand.position.distance_to(hand_point.global_position) < 0.2:
				hand_attached = true
				hand_retracting = false
				wire_unwrap = true
				wire_container.end_wire()

func _on_basic_interaction_player_interacted():
	if using:
		Grabpack.raise_grabpack()
		Grabpack.set_movable(true)
		Grabpack.hud.set_crosshair(true)
	else:
		Grabpack.lower_grabpack()
		Grabpack.set_movable(false)
		Grabpack.hud.set_crosshair(false)
	animation_player.play("Enable")
	using = !using

func set_camera():
	camera.current = using
	texture_rect.visible = using
	Grabpack.player.camera.current = !using

func play_animation(anim_name: String):
	animation_player.play(anim_name)

func _on_lever_pulled_down():
	launch_hand()
func _on_lever_pulled_up():
	retract_hand()
