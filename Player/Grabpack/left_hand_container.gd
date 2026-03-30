extends Node3D

@onready var grabpack = $"../.."
@onready var ray_cast_3d = $"../../../Neck/RayCast3D"
@onready var direction_cast = $DirectionCast
@onready var air_grab_point = $"../../../Neck/AirGrabPoint"
@onready var player: CharacterBody3D = $"../../.."

@onready var hand_pos = $"../LayerWalk/CanonAttachLeft/HandPos"
@onready var hand_fake = $"../LeftHandFake"
@onready var wire_container = $"../LeftWireContainer"
@onready var item_pos: Marker3D = $Hands/ItemPos

@onready var sound_manager = $"../../../SoundManager"
@onready var animation_player = $Hands/Blue/AnimationPlayer

@onready var timer = $Timer
@onready var left_auto_correct: Area3D = $"../LeftAutoCorrect"
@onready var finger_fingy: RayCast3D = $FingerFingy
@onready var left_wire_special: Node3D = $"../LeftWireSpecial"
@onready var animation: Node = $"../../GrabpackAnimationHandler"

var hand_attached: bool = true
var hand_retracting: bool = false
var hand_travelling: bool = false
var hand_normal: Vector3 = Vector3.ZERO
var hand_reached_point: bool = false
var hand_changed_point: bool = false
var hand_grab_point: Vector3 = Vector3.ZERO
var quick_retract: bool = true
var holding_object: bool = false
var hand_hold_time: float = 0.0
var pulling: bool = false
var wire_unwrap: bool = true
var wire_wrap: bool = true
var retract_click: bool = false

var retract_type = false
var hand_speed: float = 35.0
var impact_distance:float = 15.0

var exit_size: Vector3 = Vector3(1.0, 1.0, 1.0)

func _ready() -> void:
	hand_speed = player.hand_speed

func _process(_delta): if hand_attached: global_transform = hand_pos.global_transform
func _physics_process(delta: float) -> void:
	if holding_object:
		if Input.is_action_pressed("handleft") and not retract_click:
			hand_hold_time += 1.0 * delta
			if hand_hold_time > 0.32:
				holding_object = false
		elif Input.is_action_just_released("handleft"):
			if retract_click:
				retract_click = false
				return
			else:
				sort_hand_use()
				hand_hold_time = 0.0
	else:
		hand_hold_time = 0.0
		if Input.is_action_just_pressed("handleft"):
			sort_hand_use()
		elif Input.is_action_just_released("handleft"):
			if pulling:
				retract_hand()
				pulling = false
	if not hand_attached:
		scale = exit_size
		if hand_travelling:
			position = position.move_toward(hand_grab_point, hand_speed * delta)
			if position == hand_grab_point:
				hand_reached_point = true
				hand_travelling = false
				
				if not pulling:
					sound_manager.cable_sound(false, false)
				if quick_retract:
					timer.start()
				
				if hand_changed_point or not direction_cast.is_colliding(): return
				play_animation("straight")
				var target_normal = direction_cast.get_collision_normal()
				if target_normal.dot(Vector3.UP) > 0.001 or target_normal.y < 0:
					if target_normal.y > 0:
						rotation_degrees.x = -90
					elif target_normal.y < 0:
							rotation_degrees.x = 90
				else:
					look_at(global_position - target_normal)
		elif not hand_changed_point and not hand_retracting:
			if not $FingerFingy3.is_colliding():
				rotation.z += 30.0*delta
			if not finger_fingy.is_colliding():
				play_animation("grabhalf")
			else:
				play_animation("straight")
		if hand_reached_point:
			if not hand_grab_point == position:
				hand_travelling = true
				hand_reached_point = false
			else:
				position = hand_grab_point
		
		if hand_retracting:
			var next_point
			if not left_wire_special.get_child_count() > 0:
				next_point = wire_container.get_retract_path()
			else:
				if not left_wire_special.retract_paused: 
					next_point = left_wire_special.get_last_point().position
					if not left_wire_special.get_child_count() > 1:
						next_point = hand_fake.global_position
				else: next_point = position
			if next_point is bool:
				position = hand_fake.position
			else:
				position = position.move_toward(next_point, hand_speed*1.4 * delta)
				if position.distance_to(next_point) > 0.1:
					look_at(next_point, Vector3.DOWN)
					rotation.x += 3.0
			
			if position.distance_to(hand_fake.global_position) < 0.2:
				animation.hand_used(false, 1.0)
				play_animation("retract")
				sound_manager.retract_hand()
				sound_manager.cable_sound(false, false)
				wire_container.end_wire()
				left_wire_special.clear_wire()
				hand_attached = true
				hand_retracting = false
				hand_changed_point = false
				wire_unwrap = true
				wire_wrap = true

func sort_hand_use():
	if hand_attached:
		if grabpack.grabpack_lowered or not player.movable: return
		launch_hand()
	elif not hand_retracting:
		if not holding_object:
			retract_click = true
			if hand_travelling:
				retract_hand()
			if not pulling:
				pulling = true
				sound_manager.cable_sound(false, true)
func launch_hand():
	if not grabpack.grabpack_usable:
		return
	if ray_cast_3d.is_colliding():
		hand_grab_point = ray_cast_3d.get_collision_point()
		hand_normal = ray_cast_3d.get_collision_normal()
	else:
		hand_grab_point = air_grab_point.global_position
		hand_normal = Vector3.ZERO
	wire_container.start_wire()
	
	animation.hand_used(false, 0.0)
	
	play_animation("fire")
	sound_manager.launch_hand()
	sound_manager.cable_sound(false, true)
	hand_attached = false
	hand_travelling = true
	wire_wrap = true
	
	position = hand_fake.global_position
	left_auto_correct.position = hand_grab_point
	await get_tree().create_timer(0.2).timeout
	left_auto_correct.position = Vector3(0.0, -50.0, 0.0)
func retract_hand():
	if hand_attached:
		return
	if grabpack.global_position.distance_to(hand_grab_point) > impact_distance:
		retract_type = true
	else:
		retract_type = false
	play_animation("reverse")
	hand_travelling = false
	hand_reached_point = false
	hand_retracting = true
	quick_retract = true
	
	#hand_motions_animation.play("retract")
	sound_manager.cable_sound(false, true)

func play_animation(anim_name: String):
	animation_player.play(anim_name)
