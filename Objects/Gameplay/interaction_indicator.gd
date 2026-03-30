extends Node3D

##The distance the player must be from the indicator for it to appear
@export var radius: float = 1.0
@export var enabled: bool = true

const ITEM_OUTLINE = preload("res://Objects/VFX/Item/item_outline.tres")

@onready var circle: MeshInstance3D = $Circle
@onready var ready_mesh: Node3D = $ReadyMesh

var ind_node: Area3D = null

func _ready():
	ready_mesh.visible = false
	circle.visible = false
	visible = false
	$Area/CollisionShape3D.shape.radius = radius
	
	if get_parent() is BasicInteraction:
		ind_node = get_parent()
		ind_node.connect("player_started_look", Callable(start_look))
		ind_node.connect("player_ended_look", Callable(end_look))

func start_look():
	circle.visible = false
	ready_mesh.visible = true
func end_look():
	circle.visible = true
	ready_mesh.visible = false

func _on_area_body_entered(body):
	if body.is_in_group("Player"):
		if ind_node and not ind_node.enabled:
			return
		circle.visible = true
		visible = true

func _on_area_body_exited(body):
	if body.is_in_group("Player"):
		circle.visible = false
		ready_mesh.visible = false
		visible = false
