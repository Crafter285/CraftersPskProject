extends StaticBody3D

@export var begin_on: bool = false
@export var disabled: bool = false
@export var pullable_once: bool = false

@onready var animation_player = $AnimationPlayer
@onready var pull_sound = $PullSound
@onready var pull_sound2 = $PullSound2
@onready var hand_grab = $Hinge/HandGrab
@onready var hinge = $Hinge
@onready var interaction_indicator = $BasicInteraction/InteractionIndicator
@onready var basic_interaction = $BasicInteraction

signal pulled_on
signal pulled_off
signal pull_failed

var facing: bool = false
var pulled_once: bool = false

func _ready():
	if begin_on == true:
		animation_player.play("faildown")
		facing = true
	elif begin_on == false:
		facing = false
	pass

func set_has_lever(value: bool):
	hand_grab.enabled = value
	hinge.visible = value
	interaction_indicator.visible = false
	interaction_indicator.enabled = !value
	#basic_interaction.enabled = !value

func has_spare_lever():
	return Inventory.scan_list("items_Keys", "Lever")

func _on_hand_grab_pulled(_hand):
	if pulled_once or disabled:
		if facing:
			animation_player.play("faildown")
		else:
			animation_player.play("fail")
		pull_sound.play()
		pull_failed.emit()
		return
	if facing:
		animation_player.play("pull_down")
		pulled_off.emit()
	else:
		animation_player.play("pull")
		pulled_on.emit()
	pull_sound2.play()
	if pullable_once:
		pulled_once = true

func _on_hand_grab_let_go(_hand: bool) -> void:
	if animation_player.is_playing():
		if animation_player.current_animation == "pull" or animation_player.current_animation == "pull_down":
			pass

func direction_changed(new_direction: bool):
	facing = new_direction
