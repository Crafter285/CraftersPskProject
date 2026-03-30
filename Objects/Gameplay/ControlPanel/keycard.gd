@tool
extends Node3D

@export var keycard_name: String = ""
@export var colour: Color
@export var custom_inventory_image: bool = false
@export var inventory_image: Texture2D = null

@onready var inventory_item: InventoryItem = $InventoryItem
@onready var hand_grab: HandGrab = $HandGrab

@onready var material: ORMMaterial3D = $SM_KeyCard_B.get_surface_override_material(0)

func _ready() -> void:
	material.albedo_color = colour
	inventory_item.item_name = keycard_name
	if custom_inventory_image:
		inventory_item.item_image = inventory_image

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		material.albedo_color = colour

func grabbed():
	hand_grab.release_grabbed()
	inventory_item.add_to_inventory()
	queue_free()

func _on_basic_interaction_player_interacted() -> void:
	grabbed()
func _on_hand_grab_let_go(_hand: bool) -> void:
	grabbed()
