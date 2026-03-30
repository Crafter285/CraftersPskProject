extends Area3D
class_name AutomaticGate

func _ready() -> void:
	connect("body_entered", Callable(entered))
	connect("body_exited", Callable(exited))

func entered(body):
	if body.is_in_group("Player"):
		get_parent().opengate()
func exited(body):
	if body.is_in_group("Player"):
		get_parent().closegate()
