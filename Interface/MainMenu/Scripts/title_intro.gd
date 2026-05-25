extends Control
@onready var name_animation = $NameAnimation
@onready var menu_transition = $"../MenuTransition/AnimationPlayer"
@onready var pressedsfx = $"../menu/Pressed"
@onready var ch5_render_bg_any = get_node_or_null("RenderBG")
@onready var ch5_music = get_node_or_null("Music2")

var awaiting: bool = false
signal pressed

func _ready():
	visible = false

func _input(_event):
	if awaiting:
		if Input.is_anything_pressed():
			if menu_transition:
				menu_transition.play("transition")
			name_animation.play("pressed")
			pressedsfx.play()
			awaiting = false

func start():
	if Game.interface == "Ch5":
		if ch5_render_bg_any:
			ch5_render_bg_any.play()
		if ch5_music:
			ch5_music.play()

	visible = true
	name_animation.play("loop")
	awaiting = true

func finished():
	pressed.emit()
	if Game.interface == "Ch5":
		if ch5_render_bg_any:
			ch5_render_bg_any.stop()
		if ch5_music:
			ch5_music.stop()
