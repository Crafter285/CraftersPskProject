extends Node3D

##If enabled, the jump pad will appear lit up, and will be able to be used by the players purple hand.
@export var powered: bool = true
@export var speed: float = 20.0

@onready var sm_jump_pad:MeshInstance3D = $SM_Jump_Pad
@onready var light = $OmniLight3D
@onready var jumped = $Jumped
@onready var jumped_2 = $Jumped2
@onready var jumped_3  = $Jumped3

const DASH_PAD_POWERED = preload("uid://b8lv7ltv7b0hq")

var using: bool = false
var dash_timer: float = 0.0

signal dash_completed
signal dash_cancelled
signal dash_started

func _ready():
	set_power(powered)

func _process(delta: float) -> void:
	if using:
		Grabpack.player.position = Grabpack.player.position.move_toward(global_position, speed*delta)
		
		dash_timer += 1.0*delta
		if dash_timer > 0.1:
			Grabpack.player.camera.fov += 1
		Grabpack.player.velocity = Vector3.ZERO
		Grabpack.player.jump_vel.y += 0.5*delta
		if Grabpack.player.position.distance_to(global_position) < 2.0:
			dash_completed.emit()
			Grabpack.right_retract()
			$Jets.play()
			jumped.fadeOut(40.0)
			jumped_2.fadeOut(40.0)
			using = false

func set_power(power: bool):
	var material: ORMMaterial3D = sm_jump_pad.get_surface_override_material(0)
	
	if not power:
		material.next_pass = null
	else:
		material.next_pass = DASH_PAD_POWERED
	light.visible = power
	powered = power

func area_entered(area):
	if area.is_in_group("DashHand") and powered:
		jumped.instantIn()
		jumped_2.instantIn()
		jumped_3.play()
		dash_started.emit()
		using = true
		#Grabpack.right_specific_rotation_axis("x", global_rotation.x-1.5)

func let_go(_hand: bool) -> void:
	if using:
		dash_cancelled.emit()
		jumped.fadeOut(40.0)
		jumped_2.fadeOut(40.0)
		using = false
