extends Control

var speed: float = 60.0

var current_time: float = 0.0
@export var credit_time: float = 40.0

@onready var credits = $Credits

var ended: bool = false

func _process(delta):
	credits.position.y -= speed * delta
	current_time += 1.0 * delta
	if current_time > credit_time and not ended:
		end()

func end():
	Game.load_scene("res://Interface/MainMenu/title_screen.tscn")
	ended = true
