extends Node

var hud = null
var checkpoint: int = 0

var current_environment_node: WorldEnvironmentGraphicsCompatible
var current_objective = "none"
var saves: Array = []

func _ready() -> void:
	if not GameSettings.setting_changed.is_connected(setting_changed): GameSettings.connect("setting_changed", setting_changed)
func reset_nodes():
	if not get_tree().get_first_node_in_group("HUD") == null:
		hud = get_tree().get_first_node_in_group("HUD")

func set_objective(objective: String):
	hud.new_objective(objective)
	current_objective = objective
func tutorial(tutorial_text: String, time: float = 4.0):
	hud.tutorial_notify(tutorial_text)
	if time > 0.0:
		await Game.delay(time)
		remove_tutorial()
func remove_tutorial():
	hud.remove_tutorial()
func tooltip(tooltip_text: String):
	hud.tooltip(tooltip_text)

#LOAD SYSTEM:

var _load_screen_path : String = "res://Interface/Loading/loading_screen.tscn"
var load_screen = load(_load_screen_path)
var previous_level: String

func load_scene(scene_path):
	previous_level = get_tree().current_scene.get_path()
	var new_loading_screen = load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	new_loading_screen.scene_path = scene_path
	new_loading_screen.start()

func _load_no_screen(Scene : NodePath):
	previous_level = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(Scene)

func save_game(new_checkpoint, save_title: String = "Untitled Save", save_image: Texture2D = preload("res://Interface/Inventory/ItemIcons/T_GreenHand_Inventory.png")):
	if new_checkpoint <= checkpoint: return
	if hud: hud.save()
	checkpoint = new_checkpoint
	saves.append([save_title, current_objective, save_image, new_checkpoint])
func reset_checkpoint():
	checkpoint = 0
func delay(time: float = 1.0):
	await get_tree().create_timer(time).timeout
	return

func load_quality_environments():
	if not current_environment_node: return
	
	if GameSettings.get_setting("graphics_quality") == 3: current_environment_node.environment = current_environment_node.epic_environment
	elif GameSettings.get_setting("graphics_quality") == 2: current_environment_node.environment = current_environment_node.high_environment
	elif GameSettings.get_setting("graphics_quality") == 1: current_environment_node.environment = current_environment_node.medium_environment
	elif GameSettings.get_setting("graphics_quality") == 0: current_environment_node.environment = current_environment_node.low_environment
	
	current_environment_node.compositor = preload("uid://cojs02qunkdeq") if GameSettings.get_setting("motion_blur") else null
func setting_changed(setting, _value): if setting ==  "motion_blur" or setting == "graphics_quality": load_quality_environments()

func load_checkpoint():
	#ADD YOUR LOAD CHECKPOINT CODE HERE
	#THE CODE ALREADY HERE IS ONLY FOR TESTING
	load_scene("res://Level/test_map.tscn")

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

func end(black_time: float = 1.5):
	get_tree().current_scene.add_child(preload("res://Interface/Credits/game_end_black.tscn").instantiate())
	Grabpack.player.capture_mouse(false)
	Grabpack.set_movable(false)
	hud.set_crosshair(false)
	
	await delay(black_time)
	
	get_tree().change_scene_to_file("res://Interface/Credits/credits.tscn")

#CUSTOM DATA:

var omni_charges: int = 4
