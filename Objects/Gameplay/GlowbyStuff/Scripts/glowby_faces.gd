extends Node3D

enum facetype {
	back_to_default,
	Curous_Concerned,
	Scared,
	Shock_Frightend,
	dead_very_scared,
	eyes_closed,
	loading,
	super_happy,
	very_very_happy,
	very_worried
}

const FACE_FLAGS := {
	facetype.back_to_default: "glowby_back_to_default",
	facetype.Curous_Concerned: "glowby_Curous_Concerned",
	facetype.Scared: "glowby_Scared",
	facetype.Shock_Frightend: "glowby_Shock_Frightend",
	facetype.dead_very_scared: "glowby_dead_very_scared",
	facetype.eyes_closed: "glowby_eyes_closed",
	facetype.loading: "glowby_laoding",
	facetype.super_happy: "glowby_super_happy",
	facetype.very_very_happy: "glowby_very_very_happy",
	facetype.very_worried: "glowby_very_worried",
}

@export var area3d: Area3D
@export var face_type: facetype = facetype.back_to_default
@export var face_only_in_area: bool = false
@export var one_time_use: bool = true
@export var Use_time: bool = false
@export var time_: float = 1

var _used: bool = false
var _revert_id: int = 0


func _ready() -> void:
	if area3d == null:
		push_error("%s: area3d is not assigned." % name)
		return
	area3d.body_entered.connect(body_entered)
	area3d.body_exited.connect(body_exited)


func body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		trigger()


func body_exited(body: Node3D) -> void:
	if not face_only_in_area or face_type == facetype.back_to_default:
		return
	if body.is_in_group("Player"):
		_revert_id += 1
		_set_face(facetype.back_to_default)


func trigger() -> void:
	if one_time_use and _used:
		return
	if get_tree().get_first_node_in_group("Player") == null:
		return
	_used = true
	_revert_id += 1
	var my_id := _revert_id
	_set_face(face_type)

	if Use_time and face_type != facetype.back_to_default:
		await get_tree().create_timer(time_).timeout
		if my_id == _revert_id:
			_set_face(facetype.back_to_default)


func _set_face(face: facetype) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	for f in FACE_FLAGS:
		player.set(FACE_FLAGS[f], false)
	player.set(FACE_FLAGS[face], true)
