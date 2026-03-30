extends StaticBody3D

@onready var puzzle_pole_handle = $PuzzlePoleHandle
@onready var laser = $PuzzlePoleHandle/Laser
@onready var ray_cast_3d = $PuzzlePoleHandle/RayCast3D
@onready var animation_player = $AnimationPlayer
@onready var hand_grab = $PuzzlePoleHandle/PuzzlePole_LowerFlap/HandGrab
@onready var hand_grab_turret = $PuzzlePoleHandle/PuzzlePole_LowerFlap/HandGrabTurret
@onready var wire: CSGMesh3D = $PuzzlePoleHandle/Wire
@onready var top_mesh: MeshInstance3D = $PuzzlePole_Base/SM_PuzzlePole_Top

@onready var rotatesfx: AudioStreamPlayer = $Rotate
@onready var hit: AudioStreamPlayer = $Hit
@onready var activate: AudioStreamPlayer = $Activate
@onready var lock: AudioStreamPlayer = $Lock
@onready var powering: AudioStreamPlayer = $Powering

const POWER_POLE_ADV_ON = preload("uid://diletnvfqm5jm")

var hands: int = 0
var handle_rotation: Vector3 = Vector3.ZERO
var rotate_speed: float = 300.0

var pushing: bool = false
var push_hand: bool = false
var is_turret: bool = false
var hand_node: Node3D = null
var is_powered: bool = false

func _ready():
	handle_rotation = puzzle_pole_handle.rotation_degrees

func _process(delta):
	if hands > 0:
		if Input.is_action_just_pressed("rotate_left"):
			handle_rotation.y = handle_rotation.y-45
			rotatesfx.play()
		elif Input.is_action_just_pressed("rotate_right"):
			handle_rotation.y = handle_rotation.y+45
			rotatesfx.play()
		laser.visible = true
		laser.scale.x = ray_cast_3d.global_position.distance_to(ray_cast_3d.get_collision_point())
	else:
		laser.visible = false
	if puzzle_pole_handle.rotation_degrees.y < handle_rotation.y:
		puzzle_pole_handle.rotation_degrees.y += rotate_speed * delta
	elif puzzle_pole_handle.rotation_degrees.y > handle_rotation.y:
		puzzle_pole_handle.rotation_degrees.y -= rotate_speed * delta
	if abs(puzzle_pole_handle.rotation_degrees.y - handle_rotation.y) < 1.0:
		puzzle_pole_handle.rotation_degrees.y = handle_rotation.y
	
	if wire.visible:
		if Grabpack.grabpack.wire_powered and not is_powered:
			top_mesh.get_surface_override_material(0).next_pass = POWER_POLE_ADV_ON
			powering.play()
			is_powered = true
		if is_powered and not Grabpack.grabpack.wire_powered:
			top_mesh.get_surface_override_material(0).next_pass = null
			powering.stop()
			is_powered = false

func _on_hand_grab_grabbed(hand):
	hands += 1
	if hands < 2:
		activate.play()
		Grabpack.selection_wheel = false
	if hand:
		Grabpack.right_hand.wire_wrap = false
	else:
		Grabpack.left_hand.wire_wrap = false
func _on_hand_grab_let_go(hand):
	hands -= 1
	if hands < 1:
		lock.play()
		Grabpack.selection_wheel = true
	if hand:
		Grabpack.right_hand.wire_wrap = true
	else:
		Grabpack.left_hand.wire_wrap = true

