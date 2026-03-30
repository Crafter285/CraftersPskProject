extends Node
##Shows a tutorial message when the parent node emits a specified signal.
class_name TutorialTrigger

@export var signal_name: String = "triggered"
@export var tutorial_message: String = ""
@export var display_time: float = 4.0

func _ready():
	get_parent().connect(signal_name, Callable(tutorial))

func tutorial():
	Game.tutorial(tutorial_message, display_time)
