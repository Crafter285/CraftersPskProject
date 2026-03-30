extends Node
##Emits a signal when all levers are pulled down and when one is pulled up after all being pulled down.
class_name LeverLinker

@export var levers: Array[StaticBody3D]
var lever_list: Array[bool] = []
var lever_target: Array[bool] = []

signal levers_down
signal levers_up

var complete: bool = false

func _ready():
	if levers.size() > 0:
		for i in levers.size():
			lever_list.append(false)
			lever_target.append(true)
			levers[i].connect("pulled_down", Callable(lever_pulled_down).bind(i))
			levers[i].connect("pulled_up", Callable(lever_pulled_up).bind(i))

func lever_pulled_down(lever_idx: int):
	lever_list[lever_idx] = true
	if lever_list == lever_target:
		emit_signal("levers_down")
		complete = true
func lever_pulled_up(lever_idx: int):
	lever_list[lever_idx] = false
	if complete:
		emit_signal("levers_up")
		complete = false
