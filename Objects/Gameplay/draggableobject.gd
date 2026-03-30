@tool
extends Node3D
class_name DraggableObject3D

@export var pull_speed = 0.001

var hand_grab: Area3D
var collision:CollisionShape3D

var grabbed: bool = false
var pulling: bool = false

@onready var object = get_parent()
@onready var hand_grab_node: HandGrab = $HandGrab
@onready var hand_position_marker: Marker3D = $HandGrab/HandPositionMarker

func _ready():
	if Engine.is_editor_hint(): return
	hand_grab_node.pulled.connect(Callable(pull_started))
	hand_grab_node.let_go.connect(Callable(released))

func pull_started(_hand: bool):
	pulling = true
func released(_hand: bool):
	pulling = false

func _physics_process(delta: float) -> void:
	if pulling:
		var direction: Vector3 = (Grabpack.player.global_position - object.global_transform.origin).normalized()
		object.apply_impulse(direction, direction * pull_speed * delta)

func _enter_tree() -> void:
	if get_node("HandGrab") == null:
		hand_grab = HandGrab.new()
		add_child(hand_grab)
		hand_grab.set_owner(get_tree().edited_scene_root)
		hand_grab.name = "HandGrab"
