@tool
extends Node3D

@onready var anim = $AnimationPlayer
@onready var opening = $opening
@onready var close = $close
@onready var gate = $gate

@export_category("Settings")
##Cosmetic of the gate.
@export var gate_type: PackedScene = preload("res://Objects/Gameplay/Gates/GateTypes/gate_rail.tscn")
##If enabled, the gate starts open.
@export var open_by_defualt = false

var prev_colour = null
var open = false

signal opened
signal closed
var frame_mesh: Node
var gate_mesh: Node
var gate_type_node: Node
var prev_gate_scene: String

func _ready() -> void:
	if open_by_defualt:
		open = true
		gate.position.y = 2.612
	if not gate_type: return
	if not frame_mesh:
		load_door()
func load_door():
	if gate_type_node: gate_type_node.queue_free()
	if frame_mesh: frame_mesh.queue_free()
	if gate_mesh: gate_mesh.queue_free()
	gate_type_node = gate_type.instantiate()
	add_child(gate_type_node)
	
	gate_type_node.frame.reparent(self)
	gate_type_node.gate.reparent($gate)
	opening.stream = gate_type_node.open_sound
	close.stream = gate_type_node.close_sound
	
	gate_mesh = gate_type_node.gate
	frame_mesh = gate_type_node.frame
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if prev_gate_scene != gate_type.resource_path:
			load_door()
		prev_gate_scene = gate_type.resource_path

func opengate():
	opening.play()
	anim.play("open")
	open = true

func closegate():
	close.play()
	anim.play("close")
	open = false
func fastclose():
	anim.play("fast_close")
	open = false

func toggle():
	if open:
		closegate()
	else:
		opengate()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "open":
		emit_signal("opened")
	if anim_name == "close":
		emit_signal("closed")
