@tool
extends Node3D

@export var door_type: PackedScene = preload("res://Objects/Gameplay/Gates/DoorTypes/door_grey.tscn")
@export var locked: bool = false
@export var unlockable_with_key: bool = false
@export var key_name: String = ""

@onready var animation_player = $AnimationPlayer
@onready var hand_grab = $door/HandGrab
@onready var timer = $Timer
@onready var hand_grab_2 = $door/HandGrab2

@onready var lockedsound = $locked_01
@onready var opensound = $open
@onready var closesound = $close

var open: bool = false

signal open_finished
signal close_finished
signal locked_attempt

var frame_mesh: Node
var door_mesh: Node
var door_type_node: Node
var prev_door_scene: String

func _ready() -> void:
	if not door_type: return
	if not frame_mesh:
		load_door()
func load_door():
	if door_type_node: door_type_node.queue_free()
	if frame_mesh: frame_mesh.queue_free()
	if door_mesh: door_mesh.queue_free()
	door_type_node = door_type.instantiate()
	add_child(door_type_node)
	
	door_type_node.frame.reparent(self)
	door_type_node.door.reparent($door)
	
	door_mesh = door_type_node.door
	frame_mesh = door_type_node.frame
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		if prev_door_scene != door_type.resource_path:
			load_door()
		prev_door_scene = door_type.resource_path

func toggle():
	if locked:
		if unlockable_with_key and Inventory.scan_list("items_Keys", key_name):
			locked = false
			Inventory.remove_item("items_Keys", key_name)
		else:
			animation_player.play("locked")
			lockedsound.play()
			emit_signal("locked_attempt")
			return
	if open:
		animation_player.play("close")
		closesound.play()
	else:
		animation_player.play("open")
		opensound.play()
	open = !open

func opendoor():
	if locked:
		animation_player.play("locked")
		lockedsound.play()
		emit_signal("locked_attempt")
		return
	if not open:
		animation_player.play("open")
		opensound.play()
		open = true

func closedoor():
	if locked:
		animation_player.play("locked")
		lockedsound.play()
		emit_signal("locked_attempt")
		return
	if open:
		animation_player.play("close")
		closesound.play()
		open = false

func _on_hand_grab_grabbed(_hand):
	toggle()
	timer.start()

func _on_timer_timeout():
	hand_grab.release_grabbed()
	hand_grab_2.release_grabbed()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "open":
		emit_signal("open_finished")
	elif anim_name == "close":
		emit_signal("close_finished")
