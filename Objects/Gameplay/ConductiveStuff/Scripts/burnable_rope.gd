extends Node3D

signal burned

@export var conductive_panel: Node3D
@export var burn_duration : float = 1.0

const SHADER_PATH : String = "res://Objects/Gameplay/ConductiveStuff/Shaders/burnable_rope.gdshader"
const ALBEDO_PATH : String = "res://Objects/Gameplay/ConductiveStuff/Textures/hempen_rope_model_0.png"
const ORM_PATH    : String = "res://Objects/Gameplay/ConductiveStuff/Textures/hempen_rope_model_1.png"
const NORMAL_PATH : String = "res://Objects/Gameplay/ConductiveStuff/Textures/hempen_rope_model_2.png"

var _material : ShaderMaterial = null
var _burning  : bool           = false
var _progress : float          = 0.0

@onready var _mesh : MeshInstance3D = $Object_5


func _ready() -> void:
	_setup_shader()


func _setup_shader() -> void:
	var shader : Shader = load(SHADER_PATH)
	if shader == null:
		push_error("RopeBurn: shader not found → " + SHADER_PATH)
		return

	_material = ShaderMaterial.new()
	_material.shader = shader

	_material.set_shader_parameter("texture_albedo",       load(ALBEDO_PATH))
	_material.set_shader_parameter("texture_orm",          load(ORM_PATH))
	_material.set_shader_parameter("texture_normal",       load(NORMAL_PATH))
	_material.set_shader_parameter("normal_scale",         1.0)
	_material.set_shader_parameter("burn_progress",        0.0)
	_material.set_shader_parameter("ember_width",          0.06)
	_material.set_shader_parameter("ember_glow_intensity", 5.0)
	_material.set_shader_parameter("noise_scale",          10.0)
	_material.set_shader_parameter("noise_strength",       0.07)
	_material.set_shader_parameter("char_color",           Color(0.07, 0.05, 0.04, 1.0))
	_material.set_shader_parameter("ember_color",          Color(1.00, 0.32, 0.02, 1.0))
	_material.set_shader_parameter("ash_color",            Color(0.28, 0.26, 0.24, 1.0))

	_mesh.set_surface_override_material(0, _material)


func start_burn() -> void:
	_burning = true
	$HandGrab.queue_free()


func _process(delta: float) -> void:
	if not _burning:
		return
	if not is_instance_valid(_mesh):
		_burning = false
		return
	_progress = min(_progress + delta / burn_duration, 1.2)
	_material.set_shader_parameter("burn_progress", _progress)
	if _progress >= 1.2:
		_burning = false
		await get_tree().create_timer(3.0).timeout
		queue_free()

var current_hand_type
func _on_hand_grab_grabbed(hand: bool) -> void:
	if hand and Grabpack.right_hand.current_hand_node.name == "ConductiveHand":
		current_hand_type = hand
		if conductive_panel.is_fire2 == true:
			$Heated_Release.play()
			conductive_panel._reset_uv()
			$GPUParticles3D.emitting = true
			start_burn()
			await get_tree().create_timer(burn_duration).timeout
			if is_instance_valid(_mesh):
				_mesh.queue_free()
			await get_tree().create_timer(1.0).timeout
			if is_instance_valid($GPUParticles3D):
				$GPUParticles3D.emitting = false
			burned.emit()
