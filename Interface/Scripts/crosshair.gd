extends Node2D

@onready var circle = $CrossHair
@onready var custom: Sprite2D = $CustomCrosshair
@onready var centre: Sprite2D = $CrossHair/Centre

var circle_value:float = 1.0

func set_crosshair(image: Texture2D, color: Color = Color.WHITE, size: Vector2 = Vector2(0.74, 0.74), ring: bool = false):
	custom.texture = image
	custom.self_modulate = color
	custom.scale = size
	circle.visible = ring
	centre.visible = false
	custom.visible = true
func reset_crosshair():
	centre.visible = true
	circle.visible = true
	custom.visible = false

func set_value(new_value: float):
	var material_circle: ShaderMaterial = circle.material
	
	material_circle.set_shader_parameter("value", new_value)
	circle_value = new_value
