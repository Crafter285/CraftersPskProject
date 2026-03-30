extends RigidBody3D

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var timer: Timer = $Timer
@onready var au: AudioStreamPlayer3D = $au

func _ready() -> void:
	var path = str("res://Objects/Gameplay/Mobibles/Textibles/", randi_range(1, 9),".png")
	sprite_3d.texture = load(path)


func _on_timer_timeout() -> void:
	au.stream = load(str("res://Objects/Gameplay/Mobibles/Textibles/mobible", randi_range(1, 3),".mp3"))
	au.play()
	timer.wait_time = randf_range(1.0, 5.0)
	timer.start()
