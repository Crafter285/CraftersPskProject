extends Node

@onready var settings_menu = $"../../.."

func _ready() -> void:
	GameSettings.connect("setting_changed", setting_changed)
func reset_to_defualts():
	GameSettings.setting_values = GameSettings.default_values
	
	#RESET OTHER
	for i in GameSettings.setting_names.size():
		GameSettings.setting_changed.emit(GameSettings.setting_names[i], GameSettings.setting_values[i])

func _unhandled_input(_event):
	if settings_menu.visible and Input.is_action_just_pressed("reset"):
		var result = await settings_menu.get_node(settings_menu.menu_popup).prompt("Reset To Defualts", "This will reset all settings to their defualt value.")
		if result:
			reset_to_defualts()
func setting_changed(setting, value):
	if setting == "master_volume": AudioServer.set_bus_volume_db(0, linear_to_db(value/100.0))
	elif setting == "music_volume": AudioServer.set_bus_volume_db(1, linear_to_db(value/100.0))
	elif setting == "sfx_volume": AudioServer.set_bus_volume_db(2, linear_to_db(value/100.0))
	elif setting == "ambience_volume": AudioServer.set_bus_volume_db(3, linear_to_db(value/100.0))
	elif setting == "vsync": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if GameSettings.get_setting("vsync") else DisplayServer.VSYNC_DISABLED)
	elif setting == "window_mode": DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if GameSettings.get_setting("window_mode") == 0 else (DisplayServer.WINDOW_MODE_MAXIMIZED if GameSettings.get_setting("window_mode") == 1 else DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN))
	elif setting == "fps_limit":
		var fps_caps: Array[int] = [30, 60, 120, 144, 160, 165, 180, 200, 240, 360, 0]
		Engine.max_fps = fps_caps[GameSettings.get_setting("fps_limit")]

#func _on_settings_box_5_toggled(toggled_on: bool) -> void:
	#GameSettings.mobile_controls = toggled_on
	#if Grabpack.player != null:
		#if toggled_on:
			#if Grabpack.player.has_node("MobileControls"): return
			#var mobile = load("res://Interface/Mobile/mobile_controls.tscn").instantiate()
			#mobile.name = "MobileControls"
			#Grabpack.player.add_child(mobile)
		#else:
			#if Grabpack.player.has_node("MobileControls"):
				#Grabpack.player.get_node("MobileControls").queue_free()

func apply():
	var viewport: Viewport = get_viewport()
	viewport.scaling_3d_scale = GameSettings.get_setting("resolution_scale")
	if GameSettings.get_setting("anti_aliasing") == 0: get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif GameSettings.get_setting("anti_aliasing") == 1: get_viewport().msaa_3d = Viewport.MSAA_2X
	elif GameSettings.get_setting("anti_aliasing") == 2: get_viewport().msaa_3d = Viewport.MSAA_4X
	elif GameSettings.get_setting("anti_aliasing") == 2: get_viewport().msaa_3d = Viewport.MSAA_8X
	Game.load_quality_environments()
