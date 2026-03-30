extends Node3D

@export var animation_player: AnimationPlayer = null
@export var look_at_modifier: LookAtModifier3D =  null
@export var body_material: Array[ORMMaterial3D]
@export var fur_material: Array[ORMMaterial3D]
@export var walking_ground_offset: float = 0.0
@export var in_air_offset: float = 0.0
@export var walk_anim: String = ""
@export var idle_anim: String = ""
@export var left_walk_anim: String = ""
@export var right_walk_anim: String = ""
@export var lunge_anim: String = ""
@export var attack_anim: String = ""
@export var attacked_anim: String = ""
@export var in_air_anim: String = ""

@onready var meshinstance: MeshInstance3D = $Skeleton3D/SK_HuggyWuggy_Red_mo

func _ready() -> void:
	var huggy_mat: int = randi_range(0, body_material.size()-1)
	meshinstance.set_surface_override_material(1, body_material[huggy_mat])
	meshinstance.set_surface_override_material(2, fur_material[huggy_mat])
	body_material = []
	fur_material = []
	await get_tree().create_timer(0.1).timeout
	look_at_modifier.target_node = look_at_modifier.get_path_to(Grabpack.player)

func play(anim: String):
	if anim == "Lunge":
		animation_player.speed_scale = 1.0
		animation_player.play(lunge_anim)
	if anim == "Walk":
		animation_player.speed_scale = 2.5
		animation_player.play(walk_anim)
	if anim == "Idle":
		animation_player.speed_scale = 1.0
		animation_player.play(idle_anim)
	if anim == "WalkRight":
		animation_player.speed_scale = 1.5
		animation_player.play(right_walk_anim)
	if anim == "WalkLeft":
		animation_player.speed_scale = 1.5
		animation_player.play(left_walk_anim)
	if anim == "InAir":
		animation_player.play(in_air_anim)
