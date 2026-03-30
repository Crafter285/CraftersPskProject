extends Node3D

#SETTINGS:
@export_category("Hand Settings")

var hands: Array [PackedScene]

@onready var grabpack = $"../.."
@onready var ray_cast_3d = $"../../../Neck/RayCast3D"
@onready var direction_cast = $DirectionCast
@onready var player = $"../../.."
@onready var air_grab_point = $"../../../Neck/AirGrabPoint"

@onready var hand_pos = $"../LayerWalk/CanonAttachRight/HandPos"
@onready var hand_fake = $"../RightHandFake"
@onready var wire_container = $"../RightWireContainer"
@onready var item_pos: Marker3D = $Hands/ItemPos

@onready var animation: Node = $"../../GrabpackAnimationHandler"
@onready var sound_manager = $"../../../SoundManager"
@onready var timer = $Timer
@onready var right_auto_correct: Area3D = $"../RightAutoCorrect"
@onready var right_wire_special: Node3D = $"../RightWireSpecial"

#HAND SYSTEM

var hand_queue: int = 0
var current_hand: int = 0
var current_hand_node = null

#Loaded Hand Settings

var fire_mode_launch: bool = false
var fire_mode_animation: bool = false
var fire_mode_animation_string: String = "ShootIn"
var hand_send_signals: bool = false
var hand_signal_connector: HandSignalConnector = null
var hand_useless: bool = true
var hand_animations_node: HandUseAnimations = null
var hand_uses_animations: bool = false
var hand_particle_emitter: HandDisableParticles = null
var hand_uses_emitter: bool = false

var hand_attached: bool = true
var hand_retracting: bool = false
var hand_travelling: bool = false
var hand_reached_point: bool = false
var hand_changed_point: bool = false
var hand_grab_point: Vector3 = Vector3.ZERO
var quick_retract: bool = true
var holding_object: bool = false
var hand_hold_time: float = 0.0
var pulling: bool = false
var wire_unwrap: bool = true
var wire_wrap: bool = true
var awaiting_switch: bool = false
var retract_click: bool = false

var disabled: bool = false
var retract_type = false
var hand_speed: float = 35.0
var impact_distance:float = 15.0

var exit_size: Vector3 = Vector3(1.0, 1.0, 1.0)

func _ready():
	hand_speed = player.hand_speed
	hands = player.enabled_hands

func _process(_delta): if hand_attached: global_transform = hand_pos.global_transform
func _physics_process(delta: float) -> void:
	if awaiting_switch and hand_attached:
		current_hand = -1
		if grabpack.current_grabpack == 1: switch_hand(0, hand_queue)
		else: switch_hand(1, hand_queue)
		awaiting_switch = false
	if holding_object:
		if Input.is_action_pressed("handright") and not retract_click:
			hand_hold_time += 1.0 * delta
			if hand_hold_time > 0.32:
				holding_object = false
		elif Input.is_action_just_released("handright"):
			if retract_click:
				retract_click = false
				return
			else:
				sort_hand_use()
				hand_hold_time = 0.0
	else:
		hand_hold_time = 0.0
		if Input.is_action_just_pressed("handright"):
			sort_hand_use()
		elif Input.is_action_just_released("handright"):
			if pulling:
				retract_hand()
				pulling = false
	if not hand_attached:
		scale = exit_size
		if hand_travelling:
			position = position.move_toward(hand_grab_point, hand_speed * delta)
			if position == hand_grab_point:
				hand_reached_point = true
				hand_travelling = false
				
				if not pulling:
					sound_manager.cable_sound(true, false)
				if quick_retract:
					timer.start()
				
				#Send Signals
				if hand_send_signals:
					hand_signal_connector.emit_signal("hand_reached_target")
				
				if hand_changed_point or not direction_cast.is_colliding(): return
				play_animation("straight")
				var target_normal = direction_cast.get_collision_normal()
				if target_normal.dot(Vector3.UP) > 0.001 or target_normal.y < 0:
					if target_normal.y > 0:
						rotation_degrees.x = -90
					elif target_normal.y < 0:
							rotation_degrees.x = 90
				else:
					look_at(global_position - target_normal)
		elif not hand_changed_point and not hand_retracting:
			if not $FingerFingy3.is_colliding():
				rotation.z -= 30.0*delta
			if not $FingerFingy.is_colliding():
				play_animation("grabhalf")
			else:
				play_animation("straight")
		
		if hand_reached_point:
			if not hand_grab_point == position:
				hand_travelling = true
				hand_reached_point = false
			else:
				position = hand_grab_point
		
		if hand_retracting:
			var next_point
			if not right_wire_special.get_child_count() > 0:
				next_point = wire_container.get_retract_path()
			else:
				if not right_wire_special.retract_paused: 
					next_point = right_wire_special.get_last_point().position
					if not right_wire_special.get_child_count() > 1:
						next_point = hand_fake.global_position
				else: next_point = position
			if next_point is bool:
				position = hand_fake.position
			else:
				position = position.move_toward(next_point, hand_speed*1.4 * delta)
				if position.distance_to(next_point) > 0.1:
					look_at(next_point, Vector3.DOWN)
					rotation.x += 3.0
			if position.distance_to(hand_fake.global_position) < 0.2:
				animation.hand_used(true, 1.0)
				play_animation("retract")
				sound_manager.cable_sound(true, false)
				sound_manager.retract_hand()
				wire_container.end_wire()
				right_wire_special.clear_wire()
				hand_attached = true
				hand_retracting = false
				hand_changed_point = false
				wire_unwrap = true
				wire_wrap = true
				
				#Send Signals
				if hand_send_signals:
					hand_signal_connector.emit_signal("hand_finished_retract")
	
	if not holding_object:
		if Input.is_action_just_pressed("hand_up"):
			switch_hand(1, current_hand + 1)
		elif Input.is_action_just_pressed("hand_down"):
			switch_hand(1, current_hand - 1)

