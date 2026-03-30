extends Button

@onready var titlenode = $Title
@onready var objectivenode = $Objective
@onready var sprite = $Sprite2D
@onready var current = $"../Current"

var game_save: int = 0

func _ready():
	connect("pressed", Callable(pressed_btn))

func pressed_btn():
	get_parent().get_parent().get_parent().get_parent().confirm_load(game_save)

func load_data(data: Array):
	titlenode.text = data[0]
	objectivenode.text = data[1]
	sprite.texture = data[2]
	game_save = data[3]
