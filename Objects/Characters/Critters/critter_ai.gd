extends CharacterBody3D

@export var animation_handler: Node3D = null
@export var spawn_sounds: Array[AudioStream]
@export var lunge_sounds: Array[AudioStream]
@export var lunge_roars: Array[AudioStream]
@export var despawn_y: float = -15.0
@export var zigzag: bool = true
@export var ground_speed: float = 4.0
@export var air_speed: float = 8.0
@export var return_markers: Array[Marker3D]

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var timer: Timer = $Timer

var prev_look: Vector3 = transform.origin
var LERP_SPEED: float = 5.0
var speed: float = 4.0

var zigzag_amplitude: float = 2.0
var zigzag_frequency: float = 0.5

var zigzag_timer: float = 0.0

var attacking: bool = false
var in_air: bool = false
var fleeing: bool = false
var return_mark_idx: int = 0

func _ready() -> void:
	play_stream(spawn_sounds[randi_range(0, spawn_sounds.size()-1)])
	zigzag = true if randi_range(0, 8)>5 else false

func _physics_process(delta: float) -> void:
	chase_process(delta)
	move_and_slide()
	
	if position.y < despawn_y: queue_free()

func move_ai(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var fake_vel = (next_location - current_location).normalized() * speed
	var forward_direction = (next_location - current_location).normalized()
	
	zigzag_timer += delta
	
	var up = Vector3.UP  # Assuming Y-up world
	var right_direction = forward_direction.cross(up).normalized()
	
	var zigzag_offset = right_direction * sin(zigzag_timer * zigzag_frequency * TAU) * zigzag_amplitude
	
	var combined_direction = (forward_direction + zigzag_offset).normalized()
	velocity = combined_direction * speed
	
	prev_look = lerp(prev_look, global_transform.origin + fake_vel, LERP_SPEED * delta)
	if not global_position.is_equal_approx(prev_look):
		look_at(prev_look)
	
	var zigzag_phase = sin(zigzag_timer * zigzag_frequency * TAU)
	handle_animation(zigzag_phase)

func move_forward(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * speed

	prev_look = lerp(prev_look, global_transform.origin + velocity, LERP_SPEED * delta)
	if not global_position.is_equal_approx(prev_look): look_at(prev_look)
	
	velocity = new_velocity

func handle_animation(offset: float):
	if not animation_handler: return
	if offset > 0.0:
		animation_handler.play("WalkRight")
	elif offset < 0.0:
		animation_handler.play("WalkLeft")

func chase_process(delta: float) -> void:
	if fleeing:
		speed = ground_speed*1.5
		animation_handler.play("Walk")
		animation_handler.animation_player.speed_scale = animation_handler.animation_player.speed_scale*1.5
		nav_agent.target_position = return_markers[return_mark_idx].global_position
		move_forward(delta)
		if global_position.distance_to(nav_agent.target_position) < 2.0:
			queue_free()
		return
	if attacking:
		if in_air:
			speed = air_speed
			if not is_on_floor():
				animation_handler.position.y = animation_handler.in_air_offset
				velocity.y -= 5.0 * delta
				animation_handler.play("InAir")
			else:
				in_air = false
				velocity = Vector3.ZERO
				animation_handler.play("Idle")
				await get_tree().create_timer(randf_range(0.2, 1.0)).timeout
				position.y += -animation_handler.walking_ground_offset
				animation_handler.position.y = animation_handler.walking_ground_offset
				attacking = false
		return
	if global_position.distance_to(Grabpack.player.global_position) < 4.0:
		velocity = Vector3.ZERO
		attacking = true
		animation_handler.play("Lunge")
		play_stream(lunge_sounds[randi_range(0, lunge_sounds.size()-1)])
		await get_tree().create_timer(0.2).timeout
		
		play_stream(lunge_roars[randi_range(0, lunge_roars.size()-1)])
		velocity.y = 2.0
		position.y += 0.05
		var y_vel: float = velocity.y
		move_forward(delta)
		velocity.y = y_vel
		in_air = true
		return
	
	nav_agent.target_position = Grabpack.player.global_position
	if zigzag:
		speed = ground_speed
		move_ai(delta)
	else:
		speed = ground_speed
		if animation_handler: animation_handler.play("Walk")
		move_forward(delta)

func _on_timer_timeout() -> void:
	zigzag_amplitude = randf_range(0.0, 4.0)
	zigzag_frequency = randf_range(0.0, 1.5)
	timer.start(randf_range(0.2, 1.0))

func _on_player_detection_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and in_air:
		Grabpack.player.camera.shake_camera(0.5)
		Grabpack.damage_player(18.0)
		play_sound("damage", 3, true)

func play_sound(sound: String, int_range: int, num_d: bool = false, volume: float = 0.0):
	var sound_node: String = str("res://Objects/Characters/Critters/Sound/", sound, randi_range(1, int_range), ".wav")
	var sound_stream = ResourceLoader.load(sound_node) as AudioStream
	if num_d:
		var new_sound: QuickSFXNoDir = QuickSFXNoDir.new()
		add_child(new_sound)
		new_sound.volume_db = volume
		new_sound.stream = sound_stream
		new_sound.play()
	else:
		var new_sound: QuickSFX = QuickSFX.new()
		add_child(new_sound)
		new_sound.volume_db = volume
		new_sound.global_position = global_position
		new_sound.stream = sound_stream
		new_sound.play()
func play_stream(sound_stream: AudioStream, num_d: bool = false):
	if num_d:
		var new_sound: QuickSFXNoDir = QuickSFXNoDir.new()
		add_child(new_sound)
		new_sound.stream = sound_stream
		new_sound.play()
	else:
		var new_sound: QuickSFX = QuickSFX.new()
		add_child(new_sound)
		new_sound.global_position = global_position
		new_sound.stream = sound_stream
		new_sound.play()

func step():
	play_sound("step", randi_range(1, 6), false, -10)

func _on_flare_detector_flare_entered() -> void:
	if attacking or in_air or fleeing: return
	play_stream(spawn_sounds[randi_range(0, spawn_sounds.size()-1)])
	fleeing = true
	return_mark_idx = randi_range(0, return_markers.size()-1)