func _input(event: InputEvent) -> void:
	if not holding_object:
		if event is InputEventKey and event.pressed:
			if event.keycode >= KEY_0 and event.keycode <= KEY_9:
				var switch_num: int = -1
				switch_num = event.keycode - KEY_0 # Convert keycode to number
				if queue_test(switch_num-1): switch_hand(1, switch_num-1)

func queue_test(hand_index: int):
	var test_queue: int = hand_index
	if test_queue < 0:
		test_queue = 0
	if test_queue > hands.size()-1:
		test_queue = hands.size()-1
	if test_queue == current_hand:
		return false
	return true
func sort_hand_use():
	if not hand_useless:
		if fire_mode_launch:
			if hand_attached:
				if grabpack.grabpack_lowered or not player.movable: return
				launch_hand()
				
				#Send Signals
				if hand_send_signals:
					hand_signal_connector.emit_signal("hand_used")
			elif not hand_retracting:
				if not holding_object:
					retract_click = true
					if hand_travelling:
						retract_hand()
					if not pulling:
						pulling = true
						sound_manager.cable_sound(true, true)
		elif not hand_useless:
			fire_non_launchable()
func launch_hand():
	if not grabpack.grabpack_usable:
		return
	if disabled:
		GlobalSound.quick_local_sfx(load("res://Player/Sound/Grabpack/SW_Grabpack_BrokenLaunch_01.wav"), 0.0)
		return
	if ray_cast_3d.is_colliding():
		hand_grab_point = ray_cast_3d.get_collision_point()
	else:
		hand_grab_point = air_grab_point.global_position
	wire_container.start_wire()
	
	animation.hand_used(true, 0.0)
	play_animation("fire")
	
	sound_manager.launch_hand()
	sound_manager.cable_sound(true, true)
	hand_attached = false
	hand_travelling = true
	wire_wrap = true
	
	position = hand_fake.global_position
	
	#Send Signals
	if hand_send_signals:
		hand_signal_connector.emit_signal("hand_launched")
	
	right_auto_correct.position = hand_grab_point
	await get_tree().create_timer(0.2).timeout
	right_auto_correct.position = Vector3(0.0, -50.0, 0.0)
func fire_non_launchable():
	if not grabpack.grabpack_usable:
		return
	if fire_mode_animation: animation.hand_used(true, 0.0)
	if hand_send_signals:
		hand_signal_connector.emit_signal("hand_used")
