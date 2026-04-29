extends Node3D

@onready var mesh: MeshInstance3D = $SK_ConductiveHand_ao/Skeleton3D/SK_ConductiveHand_mo
@onready var electra_mat = preload("res://Player/Grabpack/Hands/Shaders/electra.tres")
@onready var fire_mat = preload("res://Player/Grabpack/Hands/Shaders/fire.tres")
@onready var ice_mat = preload("res://Player/Grabpack/Hands/Shaders/ice.tres")

func none():
	var mat: Material = null
	mat = null
	if mesh:
		mesh.set_surface_override_material(1, null)
		var base_mat = mesh.get_active_material(1)
		if base_mat:
			base_mat.next_pass = mat

func electra():
	var mat: Material = null
	mat = electra_mat
	if mesh:
		mesh.set_surface_override_material(1, null)
		var base_mat = mesh.get_active_material(1)
		if base_mat:
			base_mat.next_pass = mat

func fire():
	var mat: Material = null
	mat = fire_mat
	if mesh:
		mesh.set_surface_override_material(1, null)
		var base_mat = mesh.get_active_material(1)
		if base_mat:
			base_mat.next_pass = mat

func ice():
	var mat: Material = null
	mat = ice_mat
	if mesh:
		mesh.set_surface_override_material(1, null)
		var base_mat = mesh.get_active_material(1)
		if base_mat:
			base_mat.next_pass = mat
