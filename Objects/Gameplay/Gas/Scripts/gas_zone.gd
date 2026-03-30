extends Area3D
class_name GasZone

@export var enabled: bool = false
##Seconds until the gas kills the player
@export var death_time: float = 30.0
@export var effect_speed: float = 0.01

@onready var gas_cover = $CanvasLayer/ColorRect
@onready var gas_shader: ShaderMaterial = gas_cover.material
@onready var layer_1 = $CanvasLayer/Layer1
@onready var layer_2 = $CanvasLayer/Layer2
@onready var layer_3 = $CanvasLayer/Layer3

var player_in_gas: bool = false

#GAS SHADER VARS:
var speed = 0.01
var increase_speed = 0.01
var decrease_speed = -0.1
var current_increase = 0.0
var current_gas_time: float = 0.0

var awaiting_enable: bool = false

func _ready():
	connect("body_entered", Callable(body_entered))
	connect("body_exited", Callable(body_exited))
	gas_cover.visible = false
	increase_speed = effect_speed
	reset_gas()

func reset_gas():
	set_shader_parameters(0.0)

func _process(delta):
	if not player_in_gas and not current_increase > 0.0:
		gas_cover.visible = false
		layer_1.playing = false
		layer_2.playing = false
		layer_3.playing = false
		current_gas_time = 0.0
		
		return
	if awaiting_enable:
		if enabled:
			speed = increase_speed
			player_in_gas = true
			awaiting_enable = false
			layer_1.play()
			layer_2.play()
			layer_3.play()
			reset_sound()
		return
	if not enabled or Grabpack.hud.gas_mask.equipped:
		player_in_gas = false
		awaiting_enable = false
		speed = decrease_speed
		current_gas_time -= 10.0 * delta
	gas_cover.visible = true
	# Gradually increase the values over time
	if gas_cover.material and gas_cover.material.shader:
		var shader_material = gas_cover.material
		var current_frequency = shader_material.get_shader_parameter("frequency")
		var current_amplitude = shader_material.get_shader_parameter("amplitude")
		var current_radial_frequency = shader_material.get_shader_parameter("radial_frequency")
		var current_radial_amount = shader_material.get_shader_parameter("radial_amount")
		var current_rotation_frequency = shader_material.get_shader_parameter("rotation_frequency")
		var current_rotation_amount = shader_material.get_shader_parameter("rotation_amount")
		var current_color_distortion_amount = shader_material.get_shader_parameter("color_distortion_amount")
		var current_chromatic_aberration_amount = shader_material.get_shader_parameter("chromatic_aberration_amount")

		# Increase each parameter slowly
		shader_material.set_shader_parameter("frequency", current_frequency + speed * delta)
		shader_material.set_shader_parameter("amplitude", current_amplitude + speed * 0.1 * delta)  # A smaller increase for amplitude
		shader_material.set_shader_parameter("radial_frequency", current_radial_frequency + speed * delta)
		shader_material.set_shader_parameter("radial_amount", current_radial_amount + speed * 0.05 * delta)  # Slightly smaller increase
		shader_material.set_shader_parameter("rotation_frequency", current_rotation_frequency + speed * delta)
		shader_material.set_shader_parameter("rotation_amount", current_rotation_amount + speed * 0.02 * delta)  # Smaller increase
		shader_material.set_shader_parameter("color_distortion_amount", current_color_distortion_amount + (speed if death_time-current_gas_time > 1.0 else speed*200.0 ) * 0.01 * delta)  # Very subtle increase
		shader_material.set_shader_parameter("chromatic_aberration_amount", current_chromatic_aberration_amount + speed * 0.01 * delta)  # Subtle increase
		current_increase += speed * delta
		current_gas_time += 1.0 * delta
		if current_gas_time > death_time:
			Grabpack.kill_player()
		layer_1.volume_db += speed * 1000.0 * delta
		if layer_1.volume_db > 1.0:
			layer_1.volume_db = 1.0
		layer_2.volume_db = layer_1.volume_db
		layer_3.volume_db = layer_1.volume_db

func reset_sound():
	layer_1.volume_db = -80
	layer_1.volume_db = -80
	layer_1.volume_db = -80

func set_shader_parameters(value: float):
	if gas_cover.material and gas_cover.material.shader:
		var shader_material = gas_cover.material
		shader_material.set_shader_parameter("frequency", value)
		shader_material.set_shader_parameter("amplitude", value)
		shader_material.set_shader_parameter("radial_frequency", value)
		shader_material.set_shader_parameter("radial_amount", value)
		shader_material.set_shader_parameter("rotation_frequency", value)
		shader_material.set_shader_parameter("rotation_amount", value)
		shader_material.set_shader_parameter("color_distortion_amount", value)
		shader_material.set_shader_parameter("chromatic_aberration_amount", value)

func body_entered(body):
	if body.is_in_group("Player"):
		if not enabled:
			awaiting_enable = true
			return
		Grabpack.hud.gas_mask.in_gas = true
		layer_1.play()
		layer_2.play()
		layer_3.play()
		reset_sound()
		speed = increase_speed
		player_in_gas = true
func body_exited(body):
	if body.is_in_group("Player"):
		Grabpack.hud.gas_mask.in_gas = false
		player_in_gas = false
		awaiting_enable = false
		speed = decrease_speed
