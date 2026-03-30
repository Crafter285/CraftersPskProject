extends Node
##Allows you to add a lightning-like effect to the hand when the hand is disabled. Effect replaces the Next Pass of a MeshInstance3D's surface override material.
class_name HandDisableParticles

const HAND_DISABLE_PARTICLES = preload("uid://ynv5bqxdxt2l")

@export var add_effect_to_mesh: MeshInstance3D
@export var surface_override: int = 0

func enable():
	if add_effect_to_mesh:
		if add_effect_to_mesh.get_surface_override_material(0):
			add_effect_to_mesh.get_surface_override_material(0).next_pass = HAND_DISABLE_PARTICLES
func disable():
	if add_effect_to_mesh:
		if add_effect_to_mesh.get_surface_override_material(0):
			add_effect_to_mesh.get_surface_override_material(0).next_pass = null
