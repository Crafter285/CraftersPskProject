extends CharacterBody3D

@onready var idle_timer: Timer = $IdleTimer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast
@onready var tauntsfx: AudioStreamPlayer3D = $Taunt
var prev_look: Vector3 = transform.origin
var LERP_SPEED: float = 5.0
var spawning: bool = false

enum states {
	disabled,
	roaming,
	path_follow,
	chase
}
enum actions {
	idle,
	walk,
	run,
	jumpscare,
	taunt
}
enum path_follow_state {
	run,
	walk
}

@export var monster_visual: Node3D = null
@export var head_look_at: bool = false
@export var look_at_modifier: LookAtModifier3D = null
@export_category("State Settings")
@export var default_state: states = states.disabled
@export var kill_distance: float = 3.0
@export var death_screen_after_jumpscare: bool = true
##Plays when state switches from disabled to something else.
@export var spawn_animation: bool = false
@export_subgroup("Roaming")
@export var roaming_ai_marks: Node = null
@export var use_sound_tracking: bool = true
@export var crouch_footstep_distance: float = 2.0
@export var walk_footstep_distance: float = 5.0
@export var run_footstep_distance: float = 15.0
@export var grabpack_use_distance: float = 25.0
@export var use_visual_tracking: bool = true
@export var sight_distance: float = 30.0
@export_subgroup("Path Follow")
@export var path_follow_node: PathFollow3D = null
@export var path_move_action: path_follow_state = path_follow_state.walk
@export var path_finish_state: states = states.disabled
@export var glide_to_start: bool = true
@export var glide_to_path_speed: float = 5.0
@export var look_at_player_on_path: bool = false
@export var base_speed_on_player: bool = false
##Mess with this number until you feel the monster travels at an appropriate speed for your purpose.
@export var speed_divider: float = 1.5
@export var speed_animation_divider: float = 12.0
@export var max_speed: float = 12.0
@export var min_speed: float = 4.0
@export_subgroup("Chase")
@export var chase_move_action: path_follow_state = path_follow_state.run
@export var starting_taunt: bool = false
@export var starting_taunt_animation_name: String = ""
@export var starting_taunt_animation_speed: float = 1.0
@export_category("Movement")
@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var idle_time: Vector2 = Vector2(2.0, 4.0)

signal caught_player
@warning_ignore("unused_signal")
signal jumpscare_finished

var current_state: states = states.disabled
var current_action: actions = actions.walk

#ROAMING VARIABLES:
var current_mark: Marker3D = null
var tracking_sound: bool = false
var tracking_sound_position: Vector3 = Vector3.ZERO

#PATH FOLLOW VARIABLES:
var on_path: bool = false

func _ready() -> void:
	set_state(default_state)
	await get_tree().create_timer(0.05).timeout
	Grabpack.player.sound_manager.connect("sound",Callable(heard_sound))
	if head_look_at:
		look_at_modifier.target_node = look_at_modifier.get_path_to(Grabpack.player.camera)

func _physics_process(delta: float) -> void:
	if current_state == states.disabled: return
	
	if spawning: return
	if global_position.distance_to(Grabpack.player.global_position) < kill_distance:
		set_state(states.disabled)
		set_action(actions.jumpscare)
		return
	if current_state == states.roaming:
		roaming_process(delta)
		move_and_slide()
	elif current_state == states.chase:
		chase_process(delta)
		move_and_slide()
	elif current_state == states.path_follow:
		path_follow_process(delta)

func roaming_process(delta: float) -> void:
	get_sight()
	if current_action == actions.idle: return
	if not roaming_ai_marks: printerr("No AI Mark Parent Has Been Set!")
	if not current_mark:
		var rand_mark = roaming_ai_marks.get_child(randi_range(0, (roaming_ai_marks.get_child_count()-1)))
		current_mark = rand_mark
	nav_agent.target_position = current_mark.global_transform.origin
	if tracking_sound: nav_agent.target_position = tracking_sound_position
	
	move_ai(delta)
func chase_process(delta: float) -> void:
	if current_action == actions.idle: return
	if current_action == actions.taunt: return
	nav_agent.target_position = Grabpack.player.global_position
	move_ai(delta)