func retract_hand():
	if hand_attached:
		return
	if grabpack.global_position.distance_to(hand_grab_point) > impact_distance:
		retract_type = true
	else:
		retract_type = false
	play_animation("reverse")
	hand_travelling = false
	hand_reached_point = false
	hand_retracting = true
	quick_retract = true
	sound_manager.cable_sound(true, true)
	
	#Send Signals
	if hand_send_signals:
		hand_signal_connector.emit_signal("hand_started_retract")

func switch_hand(type: int, new_hand: int):
		if not hand_attached: return
		if disabled: return
		
		if new_hand > hands.size()-1:
			new_hand = 0
		elif new_hand < 0:
			new_hand = hands.size()-1
		
		queue_hand(new_hand)
		if type == 0:
			animation.animation_tree.set("parameters/QuickSwitchAnim/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		elif type == 1:
			if not grabpack.grabpack_switchable_hands: return
			if player.hand_switch_animation == player.hand_anims.Ch4:
				if animation.animation_tree.get("parameters/QuickSwitchAnim/active") == true: return
				#else: switch_animation.stop()
				animation.animation_tree.set("parameters/SwitchSpeed/scale", 2.0)
				animation.animation_tree.set("parameters/QuickSwitchAnim/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			elif player.hand_switch_animation == player.hand_anims.Ch3:
				animation.animation_tree.set("parameters/SwitchSpeed/scale", 2.0)
				animation.animation_tree.set("parameters/QuickSwitchAnim/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			else:
				animation.animation_tree.set("parameters/SwitchSpeed/scale", 2.0)
				animation.animation_tree.set("parameters/QuickSwitchAnim/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

#HAND DATA
func set_hand(hand_index: int):
	if not current_hand_node == null:
		current_hand_node.queue_free()
		current_hand_node = null
	var new_hand = hands[hand_index].instantiate()
	get_node("Hands").add_child(new_hand)
	
	current_hand_node = new_hand
	current_hand = hand_index
	
	#LOAD SETTINGS:
	fire_mode_launch = new_hand.has_node("FireModeLaunch")
	fire_mode_animation = new_hand.has_node("FireModeAnimation")
	if fire_mode_animation:
		fire_mode_animation_string = new_hand.get_node("FireModeAnimation").animation_string
	hand_send_signals = new_hand.has_node("HandSignalConnector")
	if hand_send_signals:
		hand_signal_connector = new_hand.get_node("HandSignalConnector")
	hand_uses_emitter = new_hand.has_node("HandDisableParticles")
	if hand_uses_emitter:
		hand_particle_emitter = new_hand.get_node("HandDisableParticles")
	hand_useless = new_hand.has_node("Useless")
	hand_uses_animations = new_hand.has_node("HandUseAnimations")
	if hand_uses_animations:
		hand_animations_node = new_hand.get_node("HandUseAnimations")
	if new_hand.has_node("HandCrosshair"):
		var crosshair_settings = new_hand.get_node("HandCrosshair")
		Grabpack.hud.crosshair.set_crosshair(crosshair_settings.crosshair_image, crosshair_settings.crosshair_color, crosshair_settings.crosshair_size, crosshair_settings.display_ring)
	else:
		Grabpack.hud.crosshair.reset_crosshair()

func set_queued_hand():
	set_hand(hand_queue)
func queue_hand(hand_index: int):
	hand_queue = hand_index
	
	if hand_queue < 0:
		hand_queue = 0
	if hand_queue > hands.size()-1:
		hand_queue = hands.size()-1
func queue_hand_switch(hand_index: int):
	if disabled: return
	hand_queue = hand_index
	
	if hand_queue < 0:
		hand_queue = 0
	if hand_queue > hands.size()-1:
		hand_queue = hands.size()-1
	
	awaiting_switch = true

func play_animation(anim_name: String):
	if not hand_uses_animations:
		return
	hand_animations_node.animation_player.play(anim_name)
func seek_animation(time: float):
	if not hand_uses_animations:
		return
	hand_animations_node.animation_player.seek(time)

func disable_hand():
	disabled = true
	if hand_uses_emitter:
		hand_particle_emitter.enable()
func enable_hand():
	disabled = false
	if hand_uses_emitter:
		hand_particle_emitter.disable()
