extends Node3D

@onready var item_animation: AnimationPlayer = $"../ItemAnimation"
@onready var watch = $Watch
@onready var arm_attach: BoneAttachment3D = $"../LayerWalk/CanonAttachLeft/ArmAttach"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_3d: Camera3D = $CanvasLayer/ui/SubViewportContainer/SubViewport/Camera3D

@onready var ui: Control = $CanvasLayer/ui
@onready var sub: SubViewportContainer = $CanvasLayer/ui/SubViewportContainer
@onready var buttons: Node2D = $CanvasLayer/ui/Buttons
@onready var vcr: ColorRect = $CanvasLayer/ui/ColorRect

@onready var enter: AudioStreamPlayer = $Enter
@onready var exit: AudioStreamPlayer = $Exit

var using: bool = false
var cameras: Array
var current_cam: int = 0

func _process(_delta: float) -> void:
	watch.global_transform = arm_attach.global_transform
	watch.scale = Vector3(0.008, 0.008, 0.008)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("togglewatch"):
		if animation_player.is_playing(): return
		
		if using:
			exit_watch()
		else:
			enter_watch()
func exit_watch():
	#item_animation.play("ExitWatch")
	animation_player.play_backwards("enable")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Grabpack.set_movable(true)
	ui.visible = false
	sub.visible = false
	buttons.visible = false
	vcr.visible = false
	exit.play()
	using = false
func enter_watch():
	if cameras.size() < 1: return
	
	cameras = get_tree().get_nodes_in_group("WatchCamera")
	#item_animation.play("EnterWatch")
	animation_player.play("enable")
	
	Grabpack.set_movable(false)
	camera_3d.position = cameras[current_cam].global_position
	ui.visible = true
	sub.visible = false
	buttons.visible = false
	enter.play()
	using = true
	await animation_player.animation_finished
	sub.visible = true
	buttons.visible = true
	vcr.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_button_2_pressed() -> void:
	animation_player.play("switch_cam")
	current_cam += 1
	if current_cam > (cameras.size()-1):
		current_cam = 0
	camera_3d.position = cameras[current_cam].global_position
	camera_3d.rotation = cameras[current_cam].global_rotation

func _on_button_pressed() -> void:
	cameras[current_cam].open_obstacle()

func _on_button_3_pressed() -> void:
	exit_watch()
