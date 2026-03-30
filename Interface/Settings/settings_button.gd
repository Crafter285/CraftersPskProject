extends Button

@export var setting_name: String = ""
@export var setting_description:  String = ""
@export var settings_root: NodePath
@export_group("SettingData")
@export var setting_code_name: String = ""
@export var setting_default_value: float = 1.0
@export_group("Slider")
@export var slider_min: float = 0.0
@export var slider_max: float = 100.0
@export var slider_step: float = 5.0
@export var slider_symbol: String = ""
@export_group("MultiOption")
@export var options: Array[String] = ["OFF", "ON"]
@export_group("PreConfig")
@export var multi_option: bool = false
@export var no_setting_data: bool = false
@export var is_slider: bool = false
var current_option: int = 0
var on_arrow: int = 0
var hovered: bool = false
var setting_node: Control = null

signal value_changed(new_value: float)

func _ready():
	if no_setting_data: return
	if is_slider:
		$HSlider.min_value = slider_min
		$HSlider.max_value = slider_max
		$HSlider.step = slider_step
		$HSlider.value = setting_default_value
	if multi_option:
		current_option = int(setting_default_value)
	
	connect("mouse_entered", Callable(send_data))
	setting_node = get_node(settings_root)
	connect("mouse_exited", Callable(setting_node.setting_exited))
	connect("visibility_changed", Callable(new_vis))
	get_node("ShiftL").connect("mouse_entered", func(): hover_shift(-1))
	get_node("ShiftR").connect("mouse_entered", func(): hover_shift(1))
	get_node("ShiftL").connect("mouse_exited", func(): off_shift())
	get_node("ShiftR").connect("mouse_exited", func(): off_shift())
	if has_node("HSlider"):
		var slider: HSlider = get_node("HSlider")
		slider.connect("value_changed", Callable(new_vis))
	
	pressed.connect( func(): clicked())
	mouse_entered.connect( func(): set_hover(true))
	mouse_exited.connect( func(): set_hover(false))
	new_vis()

func send_data():
	setting_node.setting_pressed(setting_name, setting_description, position.y)

func set_hover(value: bool):
	hovered = value
	new_vis()
func clicked():
	if on_arrow == 0: return
	
	if multi_option:
		var previous_option: int = current_option
		current_option+=on_arrow
		get_node("Anim").play("pressL" if on_arrow < 0 else "pressR")
		current_option = clampi(current_option, 0, options.size()-1)
		if previous_option != current_option:
			get_node("Changed").play()
			value_changed.emit(float(current_option))
	elif is_slider:
		var slider: HSlider = $HSlider
		if not (slider.value==slider.min_value or slider.value==slider.max_value):
			get_node("Anim").play("pressL" if on_arrow < 0 else "pressR")
			get_node("Changed").play()
		slider.value += on_arrow*slider.step
	
	new_vis()
func new_vis(_optional = 10.0):
	if no_setting_data: return
	GameSettings.change_setting(setting_code_name, $HSlider.value if is_slider else current_option)
	
	if has_node("HSlider"):
		@warning_ignore("incompatible_ternary")
		var slider_value = int(get_node("HSlider").value) if get_node("HSlider").step==snapped(get_node("HSlider").step, 1.0) else snappedf(get_node("HSlider").value, float(slider_step))
		if slider_value is float:
			slider_value = round(slider_value*1000.0) / 1000.0
		$Label.text = str(slider_value, slider_symbol)
	
	get_node("Label").modulate = "ffffff" if hovered else "9b9faa"
	
	if multi_option:
		get_node("Label").text = options[current_option]
		get_node("ShiftL").modulate = "5d5d5d" if current_option == 0 else ("ffffff" if hovered else "9b9faa")
		get_node("ShiftR").modulate = "5d5d5d" if current_option == options.size()-1 else ("ffffff" if hovered else "9b9faa")
	elif is_slider:
		var slider: HSlider = $HSlider
		get_node("ShiftL").modulate = "5d5d5d" if slider.value == slider.min_value else ("ffffff" if hovered else "9b9faa")
		get_node("ShiftR").modulate = "5d5d5d" if slider.value == slider.max_value else ("ffffff" if hovered else "9b9faa")

func shiftL() -> void:
	on_arrow = -1
	
func shiftR() -> void:
	on_arrow = 1
	
func off_shift() -> void:
	on_arrow = 0
	new_vis()
func hover_shift(button: int):
	on_arrow = button
	new_vis()
