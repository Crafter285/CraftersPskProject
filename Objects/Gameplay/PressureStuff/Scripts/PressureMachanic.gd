extends Node3D
@export var max_charge: float = 3.0
@export var stop_particles_on_full: bool = false
@export var enabled: bool = true
var charge: float = 0.0
var is_charging: bool = false
var fully_charged: bool = false
var is_enabled: bool = true
signal power_25
signal power_50
signal power_75
signal power_100
@onready var pressure_ui = get_tree().get_root().find_child("pressure", true, false)
@onready var hand_grab: Area3D = $HandGrab

var _cached_particles: Array = []
var _cached_hand_node = null

func _ready() -> void:
	is_enabled = enabled
	hand_grab.enabled = false
	var audio = AudioStreamPlayer3D.new()
	audio.name = "ChargeSound"
	var stream = load("res://Objects/Gameplay/PressureStuff/SFX/SW_SFX_Grabpack_PressureHand_Build.wav")
	audio.stream = stream
	audio.autoplay = false
	add_child(audio)
	# Pre-buffer the sound so first play has no hitch
	audio.play()
	audio.stop()

func _get_particles() -> Array:
	var hand = Grabpack.right_hand.current_hand_node
	if hand != _cached_hand_node:
		_cached_hand_node = hand
		if hand and hand.name == "PressureHand":
			_cached_particles = [hand.get_node("GPUParticles3D"), hand.get_node("GPUParticles3D2")]
		else:
			_cached_particles = []
	return _cached_particles

func _process(delta: float) -> void:
	var should_enable = Grabpack.right_hand.current_hand_node.name == "PressureHand"
	if hand_grab.enabled != should_enable:
		hand_grab.enabled = should_enable

	if is_charging:
		charge += delta
		charge = clamp(charge, 0.0, max_charge)
		$Label3D.text = "%.2f" % charge
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
	if is_enabled == true:
		if hand and Grabpack.right_hand.current_hand_node.name == "PressureHand":
			is_charging = true
			fully_charged = false

func _on_hand_grab_let_go(hand: bool) -> void:
	if is_charging:
		is_charging = false
		fire()

func fire():
	var power = charge / max_charge
	print("Pressure blast power:", power)

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
	$Label3D.text = "0.00"
	pressure_ui.reset_charge()
	for p in _get_particles():
		p.emitting = false
	_cached_hand_node = null
	_cached_particles = []

func enable():
	is_enabled = true

func disable():
	is_enabled = false
