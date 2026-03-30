extends Node3D

var charge: float = 0.0
var is_charging: bool = false
var fully_charged: bool = false
@export var max_charge: float = 3.0
@export var stop_particles_on_full: bool = false

signal power_25
signal power_50
signal power_75
signal power_100

@onready var pressure_ui = get_tree().get_root().find_child("pressure", true, false)
@onready var hand_grab: Area3D = $"../DraggableObject3D/HandGrab"
@onready var draggable: DraggableObject3D = get_parent().get_node("DraggableObject3D")

func _ready() -> void:
	hand_grab.enabled = false
	# Connect signals in code so they always work
	hand_grab.pulled.connect(_on_hand_grab_pulled)
	hand_grab.let_go.connect(_on_hand_grab_let_go)
	
	var audio = AudioStreamPlayer3D.new()
	audio.name = "ChargeSound"
	audio.stream = load("res://CraftersPskExtension/Materials/PressureStuff/SW_SFX_Grabpack_PressureHand_Build.wav")
	audio.autoplay = false
	add_child(audio)

func _get_particles() -> Array:
	var hand = Grabpack.right_hand.current_hand_node
	if hand and hand.name == "PressureHand":
		return [hand.get_node("GPUParticles3D"), hand.get_node("GPUParticles3D2")]
	return []

func _process(delta: float) -> void:
	hand_grab.enabled = Grabpack.right_hand.current_hand_node.name == "PressureHand"
	
	if is_charging:
		charge += delta
		charge = clamp(charge, 0.0, max_charge)
		pressure_ui.update_charge(charge / max_charge)
		
		if charge >= max_charge and not fully_charged:
			fully_charged = true
			$ChargeSound.stop()
			if stop_particles_on_full:
				for p in _get_particles():
					p.emitting = false
		
		if not fully_charged:
			if not $ChargeSound.playing:
				$ChargeSound.play()
			for p in _get_particles():
				p.emitting = true
	else:
		if $ChargeSound.playing:
			$ChargeSound.stop()
		for p in _get_particles():
			p.emitting = false

func _on_hand_grab_pulled(hand: bool) -> void:
	if hand and Grabpack.right_hand.current_hand_node.name == "PressureHand":
		is_charging = true
		fully_charged = false
		# Stop the box from being pulled while charging
		if draggable:
			draggable.set_pulling_blocked(true)

func _on_hand_grab_let_go(hand: bool) -> void:
	if is_charging:
		is_charging = false
		# Re-enable draggable pulling
		if draggable:
			draggable.set_pulling_blocked(false)
		fire()

func fire():
	var power = charge / max_charge
	print("Pressure blast power:", power)

	if draggable:
		draggable.push(power)

	if power >= 1.0:
		power_100.emit()
	elif power >= 0.75:
		power_75.emit()
	elif power >= 0.5:
		power_50.emit()
	elif power >= 0.25:
		power_25.emit()

	charge = 0.0
	fully_charged = false
	pressure_ui.reset_charge()
	for p in _get_particles():
		p.emitting = false
