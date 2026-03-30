extends RigidBody3D

@export var pull_off_point: float = 15.0
@export var pull_speed: float = 3.5

@onready var hand_grab = $HandGrab

var pulling: bool = false

var torn = false

var target_rotation: float = 0.0

func _ready():
	#hand_grab.connect("grabbed", Callable(grab))
	hand_grab.connect("pulled", Callable(pull))
	hand_grab.connect("let_go", Callable(release))
	target_rotation = rotation_degrees.y - pull_off_point
	freeze = true

func _process(delta):
	if pulling:
		pull_speed += 40.0 * delta
		if pull_off_point > 0:
			rotation_degrees.y -= pull_speed * delta
			if rotation_degrees.y < target_rotation:
				freeze = false
				rotation_degrees.x += 20
				hand_grab.release_grabbed()
				hand_grab.queue_free()
				collision_layer &= ~1
		else:
			rotation_degrees.y += pull_speed * delta
			if rotation_degrees.y > target_rotation:
				freeze = false
				rotation_degrees.x += 20
				hand_grab.release_grabbed()
				hand_grab.queue_free()
				collision_layer &= ~1

func grab(_hand):
	if torn:
		rotation_degrees.x += 20
func pull(_hand):
	pulling = true
func release(_hand):
	pulling = false
