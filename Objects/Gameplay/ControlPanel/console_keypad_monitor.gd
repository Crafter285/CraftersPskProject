extends StaticBody3D

@export var keypad: StaticBody3D

@onready var code_label: Label = $SM_ConsolsMonitor_A/SubViewportContainer/SubViewport/Control/CodeLabel
@onready var enter_label: Label = $SM_ConsolsMonitor_A/SubViewportContainer/SubViewport/Control/EnterLabel

func _ready() -> void:
	await get_tree().process_frame
	keypad.connect("button_pressed", Callable(update_text))
	keypad.connect("code_failed", Callable(update_text))
	update_text()

func update_text():
	if not keypad: return
	var code_str: String = ""
	var code_full: String = str(keypad.code)
	for i in str(keypad.code).length():
		code_str = str(code_str, str("_", " " if i+1 < code_full.length() else "") if (keypad.current_code.size() < 1 or (keypad.current_code.size() > 0 and keypad.current_code.size() <= i))else str(str(keypad.current_code[i]), " " if i+1 < code_full.length() else ""))
	code_label.text = code_str
	
	if not code_str.contains("_"):
		enter_label.text = "SUCCESS"
		enter_label.add_theme_color_override("font_color", Color.GREEN)
		enter_label.get_theme_stylebox("normal").bg_color = Color("43ff3c4c")
	else:
		enter_label.text = "ENTER CODE"
		enter_label.add_theme_color_override("font_color", Color("00bd6e"))
		enter_label.get_theme_stylebox("normal").bg_color = Color("43ffbc4c")
