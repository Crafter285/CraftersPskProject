extends Node2D

@onready var gauge_fill: TextureProgressBar = $GaugeFill
@onready var target_image: TextureRect = $TargetImage

func _ready() -> void:
	gauge_fill.hide()
	target_image.hide()

func update_charge(ratio: float) -> void:
	gauge_fill.show()
	gauge_fill.value = ratio * 50.0

func reset_charge() -> void:
	gauge_fill.value = 0.0
	gauge_fill.hide()

func show_target() -> void:
	target_image.show()

func hide_target() -> void:
	target_image.hide()
