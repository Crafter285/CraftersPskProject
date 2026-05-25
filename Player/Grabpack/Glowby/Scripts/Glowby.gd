extends Node3D

@onready var face_sprite = $SubViewportContainer/SubViewport/AnimatedSprite2D
@onready var flashlight_sound = $Flashlight
@onready var blacklight_sound = $BlackLight
@onready var light_off_sound = $lightoff
@onready var Notifacation_sound = $Notifacation

var flashlight_var = false
var blacklight_var = false
var disable_controls = true

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		if player.glowby_notifaction == true:
			player.glowby_notifaction = false
			notifaction()
			disable_controls = true
		
		if player.start_with_glowby == true:
			startup(player)

func startup(player):
	if player.glowby_check == true:
		player.glowby_check = false
		if player.glowby_collected == true:
			collected()
		elif player.glowby_collected == false:
			idle()
			disable_controls = false

func idle():
	face_sprite.play("Idle")

func collected():
	face_sprite.play("Collected")
	await face_sprite.animation_finished
	disable_controls = false
	face_sprite.play("Idle")

func flashlight():
	face_sprite.play("Flashlight")

func blacklight():
	face_sprite.play("Blacklight")

func notifaction():
	Notifacation_sound.play()
	face_sprite.play("Notifaction")
	await face_sprite.animation_finished
	disable_controls = false
	if flashlight_var == true:
		flashlight()
	elif blacklight_var == true:
		blacklight()
	elif blacklight_var == false and flashlight_var == false:
		idle()

func _input(_event):
	if disable_controls == false:
		var player = get_tree().get_first_node_in_group("Player")
		if Input.is_action_just_pressed("glowby_flashlight"):
			if flashlight_var == false:
				flashlight_var = true
				blacklight_var = false
				flashlight()
				flashlight_sound.play()
				player.glowby_flashlight_player.show()
				player.glowby_blacklight_player.hide()
			elif flashlight_var == true:
				flashlight_var = false
				idle()
				light_off_sound.play()
				player.glowby_blacklight_player.hide()
				player.glowby_flashlight_player.hide()
		elif Input.is_action_just_pressed("glowby_blacklight"):
			if blacklight_var == false:
				blacklight_var = true
				flashlight_var= false
				blacklight()
				blacklight_sound.play()
				player.glowby_blacklight_player.show()
				player.glowby_flashlight_player.hide()
			elif blacklight_var == true:
				blacklight_var = false
				idle()
				light_off_sound.play()
				player.glowby_blacklight_player.hide()
				player.glowby_flashlight_player.hide()
