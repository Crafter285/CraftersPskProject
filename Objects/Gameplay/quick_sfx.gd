extends AudioStreamPlayer3D
class_name QuickSFX

func _enter_tree() -> void:
	connect("finished", Callable(delete))

func delete():
	queue_free()
