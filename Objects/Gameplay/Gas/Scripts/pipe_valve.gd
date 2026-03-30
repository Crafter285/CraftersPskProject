@tool
extends StaticBody3D

@export var missing_valve: bool = false
@export var emitting_gas: bool = false
@export var pull_amount: float = 1000.0
@export var gas_leak_direction: Vector3 = Vector3(0.0, 0.0, 0.0)
@export var editor_gas_preview: bool = false
@export var use_fog: bool = true
@export var fog_node: FogVolume
@export var fog_density: float = 1.0
@export var use_gas_zone: bool = true
@export var gas_zone: GasZone

var fog_material: FogMaterial

@onready var valve = $Valve
@onready var gas_particles = $GasParticles
@onready var gas_material: ParticleProcessMaterial = gas_particles.process_material
@onready var started = $Started
@onready var stopped = $Stopped
@onready var loop = $Loop
@onready var turning = $Turning
@onready var hand_grab = $Valve/HandGrab

var pull_speed: float = 130.0
var pulling: bool = false
var pulled_amount: float = 0.0

signal started_emitting
signal stopped_emitting

func _ready():
	if Engine.is_editor_hint():
		return
	gas_material.gravity = gas_leak_direction
	gas_particles.emitting = false
	if use_fog:
		fog_material = fog_node.material
	if use_gas_zone:
		gas_zone.enabled = false
	if emitting_gas:
		start_gas_leak()
	if missing_valve:
		set_valve(false)

func _process(delta):
	if Engine.is_editor_hint():
		if editor_gas_preview:
			gas_material.gravity = gas_leak_direction
			gas_particles.emitting = true
		else:
			gas_particles.emitting = false
		return
	if use_fog:
		if emitting_gas:
			if fog_material.density < fog_density:
				fog_material.density += 0.25 * delta
		else:
			if fog_material.density > 0.0:
				fog_material.density -= 0.25 * delta
	if pulling and emitting_gas:
		pulled_amount += pull_speed * delta
		valve.rotation_degrees.z += pull_speed * delta
		if pulled_amount > pull_amount:
			stop_gas_leak()

func stop_gas_leak():
	emitting_gas = false
	pulling = false
	gas_particles.emitting = false
	stopped.play()
	loop.stop()
	if use_gas_zone:
		gas_zone.enabled = false
	stopped_emitting.emit()

func start_gas_leak():
	emitting_gas = true
	gas_particles.emitting = true
	
	started_emitting.emit()
	started.play()
	loop.play()
	
	if use_gas_zone:
		gas_zone.enabled = true

func set_valve(has_valve: bool):
	valve.visible = has_valve
	hand_grab.enabled = has_valve
	missing_valve = !has_valve

func _on_hand_grab_pulled(_hand):
	pulling = true
	turning.play()
func _on_hand_grab_let_go(_hand):
	pulling = false
	turning.stop()

func _on_valve_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("Valve"):
		var body = area.get_parent()
		set_valve(true)
		body.holdable_item.stop_hold(body.holdable_item.hold_hand)
		body.queue_free()
