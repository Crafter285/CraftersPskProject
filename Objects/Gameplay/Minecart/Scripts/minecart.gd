extends PathFollow3D

@export var enabled: bool = true
@export var max_speed: float = 3.0
@export var acceleration: float = 1.0
@export var looping_track: bool = true

var speed: float = 0.0
var moving: bool = false
var move_dir: float = 1.0

func _process(delta):
	if moving:
		speed += move_dir * delta
		if speed > max_speed:
			speed = max_speed
		if speed < -max_speed:
			speed = -max_speed
	else:
		if speed > 0.0:
			speed -= acceleration * delta
		if speed < 0.0:
			speed += acceleration * delta
		if speed > -0.1 and speed < 0.1:
			speed = 0.0
	
	#Move Minecart
	if enabled and not speed == 0.0:
		var pre_progress: float = progress_ratio
		progress += speed * delta
		if pre_progress > 0.95 and progress_ratio < 0.1 and not looping_track:
			progress -= speed * delta
		if pre_progress < 0.1 and progress_ratio > 0.95 and not looping_track:
			progress -= speed * delta

func _on_hand_grab_pulled(_hand):
	moving = true
	move_dir = -acceleration
func _on_hand_grab_let_go(_hand):
	moving = false

func _on_hand_grab_2_pulled(_hand):
	moving = true
	move_dir = acceleration
func _on_hand_grab_2_let_go(_hand):
	moving = false
