extends AudioStreamPlayer
class_name QuickSFXNoDir

func _enter_tree() -> void:
	connect("finished", Callable(delete))

func delete():
	queue_free()
