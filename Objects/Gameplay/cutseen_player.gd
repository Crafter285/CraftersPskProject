extends Node
class_name CutscenePlayer

@export var cutseen_camera: Camera3D
@export var camera_transition_length_in: float = 1.0
@export var camera_transition_length_out: float = 1.0
@export var autoplay: bool = false
@export var lower_grabpack: bool = true
@export var attach_grabpack_to_camera: bool = false
@export var use_player_offset_to_camera: bool = false
##Required if using player offset
@export var cutseen_animation_marker: Marker3D
@export var spawn_player_at_cutseen_end: bool = false
@export var use_player_fov: bool = false

@export_group("Animation")
@export var play_with_animation: bool = false
@export var animation_player: AnimationPlayer
@export var animation_name: String = ""

var in_progress: bool = false
var transition_in_progress: bool = false

func _ready() -> void:
	if autoplay:
		await Game.delay(0.5)
		start()

func _process(_delta: float) -> void:
	if (in_progress or transition_in_progress) and attach_grabpack_to_camera:
		if transition_in_progress: Grabpack.player.neck.global_transform = CameraTransition.camera.global_transform
		else: Grabpack.player.neck.global_transform = cutseen_camera.global_transform
		Grabpack.grabpack.position = Grabpack.player.neck.position

func start():
	cutseen_camera.fov = Grabpack.player.camera.fov
	Grabpack.set_movable(false)
	
	if lower_grabpack and not Grabpack.grabpack.grabpack_lowered: Grabpack.lower_grabpack()
	if use_player_offset_to_camera: cutseen_camera.global_position = Grabpack.player.camera.global_position
	
	in_progress = true
	transition_in_progress = true
	CameraTransition.transition_camera(Grabpack.player.camera, cutseen_camera, camera_transition_length_in)
	await Game.delay(camera_transition_length_in)
	
	transition_in_progress = false
	if play_with_animation:
		animation_player.play(animation_name)
		await animation_player.animation_finished
		exit()

func exit():
	
	in_progress = false
	transition_in_progress = true
	
	Grabpack.player.neck.position = Vector3.ZERO
	Grabpack.player.neck.position.y += 1.7
	Grabpack.player.neck.scale = Vector3(0.4, 0.4, 0.4)
	Grabpack.grabpack.position = Grabpack.player.neck.position
	if spawn_player_at_cutseen_end:
		Grabpack.player.global_position = cutseen_camera.global_position
		Grabpack.player.position.y -= 1.693
		Grabpack.player.neck.global_rotation = cutseen_camera.global_rotation
		Grabpack.player.neck.rotation.z = 0.0
	
	CameraTransition.transition_camera(cutseen_camera, Grabpack.player.camera, camera_transition_length_out)
	await Game.delay(camera_transition_length_out)
	
	Grabpack.player.neck.position = Vector3.ZERO
	Grabpack.player.neck.position.y += 1.7
	Grabpack.player.neck.scale = Vector3(0.4, 0.4, 0.4)
	Grabpack.grabpack.position = Grabpack.player.neck.position
	if spawn_player_at_cutseen_end:
		Grabpack.player.global_position = cutseen_camera.global_position
		Grabpack.player.position.y -= 1.693
		Grabpack.player.neck.global_rotation = cutseen_camera.global_rotation
		Grabpack.player.neck.rotation.z = 0.0
	if lower_grabpack: Grabpack.raise_grabpack()
	Grabpack.set_movable(true)
	transition_in_progress = false
