extends Button

@onready var settings_menu = $"../.."

func _ready():
	connect("pressed", Callable(pressed_button))

func pressed_button():
	settings_menu.load_tab(str("Tab", name), self)
