extends Node3D

##The distance the player must be from the indicator for it to appear
@export var radius: float = 1.0
@export var enabled: bool = true
@export var door: Node3D = null
const ITEM_OUTLINE = preload("res://Objects/VFX/Item/item_outline.tres")

@onready var circle: MeshInstance3D = $Circle
@onready var ready_mesh: Node3D = $ReadyMesh
@onready var ready_ind: MeshInstance3D = $ReadyMesh/Ready
@onready var locked: MeshInstance3D = $ReadyMesh/Locked
@onready var unlockable: MeshInstance3D = $ReadyMesh/Unlockable

var ind_node: Area3D = null

func _ready():
	ready_mesh.visible = false
	circle.visible = false
	set_indicator(0)
	$Area/CollisionShape3D.shape.radius = radius
	
	if get_parent() is BasicInteraction:
		ind_node = get_parent()
		ind_node.connect("player_started_look", Callable(start_look))
		ind_node.connect("player_ended_look", Callable(end_look))

func start_look():
	if door.locked:
		if door.unlockable_with_key:
			if Inventory.scan_list("items_Keys", door.key_name):
				set_indicator(2)
			else:
				set_indicator(1)
		else:
			return
	else:
		set_indicator(0)
	circle.visible = false
	ready_mesh.visible = true
func end_look():
	circle.visible = true
	ready_mesh.visible = false

func set_indicator(id: int):
	ready_ind.visible = false
	unlockable.visible = false
	locked.visible = false
	if id == 0:
		ready_ind.visible = true
	elif id == 1:
		locked.visible = true
	else:
		unlockable.visible = true

func _on_area_body_entered(body):
	if body.is_in_group("Player"):
		if ind_node and (door.locked and not door.unlockable_with_key) and not ind_node.enabled:
			return
		circle.visible = true
		visible = true

func _on_area_body_exited(body):
	if body.is_in_group("Player"):
		circle.visible = false
		ready_mesh.visible = false
		visible = false
