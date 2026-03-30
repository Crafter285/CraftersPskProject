extends StaticBody3D

@export var code: int

@onready var press_sfx: AudioStreamPlayer3D = $Press
@onready var success_sfx: AudioStreamPlayer3D = $Success
@onready var reset_sfx: AudioStreamPlayer3D = $Reset

var target_code: Array = []
var current_code: Array = []

signal code_success
signal code_failed
signal button_pressed

var complete: bool = false

func _ready() -> void:
	var code_string: String = str(code)
	for i in code_string.length():
		target_code.append(int(code_string[i]))

func success():
	success_sfx.play()
	complete = true
	code_success.emit()
func reset():
	reset_sfx.play()
	current_code = []
	code_failed.emit()
	for i in $Buttons.get_child_count():
		$Buttons.get_child(i).reset_button()
func pressed(idx: int):
	if complete: return
	if idx == 0 and $Buttons.get_child(2).press_time < 0.6:
		current_code = []
		for i in $Buttons.get_child_count():
			$Buttons.get_child(i).reset_button()
		button_pressed.emit()
		return
	current_code.append(idx)
	press_sfx.play()
	button_pressed.emit()
	if target_code == current_code:
		success()
	elif current_code.size() >= target_code.size():
		reset()
