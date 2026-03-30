extends Node

@onready var player = $"../.."
@onready var sound_manager: Node = $"../../SoundManager"
@onready var step_cast: RayCast3D = $"../../StepCast"
@onready var animation_tree: AnimationTree = $"../Pack/AnimationTree"
@onready var animation_player: AnimationPlayer = $"../Pack/GrabpackAnimation"
var tree: AnimationNodeBlendTree

#GRABPACKANIMATION:
var is_walking = false
var is_falling = false
var is_left_fire: bool = false
var is_right_fire: bool = false
var is_crouching = false
var is_sidel_animation = false

@onready var grabpack = $".."

func _ready():
	tree = animation_tree.tree_root

func _physics_process(delta: float) -> void:
	handle_grabpack_animation(delta)

func handle_grabpack_animation(delta):
	var speed: float = player.velocity.length()
	
	animation_tree.set("parameters/WalkBlend/blend_amount", lerp(animation_tree.get("parameters/WalkBlend/blend_amount"), 1.0 if player.walk_vel != Vector3.ZERO else 0.0, 5.0*delta))
	animation_tree.set("parameters/WalkSpeed/scale", clamp(speed/2.25, 0.05, 2.0))
	animation_tree.set("parameters/FB_Tilt/add_amount", lerp(animation_tree.get("parameters/FB_Tilt/add_amount"), -player.move_dir.y, 6.0*delta))
	animation_tree.set("parameters/LR_Tilt/add_amount", lerp(animation_tree.get("parameters/LR_Tilt/add_amount"), player.move_dir.x, 6.0*delta))
	animation_tree.set("parameters/WalkType/blend_amount", 1.0 if is_sidel_animation else 0.0)
	
	if player.move_dir != Vector2.ZERO and not is_walking: is_walking = true
	elif player.move_dir == Vector2.ZERO and is_walking:
		animation_tree.set("parameters/WalkStop/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_walking = false
	
	if not player.is_on_floor() and not is_falling: 
		if player.jump_vel != Vector3.ZERO: animation_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_falling = true
	elif player.is_on_floor() and is_falling:
		animation_tree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
		animation_tree.set("parameters/Land/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_falling = false
	
	if is_falling:
		animation_tree.set("parameters/InAir/blend_amount", lerp(animation_tree.get("parameters/InAir/blend_amount"), 1.0, 4.0*delta))
	
	if player.crouched and not is_crouching: 
		animation_tree.set("parameters/Crouch/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_crouching = true
	elif is_crouching and not player.crouched:
		animation_tree.set("parameters/Crouch/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
		animation_tree.set("parameters/UnCrouch/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		is_crouching = false

func hand_used(hand: bool, direction: float):
	if not hand:
		animation_tree.set("parameters/HandLeftInOut/blend_amount", direction)
		animation_tree.set("parameters/FireAnimationL/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	else:
		animation_tree.set("parameters/HandRightInOut/blend_amount", direction)
		animation_tree.set("parameters/FireAnimationR/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
func set_air(value: bool): animation_tree.set("parameters/InAir/blend_amount", 0.0 if not value else 1.0)
func set_lower(value: bool): animation_tree.set("parameters/LoweredPose/blend_amount", 1.0 if value else 0.0)
