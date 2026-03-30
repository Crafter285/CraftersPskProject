extends StaticBody3D

@onready var pivot: Node3D = $Pivot
@onready var pivot_2: Node3D = $Pivot2

func _process(delta: float) -> void:
	pivot_2.look_at(Grabpack.player.camera.global_position)
	pivot.rotation = pivot.rotation.lerp(pivot_2.rotation, 3.0*delta)
	pivot.rotation.x = clampf(pivot.rotation.x, -1.0, 1.0)
	pivot.rotation.z = 0.0
	pivot.rotation.y = clampf(pivot.rotation.y, -1.0, 1.0)
