extends Control

@onready var audio_stream_player = $AudioStreamPlayer
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("FadeOut")
	audio_stream_player.play(10.0)
	await animation_player.animation_finished
	Game.load_scene(Game.previous_level)
