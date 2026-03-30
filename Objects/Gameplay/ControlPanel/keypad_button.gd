extends Node3D

@export var button_number: int = 0
@export var press_time: float = 0.65

@onready var basic_interaction = $BasicInteraction
@onready var keypad = $"../.."

var pressing_time: float = 0.0

func _ready():
	basic_interaction.connect("player_interacted", Callable(pressed))

func _process(delta):
	if pressing_time > 0.0:
		if pressing_time < 0.5:
			if position.y < 0.0:
				position.y += 0.25* delta
		else:
			position.y -= 0.25 * delta
		if press_time > 0.6: pressing_time -= 1.5 * delta
		else: pressing_time -= 0.4 * delta

func pressed():
	if pressing_time > 0.0: return
	if has_node("Mesh"): $Mesh.get_surface_override_material(0).emission_enabled = true
	keypad.pressed(button_number)
	pressing_time = press_time

func reset_button():
	if has_node("Mesh"): $Mesh.get_surface_override_material(0).emission_enabled = false
