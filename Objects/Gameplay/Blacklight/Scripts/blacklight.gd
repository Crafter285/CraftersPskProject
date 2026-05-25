@tool
extends Node3D

@export var image: Texture2D
@export var notify_glowby: bool = true
@export_range(0.1, 10.0, 0.01) var mesh_scale: float = 2.5

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var preview: MeshInstance3D = $MeshInstance3D2

var _last_image: Texture2D
var _last_scale: float = 1.0

func _ready() -> void:
	if mesh:
		var mat := mesh.get_active_material(0)
		if mat:
			mesh.set_surface_override_material(0, mat.duplicate())

	if preview:
		var pmat := preview.get_active_material(0)
		if pmat:
			preview.set_surface_override_material(0, pmat.duplicate())

		if not Engine.is_editor_hint():
			preview.queue_free()
			preview = null

	_update_materials()
	_update_scale()

func _process(_delta: float) -> void:
	if image != _last_image:
		_update_materials()
		_last_image = image
	
	if mesh_scale != _last_scale:
		_update_scale()
		_last_scale = mesh_scale

func _update_materials() -> void:
	if mesh:
		var mat = mesh.get_surface_override_material(0)
		if mat is ShaderMaterial:
			mat.set_shader_parameter("image", image)

	if preview:
		var preview_mat = preview.get_surface_override_material(0)
		if preview_mat is StandardMaterial3D:
			preview_mat.albedo_texture = image

func _update_scale() -> void:
	var new_scale := Vector3(mesh_scale, mesh_scale, mesh_scale)
	if mesh:
		mesh.scale = new_scale
	if preview:
		preview.scale = new_scale

func _on_area_3d_body_entered(body: Node3D) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if body.is_in_group("Player"):
			if notify_glowby == true:
				if player.glowby_can_notify == true:
					player.glowby_notifaction = true
					player.glowby_can_notify = false


func _on_area_3d_body_exited(body: Node3D) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if notify_glowby == true:
			player.glowby_can_notify = true
