extends CharacterBody3D
class_name KissyCharacter

enum Mode {
	FOLLOW_PLAYER,
	FOLLOW_PATH
}

@export_category("Behavior")
@export var mode: Mode = Mode.FOLLOW_PLAYER
@export var player: Node3D
@export var path_3d: Path3D

@export_category("Movement")
@export var walk_speed: float = 3.0
@export var rotation_speed: float = 8.0

@export_category("Distance Settings")
@export var stop_distance: float = 2.5

@export_category("Path Settings")
@export var loop_path: bool = false
@export var follow_player_after_path: bool = true

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var model_root: Node3D = $SK_Kissy_Injured_LOD0_ao

var path_follower: PathFollow3D
var current_animation: String = ""
var gravity: float = 9.8
var path_completed: bool = false

func _ready():
	if not anim_player:
		anim_player = get_node_or_null("AnimationPlayer")
	if not model_root:
		model_root = get_node_or_null("SK_Kissy_Injured_LOD0_ao")
	
	if mode == Mode.FOLLOW_PATH and path_3d:
		_setup_path_follower()

func _setup_path_follower():
	path_follower = PathFollow3D.new()
	path_follower.loop = loop_path
	path_3d.add_child(path_follower)
	global_position = path_follower.global_position
	path_completed = false

func _physics_process(delta):
	match mode:
		Mode.FOLLOW_PLAYER:
			_follow_player_logic(delta)
		Mode.FOLLOW_PATH:
			_follow_path_logic(delta)

func _follow_player_logic(delta):
	if not player:
		velocity = Vector3.ZERO
		_play_anim("Kissy_idle")
		move_and_slide()
		return
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	var direction = to_player.normalized()
	
	direction.y = 0
	direction = direction.normalized()
	
	if distance < stop_distance:
		velocity.x = 0
		velocity.z = 0
		_play_anim("Kissy_idle")
	else:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
		_play_anim("Kissy_walk")
		_rotate_towards(player.global_position, delta)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()

func _follow_path_logic(delta):
	if not path_follower or not path_3d:
		_play_anim("Kissy_idle")
		return
	
	if not loop_path and path_follower.progress_ratio >= 1.0:
		if not path_completed:
			path_completed = true
			_play_anim("Kissy_idle")
			
			if follow_player_after_path:
				print("Path completed! Switching to follow player mode.")
				switch_to_follow_player()
		return
	
	path_follower.progress += walk_speed * delta
	
	global_position = path_follower.global_position
	
	var old_progress = path_follower.progress
	path_follower.progress += 1.0
	var look_target = path_follower.global_position
	path_follower.progress = old_progress
	
	_rotate_towards(look_target, delta)
	_play_anim("Kissy_walk")

func _rotate_towards(target_pos: Vector3, delta: float):
	if not model_root:
		return
	
	var direction = target_pos - global_position
	direction.y = 0
	
	if direction.length() < 0.01:
		return
	
	var target_angle = atan2(direction.x, direction.z)
	
	model_root.rotation.y = lerp_angle(model_root.rotation.y, target_angle, rotation_speed * delta)

func _play_anim(anim_name: String):
	if not anim_player or not anim_player.has_animation(anim_name):
		return
	
	if current_animation != anim_name:
		anim_player.play(anim_name)
		current_animation = anim_name

func switch_to_follow_player():
	mode = Mode.FOLLOW_PLAYER

func switch_to_follow_path():
	mode = Mode.FOLLOW_PATH
	path_completed = false
	if not path_follower and path_3d:
		_setup_path_follower()

func set_player_target(new_player: Node3D):
	player = new_player

func restart_path():
	if path_follower:
		path_follower.progress = 0
		path_completed = false
