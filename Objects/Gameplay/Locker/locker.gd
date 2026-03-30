extends StaticBody3D

@onready var camera: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var npc_pos: Marker3D = $NpcPos
@onready var ui_anim_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var breathing: AudioStreamPlayer = $Breathing

var moving_in: bool = false
var in_locker: bool = false
var can_exit: bool = true

var breath_time: float = 0.0
var holding_breath: bool = false
var out_of_breath: float = false
var hold_prev: bool = false

signal locker_exited
signal locker_entered

func _ready() -> void:
	camera.fov = GameSettings.fov

func _process(delta: float) -> void:
	if in_locker and not moving_in:
		if Input.is_action_pressed("jump") and not out_of_breath and not breathing.is_fading():
			if not holding_breath: ui_anim_player.play("gone")
			holding_breath = true
		elif not breathing.is_fading(): holding_breath = false
		if out_of_breath: holding_breath = false
		if holding_breath:
			$CanvasLayer/Label.text = "HOLD SPACE TO HOLD YOUR BREATH"
			breath_time += 1.0 * delta
			if breath_time > 4.0:
				ui_anim_player.play("loop")
				$CanvasLayer/Label.text = "OUT OF BREATH"
				out_of_breath = true
				$OutOfBreath.play()
		else:
			ui_anim_player.play("loop")
			if breath_time > 0.0: breath_time -= 1.0 * delta
			else:
				$CanvasLayer/Label.text = "HOLD SPACE TO HOLD YOUR BREATH"
				out_of_breath = false
				breath_time = 0.0
		
		if holding_breath and not hold_prev: breathing.fadeOut(50.0)
		if hold_prev and not holding_breath and not out_of_breath: breathing.fadeIn(50.0)
		if not out_of_breath: hold_prev = holding_breath
		
		if Input.is_action_just_pressed("interact"):
			exit_locker()
			return

func enter_locker():
	locker_entered.emit()
	$EnterSound.play()
	
	camera.fov = GameSettings.fov
	camera.transform = $CameraStart.transform
	moving_in = true
	in_locker = true
	
	Grabpack.set_movable(false)
	Grabpack.lower_grabpack()
	CameraTransition.transition_camera(Grabpack.player.camera, camera, 0.2)
	
	breathing.fadeIn(40.0)
	animation_player.play("Open")
	await get_tree().create_timer(0.3).timeout
	Grabpack.player.position.y -= 20.0
	Grabpack.player.hide()
	await animation_player.animation_finished
	
	
	moving_in = false
func exit_locker():
	if breathing.is_fading() or not can_exit: return
	
	ui_anim_player.play("gone")
	
	$ExitSound.play()
	camera.fov = GameSettings.fov
	moving_in = true
	in_locker = false
	breathing.fadeOut(40.0)
	
	Grabpack.player.global_transform = $PlayerExit.global_transform
	Grabpack.player.neck.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	
	animation_player.play("Close")
	await get_tree().create_timer(0.8).timeout
	$OutOfBreath.playing = false
	CameraTransition.transition_camera(camera, Grabpack.player.camera, 0.3)
	await get_tree().create_timer(0.3).timeout
	Grabpack.player.show()
	Grabpack.set_movable(true)
	Grabpack.raise_grabpack()
	
	locker_exited.emit()
	moving_in = false

func _on_basic_interaction_player_interacted() -> void:
	if not in_locker and not moving_in: enter_locker()

func monster_search():
	animation_player.play("LockerShake")
