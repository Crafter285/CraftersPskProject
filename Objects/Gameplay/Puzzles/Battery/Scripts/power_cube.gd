extends StaticBody3D

enum cube_colours {
	Red,
	Blue,
	Yellow,
	Green
}

@export var cube_colour: cube_colours = cube_colours.Red

func _ready() -> void:
	var cube_colour_title: String = cube_colours.keys()[cube_colour]
	
	$InventoryItem.item_name = str(cube_colour_title," Power Cube")
	var cube_colour_value: Color = cube_colour_title.to_upper()
	$InventoryItem.item_image = load(str("res://Interface/Inventory/ItemIcons/", cube_colour_title, "_Power_Cube.png"))
	
	$Cube.get_surface_override_material(2).emission = cube_colour_value


func _on_basic_interaction_player_interacted() -> void:
	pass # Replace with function body.