func grab_hand(hand):
	if is_turret: return
	pushing = true
	push_hand = hand
	hand_grab.update_every_frame = true
	if hand:
		if Grabpack.right_hand.hand_retracting:
			if not wire.visible: return
			
			animation_player.play("hit_back")
			hand_grab.update_every_frame = true
			hand_grab.usable_while_retracting = true
			Grabpack.right_hand.right_wire_special.get_last_point().last = false
			Grabpack.right_hand.right_wire_special.get_last_point().hide()
			Grabpack.right_hand.right_wire_special.retract_paused = true
			await animation_player.animation_finished
			wire.hide()
			
			is_powered = false
			top_mesh.get_surface_override_material(0).next_pass = null
			powering.stop()
			
			Grabpack.right_hand.right_wire_special.retract_paused = false
			hand_grab.usable_while_retracting = false
			Grabpack.right_hand.right_wire_special.next_retract_point()
		else:
			if wire.visible: return
			
			animation_player.play("hit")
			wire.show()
			
			if Grabpack.grabpack.wire_powered: 
				top_mesh.get_surface_override_material(0).next_pass = POWER_POLE_ADV_ON
				powering.play()
				is_powered = true
			if not Grabpack.right_hand.right_wire_special.has_start():
				Grabpack.right_wire_custom(true, false, $PuzzlePoleHandle/Point1.global_position)
			else:
				var previous_point = Grabpack.right_hand.right_wire_special.get_last_point()
				previous_point.first = false
				previous_point.last = false
				previous_point.look_to = $PuzzlePoleHandle/Point1.global_position
		Grabpack.right_hand.wire_unwrap = false
	else:
		if Grabpack.left_hand.hand_retracting:
			if not wire.visible: return
			
			animation_player.play("hit_back")
			hand_grab.update_every_frame = true
			hand_grab.usable_while_retracting = true
			Grabpack.left_hand.left_wire_special.get_last_point().last = false
			Grabpack.left_hand.left_wire_special.retract_paused = true
			Grabpack.left_hand.left_wire_special.get_last_point().hide()
			await animation_player.animation_finished
			wire.hide()
			
			is_powered = false
			top_mesh.get_surface_override_material(0).next_pass = null
			powering.stop()
			
			Grabpack.left_hand.left_wire_special.retract_paused = false
			hand_grab.usable_while_retracting = false
			Grabpack.left_hand.left_wire_special.next_retract_point()
			
		else:
			if wire.visible: return
			
			animation_player.play("hit")
			wire.show()
			
			if Grabpack.grabpack.wire_powered: 
				top_mesh.get_surface_override_material(0).next_pass = POWER_POLE_ADV_ON
				powering.play()
				is_powered = true
			if not Grabpack.left_hand.left_wire_special.has_start():
				Grabpack.left_wire_custom(true, false, $PuzzlePoleHandle/Point1.global_position)
			else:
				var previous_point = Grabpack.left_hand.left_wire_special.get_last_point()
				previous_point.first = false
				previous_point.last = false
				previous_point.look_to = $PuzzlePoleHandle/Point1.global_position
		Grabpack.left_hand.wire_unwrap = false
func remove_hand(_hand):
	if animation_player.is_playing() and animation_player.current_animation == "hit" and pushing:
		animation_player.play("hit_back")
		wire.hide()
		hand_grab.update_every_frame = false
		hand_grab_turret.release_grip()
	pushing = false
func hand_launch():
	if is_turret:
		hand_grab_turret.release_grip()
		hand_node.hand_grab_point = ray_cast_3d.get_collision_point()
		#hand_node.wire_unwrap = true
		return
	if pushing:
		hand_grab.enabled = false
		hand_grab.stop_grabbing()
		hand_grab.update_every_frame = false
		if push_hand:
			Grabpack.right_wire_custom(false, true, Vector3.ZERO, $PuzzlePoleHandle/Point2.global_position)
			Grabpack.right_position(ray_cast_3d.get_collision_point())
			Grabpack.right_hand.hand_changed_point = false
		else:
			Grabpack.left_wire_custom(false, true, Vector3.ZERO, $PuzzlePoleHandle/Point2.global_position)
			Grabpack.left_position(ray_cast_3d.get_collision_point())
			Grabpack.left_hand.hand_changed_point = false
	fix_hand_pause()

func _on_hand_grab_turret_grabbed(hand):
	is_turret = true
	hand_node = hand
	hand.wire_unwrap = false
	if hand.hand_retracting:
		animation_player.play("hit_back")
		hand_grab_turret.release_grip()
	else:
		animation_player.play("hit")
func _on_hand_grab_turret_let_go(hand):
	is_turret = false
	hand_node = hand

func fix_hand_pause():
	if pushing:
		if push_hand:
			Grabpack.right_hand.hand_changed_point = false
			Grabpack.right_hand.quick_retract = true
		else:
			Grabpack.left_hand.hand_changed_point = false
			Grabpack.left_hand.quick_retract = true

func hand_enable(): hand_grab.enabled = true
