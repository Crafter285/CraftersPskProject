extends StaticBody3D

enum gear_types {
	Large,
	Medium,
	Small,
	ExtraSmall
}

@export var powered: bool = false
@export var has_gear: bool = false
@export var target_gear: gear_types = gear_types.Large

@onready var gear_pos: Marker3D = $SpinPivot/GearPos
@onready var gear_space_detecter: Area3D = $GearSpaceDetecter
@onready var gear_col: CollisionShape3D = $GearSpaceDetecter/CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var insert: AudioStreamPlayer3D = $Insert
@onready var spinning: AudioStreamPlayer3D = $Spinning

var current_gear: RigidBody3D = null
var awaiting_enter_check: bool = false
var can_enter: bool = false

signal GearInserted(axle)
signal GearTaken(axle)

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	if has_gear:
		var new_gear
		if target_gear == gear_types.Small: new_gear = preload("res://Objects/Gameplay/Puzzles/Gears/small_gear.tscn").instantiate()
		elif target_gear == gear_types.ExtraSmall: new_gear = preload("res://Objects/Gameplay/Puzzles/Gears/extra_small_gear.tscn").instantiate()
		elif target_gear == gear_types.Medium: new_gear = preload("res://Objects/Gameplay/Puzzles/Gears/medium_gear.tscn").instantiate()
		elif target_gear == gear_types.Large: new_gear = preload("res://Objects/Gameplay/Puzzles/Gears/large_gear.tscn").instantiate()
		get_parent().add_child(new_gear)
		current_gear = new_gear
		current_gear.in_axle = true
		current_gear.axle = self
		current_gear.disable_gear()
		if powered:
			spinning.play()
			animation_player.play("spin_loop")

func _process(_delta: float) -> void:
	if current_gear:
		gear_pos.position = current_gear.axle_offset
		current_gear.global_transform = gear_pos.global_transform

func release_gear():
	spinning.stop()
	animation_player.stop()
	current_gear.in_axle = false
	current_gear = null
	gear_col.shape.radius = 0.01
	GearTaken.emit(self)

func _on_gear_detecter_area_entered(area: Area3D) -> void:
	if area.is_in_group("AxleConnect") and not current_gear:
		current_gear = area.get_parent()
		if current_gear.in_axle: return
		can_enter = true
		gear_col.shape.radius = current_gear.main_collision.shape.radius
		awaiting_enter_check = true
		await get_tree().create_timer(0.2).timeout
		gear_col.shape.radius = 0.01
		awaiting_enter_check = false
		if not can_enter:
			current_gear = null
			return
		if powered:
			spinning.play()
			animation_player.play("spin_loop")
		current_gear.in_axle = true
		current_gear.axle = self
		current_gear.disable_gear()
		GearInserted.emit(self)
		insert.play()
func _on_timer_timeout() -> void:
	gear_col.shape.radius = 0.01
	if not can_enter: return
	current_gear.in_axle = true
	current_gear.axle = self
	current_gear.disable_gear()

func _on_gear_space_detecter_area_entered(area: Area3D) -> void:
	if area.is_in_group("Gear") and area.get_parent().in_axle:
		can_enter = false
