extends StaticBody3D

var pressing: bool = false
var total_objects: int = 0

signal pressed_down
signal pressed_up

func pressed(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		total_objects += 1
		if pressing: return
		pressing = true
		pressed_down.emit()
		$Press.play()
		$AnimationPlayer.play("move")
func unpress(body: Node3D) -> void:
	if body is CharacterBody3D or body is RigidBody3D:
		total_objects -= 1
		if total_objects > 0: return
		pressing = false
		pressed_up.emit()
		$PressUp.play()
		$AnimationPlayer.play_backwards("move")
