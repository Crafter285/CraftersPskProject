extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_3d: Camera3D = $Camera3D
@onready var long_legs: CharacterBody3D = $Puzzle/LongLegs
@onready var gate_2: StaticBody3D = $Puzzle/Gate2
@onready var gate_5: StaticBody3D = $Puzzle/Gate5
@onready var door_3: StaticBody3D = $Puzzle/Door3
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var huggy_wuggy: CharacterBody3D = $HuggyWuggy

var chase_start_pos: Vector3 = Vector3(-5.696, 5.6, 27.956)

var bat1: bool = false
var key1: bool = false

func _ready() -> void:
	camera_3d.current = true
	animation_player.play("Intro")
	Grabpack.player.visible = false
	await animation_player.animation_finished
	CameraTransition.transition_camera(camera_3d, Grabpack.player.camera, 0.5)
	await get_tree().create_timer(0.5).timeout
	animation_player.play("Crusher")
	Grabpack.player.visible = true
	Grabpack.raise_grabpack()
	Grabpack.set_movable(true)

func _on_event_trigger_triggered() -> void:
	animation_player.play("ChaseStart")
	gate_5.opengate()
	Grabpack.lower_grabpack()
	Grabpack.set_movable(false)
	await get_tree().create_timer(0.3).timeout
	await CameraTransition.transition_camera(Grabpack.player.camera, camera_3d, 0.4)
	animation_player.play("Chase")
	long_legs.set_state(2)
	Grabpack.player.position = chase_start_pos
	Grabpack.player.neck.global_rotation_degrees = Vector3(0.0, -90.0, 0.0)
	await animation_player.animation_finished
	await CameraTransition.transition_camera(camera_3d, Grabpack.player.camera, 0.4)
	Grabpack.raise_grabpack()
	Grabpack.set_movable(true)

func _on_event_trigger_triggered2() -> void:
	gate_2.fastclose()
	long_legs.set_state(0)
	long_legs.queue_free()

func _on_console_battery_socket_powered_on() -> void:
	bat1 = true
	if bat1 and key1:
		door_3.locked = false
		door_3.opendoor()
func _on_keycard_reader_2_inserted() -> void:
	key1 = true
	if bat1 and key1:
		door_3.locked = false
		door_3.opendoor()

func _on_huggy_wuggy_jumpscare_finished() -> void:
	color_rect.visible = true
	color_rect.color = Color.BLACK
	Game.load_scene("res://Level/test_map.tscn")

func _on_event_trigger_triggered3() -> void:
	Grabpack.lower_grabpack()
	Grabpack.set_movable(false)
	camera_3d.global_position = Grabpack.player.neck.global_position
	camera_3d.look_at(huggy_wuggy.raycast.global_position)
	
	door_3.closedoor()
	var tween = create_tween()
	tween.tween_property(Grabpack.player.neck, "global_rotation", camera_3d.global_rotation, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween.finished
	
	huggy_wuggy.set_state(2)
	huggy_wuggy.visible = true
	
