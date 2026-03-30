extends Node
class_name MonsterActivator

enum states {
	disabled,
	roaming,
	path_follow,
	chase
}

@export var monster: CharacterBody3D = null
@export var state: states = states.roaming
@export var node: NodePath = ""
@export var node_signal: String = ""
var activated: bool = false
func _ready() -> void:
	var activate_node = get_node(node)
	activate_node.connect(node_signal, Callable(activate))
func activate():
	if not activated: monster.set_state(state)
	activated = true
