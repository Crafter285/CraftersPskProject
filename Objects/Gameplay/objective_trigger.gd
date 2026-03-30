extends Node
##Updates the players objective when the parent node emits a specified signal.
class_name ObjectiveTrigger

@export var signal_name: String = "triggered"
@export var objective_title: String = ""

func _ready():
	get_parent().connect(signal_name, Callable(objective))

func objective():
	Game.set_objective(objective_title)
