extends Node
##Shows a tooltip popup when the parent node emits a specified signal.
class_name TooltipTrigger

@export var signal_name: String = "triggered"
@export var tooltip_text: String = ""

func _ready():
	get_parent().connect(signal_name, Callable(tooltip))

func tooltip():
	Game.tooltip(tooltip_text)
