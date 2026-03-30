extends Node3D
class_name GearPuzzle

var gear_axles: Array[StaticBody3D] = []
var gear_states: Array[bool] = []
var target_states: Array[bool] = []

signal gears_in_place
signal gear_removed

func _ready() -> void:
	for i in get_child_count():
		if get_child(i).get_script().resource_path == "res://Objects/Gameplay/Puzzles/Gears/Scripts/gear_axle.gd":
			var child = get_child(i)
			gear_axles.append(child)
			gear_states.append(child.has_gear)
			target_states.append(true)
			child.connect("GearInserted", Callable(gear_inserted))
			child.connect("GearTaken", Callable(gear_taken))

func gear_inserted(axle):
	if axle.current_gear.gear_type_idx != axle.target_gear: return
	gear_states[gear_axles.find(axle)] = true
	if gear_states == target_states:
		gears_in_place.emit()
		for i in gear_axles.size():
			if not gear_axles[i].powered:
				gear_axles[i].spinning.play()
				gear_axles[i].animation_player.play("spin_loop")
func gear_taken(axle):
	gear_states[gear_axles.find(axle)] = false
	gear_removed.emit()
	for i in gear_axles.size():
		if not gear_axles[i].powered:
			gear_axles[i].spinning.stop()
			gear_axles[i].animation_player.stop()
