extends Node2D

@onready var sprite: Sprite2D = $Damage

var current_damage: float = 0.0

func _process(delta: float) -> void:
	if current_damage > 0.0:
		current_damage -= 2.0 * delta
		sprite.visible = true
		update_sprite()
	else: sprite.visible = false

func take_damage(amount: float = 10):
	current_damage += amount
	if current_damage > 100.0:
		update_sprite()
		await get_tree().create_timer(0.1).timeout
		Grabpack.kill_player()

func update_sprite():
	sprite.modulate = Color(Color.RED, current_damage / 100)
