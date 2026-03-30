extends Control

@export var menu_popup: NodePath

@onready var tabs = $section/Tabs
@onready var setting_title = $section/setting_title
@onready var setting_description = $section/setting_description
@onready var title = $section/Title/title
@onready var load_animation = $section/LoadAnimation
@onready var tab_indecator = $Tabs/TabIndecator

var tabs_names = ["CONTROLS", "DISPLAY", "GRAPHICS", "AUDIO", "LANGUAGE"]
var current_tab: Node2D = null
var previous_tab_button: Button = null

func _ready():
	load_tab("Tab1",get_node("Tabs/1"))
	visible = false
	await get_tree().process_frame
	for i in GameSettings.setting_names.size():
		GameSettings.setting_changed.emit(GameSettings.setting_names[i], GameSettings.setting_values[i])

func toggle():
	if visible:
		#$section/Tabs/SettingsManager.apply()
		if current_tab:
			current_tab.queue_free()
			current_tab = null
	else:
		load_tab("Tab1", $"Tabs/1")
		load_animation.play("loaded")
	visible = !visible

func _unhandled_input(_event):
	if visible:
		if Input.is_action_just_pressed("rotate_left"):
			var switching_to: int = int(previous_tab_button.name)-1
			if switching_to < 1: switching_to = 5
			load_tab(str("Tab",switching_to), $Tabs.get_node(str(switching_to)))
			$Tabs/ButtonSFXPlayer/Forward.play()
		if Input.is_action_just_pressed("rotate_right"):
			var switching_to: int = int(previous_tab_button.name)+1
			if switching_to > 5: switching_to = 1
			load_tab(str("Tab",switching_to), $Tabs.get_node(str(switching_to)))
			$Tabs/ButtonSFXPlayer/Forward.play()

func load_tab(tab: String, node: Button):
	if current_tab:
		current_tab.queue_free()
		current_tab = null
	var new_tab = load(str("res://Interface/Settings/Tabs/settingsTab", tab[3], ".tscn")).instantiate()
	var button_container = new_tab if new_tab.get_child(0) is Button else (new_tab.get_child(0) if new_tab.get_child(0).get_child(0) is Button else new_tab.get_child(0).get_child(0))
	for i in button_container.get_child_count():
		var child = button_container.get_child(i)
		if child is Button:
			var setting = GameSettings.get_setting(child.setting_code_name)
			child.setting_default_value = setting if not setting is bool else 1.0 if setting else 0.0
	tabs.add_child(new_tab)
	var next_tab = new_tab
	next_tab.visible = true
	title.text = tabs_names[int(tab)-1]
	load_animation.play("loaded")
	current_tab = next_tab
	tab_indecator.position.x = node.position.x
	if previous_tab_button:
		previous_tab_button.modulate = "767f87"
		previous_tab_button.remove_theme_stylebox_override("normal")
	previous_tab_button = node
	node.modulate = "ffffffff"
func setting_pressed(titleset, descriptionset, _y_pos):
	setting_title.text = titleset
	setting_description.text = descriptionset
func setting_exited():
	return

func _on_back_pressed():
	if visible:
		toggle()
