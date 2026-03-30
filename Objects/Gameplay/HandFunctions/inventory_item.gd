extends Node
class_name InventoryItem

enum tabs {
	Keys,
	VHS,
	Notes,
	Equipment
}

@export_group("ItemProperties")
@export var item_type = tabs.Keys
@export var item_name: String = "none"
@export var item_has_description: bool = false
@export var item_description: String = "none"
@export var item_image: Texture2D

@export_group("CollectionProperties")
@export var play_collect_sound: bool = true
@export var use_hand_grab: HandGrab
@export var use_basic_interaction: BasicInteraction
@export var root_item_node: Node

var added: bool = false

func _ready() -> void:
	if use_hand_grab: use_hand_grab.connect("let_go", add_to_inventory_extra)
	if use_basic_interaction: use_basic_interaction.connect("player_interacted", add_to_inventory_extra)

func add_to_inventory_extra(_unused: bool = false):
	if use_hand_grab: use_hand_grab.release_grabbed()
	add_to_inventory()
	
	await get_tree().process_frame
	if root_item_node: root_item_node.queue_free()
func add_to_inventory():
	if added: return
	var list: String = tabs.keys()[item_type]
	var item_array: Array = Inventory.get(str("items_", list))
	
	if item_has_description:
		item_array.append([item_name, item_image, item_description])
	else:
		item_array.append([item_name, item_image])
	
	if play_collect_sound:
		Grabpack.player.sound_manager.collect()
	
	added = true
