extends Node3D
class_name MobibleSpawner3D

@export var time: float = 10.0

var coming: bool = false
var timing: float = 0.0

func _process(delta: float) -> void:
	if coming:
		timing += 1.0*delta
		if timing > 0.5:
			time -= 0.5
			timing = 0.0
			var new_mobible = preload("res://Objects/Gameplay/Mobibles/mobible.tscn").instantiate()
			add_child(new_mobible)
			new_mobible.position.x = randf_range(1.5, -1.5)
			new_mobible.position.z = randf_range(1.5, -1.5)
		if time < 0.0:
			coming = false
func spawn():
	coming = true
