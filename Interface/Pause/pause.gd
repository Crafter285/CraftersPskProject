extends Control

@onready var object_label = $Objective/Label
@onready var settings_menu = $SettingsMenu
@onready var load_game = $LoadGame
@onready var menu_popup = $menu_popup

func _ready():
	visible = false

func _unhandled_input(_event):
	if Input.is_action_just_pressed("exit"):
		if settings_menu.visible:
			settings_menu.toggle()
			return
		elif load_game.visible:
			load_game.unload_menu()
			return
		toggle_menu()

func toggle_menu():
	if $"../inventory".visible and not visible: return
	object_label.text = Game.current_objective
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$Opened.play()
	get_tree().paused = !visible
	visible = !visible

func _on_resume_pressed():
	$ButtonSFXPlayer/ExitMenu.play()
	toggle_menu()
func _on_restart_pressed():
	var result = await menu_popup.prompt("Restart Checkpoint", "Do you want to load the last checkpoint? Any unsaved progress will be lost.")
	if result:
		Game.load_checkpoint()
func _on_load_pressed():
	load_game.toggle()
func _on_settings_pressed():
	settings_menu.toggle()
func _on_main_pressed():
	var result = await menu_popup.prompt("Quit To Main Menu", "Are you sure you want to quit? Any unsaved progress will be lost.")
	if result:
		Game.load_scene("res://Interface/MainMenu/title_screen.tscn")
func _on_quit_pressed():
	var result = await menu_popup.prompt("Quit To Desktop", "Are you sure you want to quit? Any unsaved progress will be lost.")
	if result:
		get_tree().quit()
