extends Camera3D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomStrength

func shake_camera(strength: float = 30.0, shake_time: float = 5.0):
	randomStrength = strength
	shakeFade = shake_time
	apply_shake()

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shakeFade * delta)
		
		var offset = randomOffset()
		h_offset = offset.x
		v_offset = offset.y

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
