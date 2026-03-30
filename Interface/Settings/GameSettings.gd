extends Node

var setting_names: Array[String]
var setting_values: Array[float]
var setting_type: Array[bool]
var default_values: Array[float]

var built_settings: bool = false

signal setting_changed(setting: String, new_value: float)

func _ready() -> void:
	build_settings()
	loaded_settings()

func loaded_settings():
	for i in setting_names.size():
		setting_changed.emit(setting_names[i], setting_values[i])
func build_settings():
	if built_settings: return
	
	for i in 5:
		var current_tab = load(str("res://Interface/Settings/Tabs/settingsTab", i+1, ".tscn")).instantiate()
		var getting_from = (current_tab if current_tab.get_child(0) is Button else (current_tab.get_child(0) if (current_tab.get_child(0).get_child(0) is Button or not current_tab.get_child(0).get_child(0)) else current_tab.get_child(0).get_child(0)))
		for g in getting_from.get_child_count():
			if getting_from.get_child(g) is Button:
				setting_names.append(getting_from.get_child(g).setting_code_name)
				setting_values.append(getting_from.get_child(g).setting_default_value)
				setting_type.append(false if (getting_from.get_child(g).multi_option and getting_from.get_child(g).options.size()==2 and getting_from.get_child(g).options[0]=="OFF") else true)
		current_tab.queue_free()
	
	default_values = setting_values
	built_settings = true

func get_setting(setting: String):
	if setting_type[setting_names.find(setting)]:
		return setting_values[setting_names.find(setting)]
	else:
		return false if setting_values[setting_names.find(setting)]==0.0 else true
func change_setting(setting: String, new_value: float):
	setting_values[setting_names.find(setting)] = new_value
	setting_changed.emit(setting, new_value)
