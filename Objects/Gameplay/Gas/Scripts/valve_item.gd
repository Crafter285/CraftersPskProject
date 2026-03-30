extends RigidBody3D

@export var outlined: bool = true

@onready var hand_grab = $HandGrab
@onready var valve = $Valve
@onready var holdable_item: HoldableItem = $HoldableItem

func _ready():
	if not outlined:
		valve.mesh.surface_get_material(0).next_pass = null

func _on_hand_grab_let_go(hand):
	hand_grab.enabled = false
	holdable_item.start_hold(hand)

func _on_holdable_item_let_go() -> void:
	hand_grab.enabled = true
