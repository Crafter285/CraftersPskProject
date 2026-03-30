extends Control

@onready var prompt_name = $Prompt
@onready var sub_prompt = $SubPrompt
@onready var yesbutton = $YesNSF
@onready var nobutton = $NoNSF
@onready var animation = $Animation
@onready var open_sound: AudioStreamPlayer = $OpenSound

signal prompt_result(value: bool)

func _ready():
	visible = false
	yesbutton.connect("pressed", Callable(yes))
	nobutton.connect("pressed", Callable(no))

func prompt(title: String, subtitle: String):
	open_sound.play()
	prompt_name.text = title
	sub_prompt.text = subtitle
	animation.play("fadein")
	
	var result: bool = await prompt_result
	
	return result

func remove():
	animation.play("fadeout")

func yes():
	prompt_result.emit(true)
	remove()
func no():
	prompt_result.emit(false)
	remove()