func path_follow_process(delta: float) -> void:
	if not path_follow_node: printerr("No Path Follow Node Has Been Set!")
	if not on_path:
		global_position = global_position.move_toward(path_follow_node.global_position, glide_to_path_speed * delta)
		if global_position.distance_to(path_follow_node.global_position) < 0.05: on_path = true
		else: return
	var speed: float = 0.0
	if path_move_action == path_follow_state.walk: speed = walk_speed
	else: speed = run_speed
	if base_speed_on_player:
		speed = global_position.distance_to(Grabpack.player.global_position) / speed_divider
		speed = clamp(speed, min_speed, max_speed)
		if path_move_action == path_follow_state.walk:
			monster_visual.animation_player.speed_scale = speed / speed_animation_divider
		else:
			monster_visual.animation_player.speed_scale = speed / speed_animation_divider
	path_follow_node.progress += speed * delta
	global_transform = path_follow_node.global_transform
	if path_follow_node.progress_ratio > 0.99:
		set_state(path_finish_state)

func move_ai(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * get_action_speed()

	prev_look = lerp(prev_look, global_transform.origin + velocity, LERP_SPEED * delta)
	if not  global_position==prev_look: look_at(prev_look)
	
	velocity = new_velocity
func set_state(state: states):
	idle_timer.stop()
	prev_look = $PrevLookReset.global_position
	if not state == states.disabled: visible = true
	if current_state == states.disabled and spawn_animation and not state == states.disabled:
		monster_visual.play_animation(monster_visual.anims.spawn)
		GlobalSound.quicksfx(monster_visual.sound.spawn_sound, 0.0, global_position)
		await monster_visual.animation_player.animation_finished
	current_state = state
	if head_look_at: look_at_modifier.active = false
	if state == states.roaming:
		set_action(actions.walk)
	elif state == states.path_follow:
		on_path = !glide_to_start
		path_follow_node.progress_ratio = 0.0
		if head_look_at and look_at_player_on_path: look_at_modifier.active = true
		if path_move_action == path_follow_state.walk: set_action(actions.walk)
		else: set_action(actions.run)
	elif state == states.chase:
		if head_look_at: look_at_modifier.active = true
		if starting_taunt:
			monster_visual.taunt_name =  starting_taunt_animation_name
			monster_visual.taunt_speed = starting_taunt_animation_speed
			tauntsfx.stream = monster_visual.sound.taunt_sound
			tauntsfx.play()
			set_action(actions.taunt)
		else:
			if chase_move_action == path_follow_state.walk: set_action(actions.walk)
			else: set_action(actions.run)
func set_action(action: actions):
	current_action = action
	if action == actions.idle:
		current_mark = null
		idle_timer.start(randf_range(idle_time.x, idle_time.y))
		monster_visual.play_animation(actions.idle)
	elif action == actions.walk:
		monster_visual.play_animation(actions.walk)
	elif action == actions.run:
		monster_visual.play_animation(actions.run)
	elif action == actions.jumpscare:
		caught_player.emit()
		Grabpack.set_movable(false)
		Grabpack.player.visible = false
		monster_visual.play_animation(actions.jumpscare)
	elif action == actions.taunt:
		monster_visual.play_animation(actions.taunt)
		await monster_visual.animation_player.animation_finished
		if chase_move_action == path_follow_state.walk: set_action(actions.walk)
		else: set_action(actions.run)

func get_sight():
	var to_player = (Grabpack.player.global_position - global_position).normalized()
	var forward = -transform.basis.z
	var angle_cos = forward.dot(to_player)
	if angle_cos > 0.9:
		raycast.target_position = raycast.to_local(Grabpack.player.global_position)
		if raycast.is_colliding() and raycast.get_collider() == Grabpack.player and global_position.distance_to(Grabpack.player.global_position) < sight_distance:
			set_state(states.chase)
func heard_sound(sound_name: String = "walk"):
	if current_state == states.roaming:
		if not use_sound_tracking: return
		if current_action == actions.idle: set_action(actions.walk)
		elif randi_range(1, 2) == 1: return
		if sound_name == "walk" and global_position.distance_to(Grabpack.player.global_position) > walk_footstep_distance: return
		if sound_name == "run" and global_position.distance_to(Grabpack.player.global_position) > run_footstep_distance: return
		if sound_name == "jump" and global_position.distance_to(Grabpack.player.global_position) > walk_footstep_distance: return
		if sound_name == "grabpack" and global_position.distance_to(Grabpack.player.global_position) > grabpack_use_distance: return
		tracking_sound = true
		tracking_sound_position = Grabpack.player.position
func get_action_speed():
	if current_action == actions.idle:
		return 0.0
	elif current_action == actions.walk:
		return walk_speed
	elif current_action == actions.run:
		return run_speed
	elif current_action == actions.jumpscare:
		return 0.0
	elif current_action == actions.taunt:
		return 0.0

func nav_finished() -> void:
	tracking_sound = false
	set_action(actions.idle)
func idle_finished() -> void:
	set_state(states.roaming)
	if current_state == states.roaming:
		set_action(actions.walk)
