extends StaticBody3D

@export var missing_lever: bool = false
@export var disabled: bool = false
@export var pullable_once: bool = false

@onready var animation_player = $AnimationPlayer
@onready var pull_sound = $PullSound
@onready var hand_grab = $Hinge/HandGrab
@onready var hinge = $Hinge
@onready var interaction_indicator = $BasicInteraction/InteractionIndicator
@onready var basic_interaction = $BasicInteraction

signal pulled_up
signal pulled_down
signal pull_failed

var facing: bool = false
var pulled_once: bool = false

func _ready():
	if missing_lever:
		hand_grab.enabled = false
		hinge.visible = false
		interaction_indicator.enabled = true

func set_has_lever(value: bool):
	hand_grab.enabled = value
	hinge.visible = value
	missing_lever = !value
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
		pulled_up.emit()
	else:
		animation_player.play("pull")
		pulled_down.emit()
	pull_sound.play()
	if pullable_once:
		pulled_once = true

func _on_hand_grab_let_go(_hand: bool) -> void:
	if animation_player.is_playing():
		if animation_player.current_animation == "pull" or animation_player.current_animation == "pull_down":
			pass

func _on_basic_interaction_player_interacted():
	if has_spare_lever() and missing_lever:
		set_has_lever(true)
		Inventory.remove_item("items_Keys", "Lever")

func direction_changed(new_direction: bool):
	facing = new_direction
