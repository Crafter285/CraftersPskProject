extends Area3D

@export var One_Time_Use: bool = true
@export_group("Lose Options")
@export var Lose_Grabpack: bool = true
@export var Lose_Glowby: bool = false
@export var Lose_Cuffs: bool = false
@export var Lose_Hand: bool = false
@export var Hand_Name: String = "RedHand"

var one_time: bool = false

signal lost_grabpack
signal lost_glowby
signal lost_cuffs
signal lost_hand

func _ready() -> void:
	body_entered.connect(_on_area_3d_body_entered)

func _on_area_3d_body_entered(body: Node3D):
	if body.is_in_group("Player") or body.name == "Player":
		lose_stuff()

func lose_stuff():
	var player = get_tree().get_first_node_in_group("Player")
	if one_time == false:
		if One_Time_Use == true:
			one_time = true
		if Lose_Grabpack == true:
			Grabpack.switch_grabpack(0)
			lost_grabpack.emit()
		if Lose_Glowby == true:
			player.start_with_glowby = false
			player.glowby_lose = true
			lost_glowby.emit()
		if Lose_Cuffs == true:
			player.start_with_Magnet_cuffs = false
			lost_cuffs.emit()
		if Lose_Hand == true:
			Grabpack.remove_hand(Hand_Name)
			lost_hand.emit()
