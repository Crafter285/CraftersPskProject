extends  Node3D

@export var key_name: String = ""
@export var key_description: String = ""

@onready var hand_grab = $HandGrab
@onready var inventory_item = $InventoryItem

func _ready() -> void:
	inventory_item.item_name = key_name
	inventory_item.item_description = key_description

func collect():
	inventory_item.add_to_inventory()
	hand_grab.release_grabbed()
	queue_free()

func _on_hand_grab_let_go(_hand):
	collect()

func _on_basic_interaction_player_interacted():
	collect()
