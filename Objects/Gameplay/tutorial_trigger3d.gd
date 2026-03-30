extends Area3D
##Displays a tutorial message when the player is inside the area.
class_name TutorialTrigger3D

@export var enabled: bool = true
@export var tutorial_text: String

func _ready() -> void:
	connect("body_entered", display_tutorial)
	connect("body_exited", remove_tutorial)
func display_tutorial(body):
	if not enabled: return
	if body.is_in_group("Player"): Game.tutorial(tutorial_text, 0.0)
func remove_tutorial(body):
	if body.is_in_group("Player"): Game.remove_tutorial()
