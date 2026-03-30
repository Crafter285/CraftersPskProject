extends StaticBody3D

@export var outlined: bool = true

@onready var hand_grab = $HandGrab
@onready var inventory_item = $InventoryItem
@onready var sm_lever_hand_a = $SM_LeverHand_A

func _ready():
	if not outlined:
		sm_lever_hand_a.mesh.surface_get_material(0).next_pass = null

func collect():
	inventory_item.add_to_inventory()
	hand_grab.release_grabbed()
	queue_free()

func _on_hand_grab_let_go(_hand):
	collect()

func _on_basic_interaction_player_interacted():
	collect()
