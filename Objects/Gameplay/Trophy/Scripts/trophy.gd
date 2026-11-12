@tool
extends Node3D

enum TrophyType {
	Barry,
	Bunzo,
	Claw,
	Daisy,
	Hand,
	Kissy,
	Mommy,
	Pj,
	Train
}

@export var Trophy_Type: TrophyType = TrophyType.Barry:
	set(value):
		Trophy_Type = value
		if has_node("InventoryItem"):
			$InventoryItem.item_name = TrophyType.keys()[Trophy_Type]
			_update_image()
		_update_model()

@export var play_collect_sound: bool = true

signal collected

func _ready() -> void:
	if play_collect_sound == false:
		$InventoryItem.play_collect_sound = false

	if has_node("InventoryItem"):
		$InventoryItem.item_name = TrophyType.keys()[Trophy_Type]
		_update_image()
	_update_model()

func _update_image() -> void:
	if not has_node("InventoryItem"):
		return

	var trophy_name = TrophyType.keys()[Trophy_Type]

	var script_path = get_script().resource_path.get_base_dir()  # Gets "Trophy/Scripts"
	var trophy_folder = script_path.get_base_dir()  # Goes up to "Trophy"
	var image_path = trophy_folder + "/Images/" + trophy_name + ".webp"

	var texture = load(image_path)

	if texture != null and texture is Texture2D:
		$InventoryItem.item_image = texture
	else:
		push_warning("Could not load image at path: " + image_path)

func _update_model() -> void:
	if not is_inside_tree():
		return

	if Engine.is_editor_hint():
		await get_tree().process_frame

	if not has_node("Models"):
		return

	var models_node = get_node("Models")
	
	for child in models_node.get_children():
		if child is Node3D:
			child.hide()

	match Trophy_Type:
		TrophyType.Barry:
			if models_node.has_node("trophy_barry"):
				models_node.get_node("trophy_barry").show()
		TrophyType.Bunzo:
			if models_node.has_node("trophy_bunzo"):
				models_node.get_node("trophy_bunzo").show()
		TrophyType.Claw:
			if models_node.has_node("trophy_claw"):
				models_node.get_node("trophy_claw").show()
		TrophyType.Daisy:
			if models_node.has_node("trophy_daisy"):
				models_node.get_node("trophy_daisy").show()
		TrophyType.Hand:
			if models_node.has_node("trophy_green_hand"):
				models_node.get_node("trophy_green_hand").show()
		TrophyType.Kissy:
			if models_node.has_node("trophy_kissy"):
				models_node.get_node("trophy_kissy").show()
		TrophyType.Pj:
			if models_node.has_node("trophy_PJ"):
				models_node.get_node("trophy_PJ").show()
		TrophyType.Train:
			if models_node.has_node("trophy_train"):
				models_node.get_node("trophy_train").show()
		TrophyType.Mommy:
			if models_node.has_node("trophy_mommy"):
				models_node.get_node("trophy_mommy").show()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
