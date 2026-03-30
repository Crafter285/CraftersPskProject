extends Node3D

@export var note_title: String = ""
@export var note_description: String = ""
@export_multiline var note_message: String = ""

@onready var inventory_item: InventoryItem = $InventoryItem
@onready var hand_grab: HandGrab = $HandGrab

func _ready() -> void:
	inventory_item.item_name = note_title
	inventory_item.item_description = note_description

func collect():
	inventory_item.add_to_inventory()
	Inventory.notes_data.append(note_message)
	hand_grab.release_grabbed()
	
	queue_free()

func grabbed(_hand: bool):
	collect()
func interacted():
	collect()
