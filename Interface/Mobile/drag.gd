extends Control

signal drag_delta(delta: Vector2)

var dragging := false
var last_pos := Vector2.ZERO

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	connect("drag_delta", Callable(Grabpack.player, "touch_dragged"))

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			last_pos = event.position
		else:
			dragging = false

	elif dragging and event is InputEventScreenDrag:
		var delta = event.position - last_pos
		last_pos = event.position
		emit_signal("drag_delta", delta)
