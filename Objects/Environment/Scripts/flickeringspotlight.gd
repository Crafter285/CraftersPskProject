@tool
extends SpotLight3D
class_name FlickeringSpotLight

@export var frequency: float = 1.0
var noise: NoiseTexture2D
@export var max_energy: float = 2.0
@export var min_energy: float = 0.5
@export var visible_energy: float = 0.0

var time_passed: float = 0.0

func _ready() -> void:
	if noise: return
	var new_noise: NoiseTexture2D = NoiseTexture2D.new()
	var new_noise_lite: FastNoiseLite = FastNoiseLite.new()
	new_noise_lite.frequency = frequency
	new_noise_lite.seed = randi_range(1, 10000)
	new_noise.noise = new_noise_lite
	noise = new_noise

func _process(delta):
	if Engine.is_editor_hint():
		noise.noise.frequency = frequency
	time_passed += delta
	
	var test = noise.noise.get_noise_1d(time_passed)
	test = (test + 1.0) / 2.0
	test = lerp(min_energy, 1.0, test)
	
	var sampled_noise = test
	sampled_noise = abs(sampled_noise) * max_energy
	
	if sampled_noise > visible_energy: light_energy = sampled_noise
	else: light_energy = 0.0
