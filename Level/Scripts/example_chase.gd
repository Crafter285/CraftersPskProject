extends Node3D

@onready var player_chase_start: Marker3D = $PlayerChaseStart
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_3d: Camera3D = $Camera3D
@onready var mus_in: AudioStreamPlayer = $In
@onready var mus_loop: AudioStreamPlayer = $Loop
@onready var mus_out: AudioStreamPlayer = $Out

func _on_event_trigger_triggered() -> void:
	Grabpack.lower_grabpack()
	Grabpack.set_movable(false)
	await get_tree().create_timer(0.4).timeout
	animation_player.play("cutseen")
	CameraTransition.transition_camera(Grabpack.player.camera, camera_3d, 0.2)
	await get_tree().create_timer(1.0).timeout
	Grabpack.player.global_position = player_chase_start.global_position
	Grabpack.player.neck.global_rotation = player_chase_start.global_rotation

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "cutseen":
		mus_in.play()
		CameraTransition.transition_camera(camera_3d, Grabpack.player.camera, 0.2)
		await get_tree().create_timer(0.2).timeout
		Grabpack.raise_grabpack()
		Grabpack.set_movable(true)
		Game.set_objective("RUN!")

func chase_finished() -> void:
	mus_in.stop()
	mus_loop.stop()
	mus_out.play()
