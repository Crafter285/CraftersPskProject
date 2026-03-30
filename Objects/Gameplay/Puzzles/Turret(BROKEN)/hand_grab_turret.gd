@tool
extends Area3D
class_name HandGrabTurret

@export var enabled: bool = true
@export var affect_position: bool = true
@export var affect_rotation: bool = true
@export var grab_marker: Marker3D

signal grabbed(hand: Node3D)
signal let_go(hand: Node3D)

var held: bool = false
var hand_node: Node3D = null

func _ready():
	connect("area_entered", Callable(hand_grabbed))
	connect("area_exited", Callable(hand_released))

func _process(_delta):
	if enabled and not Engine.is_editor_hint():
		if held:
			update_hand_position()
			if hand_node.hand_retracting:
				held = false
				emit_signal("let_go", hand_node)

func hand_grabbed(area):
	if enabled:
		if area.is_in_group("TurretHand"):
			hand_node = area.get_parent().get_parent().get_parent().get_parent()
			update_hand_position()
			emit_signal("grabbed", hand_node)
			held = true

func hand_released(area):
	if enabled:
		if area.is_in_group("TurretHand"):
			emit_signal("let_go", hand_node)
			held = false
func release_grip():
	held = false

func update_hand_position():
	if held:
		if affect_position:
			hand_node.hand_grab_point = grab_marker.global_position
		if affect_rotation:
			hand_node.hand.global_rotation = grab_marker.global_rotation

func _enter_tree():
	if get_child_count() == 0:
		var new_collision: CollisionShape3D = CollisionShape3D.new()
		new_collision.name = "CollisionShape3D"
		add_child(new_collision)
		new_collision.owner = get_tree().edited_scene_root
		
		var new_marker: Marker3D = Marker3D.new()
		new_marker.name = "HandPositionMarker"
		add_child(new_marker)
		new_marker.owner = get_tree().edited_scene_root
		grab_marker = new_marker
