extends Node

@export var editor_critter_model: Node3D
@export var critter_anim_scenes: Array[PackedScene]

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	var new_critter_id: int = randi_range(0, critter_anim_scenes.size()-1)
	var new_critter = critter_anim_scenes[new_critter_id].instantiate()
	get_parent().add_child(new_critter)
	get_parent().animation_handler = new_critter
	
	if editor_critter_model: editor_critter_model.queue_free()
	queue_free()
