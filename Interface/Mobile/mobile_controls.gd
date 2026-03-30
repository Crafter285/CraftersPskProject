extends Control

@onready var drag: Control = $Drag
@onready var gp_extra: Node2D = $GP_Extra
@onready var watch: TouchScreenButton = $GP_Extra/Watch
@onready var f: TouchScreenButton = $F

func _enter_tree() -> void:
	disable_input("handleft", MOUSE_BUTTON_LEFT)
	disable_input("handright", MOUSE_BUTTON_RIGHT)
func _exit_tree() -> void:
	enable_input("handleft", MOUSE_BUTTON_LEFT)
	enable_input("handright", MOUSE_BUTTON_RIGHT)

func disable_input(action_name, button):
	var button_to_remove = button  # Left mouse button (value = 1)

	# Loop through all input events associated with the action
	for event in InputMap.action_get_events(action_name):
		if event is InputEventMouseButton and event.button_index == button_to_remove:
			InputMap.action_erase_event(action_name, event)

func enable_input(action_name, button):
	var mouse_event := InputEventMouseButton.new()
	mouse_event.button_index = button
	mouse_event.pressed = true  # Required for the input to be considered valid

	InputMap.action_add_event(action_name, mouse_event)

func _process(_delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.action_press("sprint")
	if Grabpack.grabpack.current_grabpack > 1:
		gp_extra.visible = true
		if Grabpack.grabpack.current_grabpack == 3:
			watch.visible = true
		else:
			watch.visible = false
	else:
		gp_extra.visible = false
	if Grabpack.player.flashlight_togglable:
		f.visible = true
	else:
		f.visible = false
