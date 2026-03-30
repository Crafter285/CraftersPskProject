extends CharacterBody3D

@onready var car_anim: AnimationPlayer = $AnimationPlayer
@onready var wheel_anim: AnimationPlayer = $AnimationPlayer2
@onready var hand_grab: HandGrab = $model/SM_RaceCar_Ring/HandGrab
@onready var raycast: RayCast3D = $RayCast3D
@onready var move_emitters: Node3D = $model/MoveEmitters
@onready var fire_emitters: Node3D = $model/FireEmitters

#SOUNDS
@onready var windup: AudioStreamPlayer3D = $sfx/windup
@onready var release: AudioStreamPlayer3D = $sfx/release
@onready var in_place: AudioStreamPlayer3D = $sfx/in_place
@onready var drive: AudioStreamPlayer3D = $sfx/drive
@onready var crash: AudioStreamPlayer3D = $sfx/crash
@onready var fire: AudioStreamPlayer3D = $sfx/fire

var moving: bool = false
var speed = 1000.0

func moving_emit(toggle: bool):
	for i in move_emitters.get_child_count():
		move_emitters.get_child(i).emitting = toggle
func fire_emit(toggle: bool):
	for i in fire_emitters.get_child_count():
		fire_emitters.get_child(i).emitting = toggle

func _physics_process(delta: float) -> void:
	if not moving: return
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	var input_dir = get_input_direction()
	input_dir = input_dir.normalized()
	var forward_dir = -transform.basis.z
	var movement_dir = transform.basis.x * input_dir.x + forward_dir * input_dir.z
	movement_dir = movement_dir.normalized()
	velocity.x = movement_dir.x * (speed * delta)
	velocity.z = movement_dir.z * (speed * delta)
	move_and_slide()
	
	if raycast.is_colliding():
		rotation.x = raycast.get_collision_normal().x

func get_input_direction() -> Vector3:
	var input_dir = Vector3.ZERO
	input_dir.z -= 1
	return input_dir

func _on_hand_grab_pulled(_hand: bool) -> void:
	car_anim.play("pull_string")
	car_anim.queue("pulled_loop")
	windup.play()
func _on_hand_grab_let_go(_hand: bool) -> void:
	if car_anim.current_animation == "pulled_loop":
		wheel_anim.play("spin_loop")
		moving = true
		drive.play()
		
		hand_grab.queue_free()
	else:
		release.play()
	windup.stop()
	in_place.stop()
	car_anim.play("RESET")

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	if anim_name == "pulled_loop":
		windup.stop()
		in_place.play()
		wheel_anim.play("spin_loop")
		moving_emit(true)

func _on_breaker_body_entered(body: Node3D) -> void:
	if body.is_in_group("RaceCarBreak"):
		return
	elif body.is_in_group("Player") or body == self: return
	else:
		moving_emit(false)
		fire_emit(true)
		moving = false
		car_anim.play("collide_end")
		wheel_anim.stop()
		drive.stop()
		crash.play()
		fire.play()
