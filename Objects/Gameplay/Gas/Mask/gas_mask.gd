extends StaticBody3D

@export var mask_togglable: bool = true

@onready var hand_grab: HandGrab = $HandGrab
@onready var inventory_item: InventoryItem = $InventoryItem

func collect():
	if Grabpack.player.gasmask and Grabpack.player.gasmask_type == 0:
		Game.tooltip("You can only have 1 gas mask at a time!")
		return
	Grabpack.player.gasmask = true
	Grabpack.player.gasmask_type = 0
	Grabpack.player.gasmask_toggleable = mask_togglable
	Grabpack.await_unequip_mask()
	if not mask_togglable:
		Grabpack.await_equip_mask()
	else:
		Game.tutorial("Press [G] To Equip/Unequip The Mask")
	hand_grab.release_grabbed()
	inventory_item.add_to_inventory()
	queue_free()

func _on_hand_grab_let_go(_hand: bool) -> void:
	collect()
func _on_basic_interaction_player_interacted() -> void:
	collect()
