extends Area3D
class_name BasicInteraction

@export var enabled: bool = true

signal player_interacted
signal player_started_look
signal player_ended_look

var colliding: bool = false

var uses_ind: bool = false
var ind_node: Node3D = null

func _ready():
	collision_layer &= ~1  # Disable layer 1
	collision_mask &= ~1   # Disable mask 1
	collision_layer |= 2  # Enable layer 1
	collision_mask |= 2   # Enable mask 1
	
	if has_node("InteractionIndicator"):
		ind_node = get_node("InteractionIndicator")

func _process(_delta):
	if not Grabpack.item_raycast:
		return
	if not Grabpack.item_raycast.is_colliding():
		if colliding: player_ended_look.emit()
		colliding = false
		return
	else:
		if Grabpack.item_raycast.get_collider() == self:
			if not colliding: player_started_look.emit()
			colliding = true
		else:
			if colliding: player_ended_look.emit()
			colliding = false

func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if colliding and enabled:
			emit_signal("player_interacted")
