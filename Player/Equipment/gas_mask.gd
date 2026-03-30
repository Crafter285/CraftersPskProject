extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fade_rect: ColorRect = $ColorRect

@onready var broken_equip: AnimatedSprite2D = $BrokenEquip
@onready var broken_overlay: Sprite2D = $BrokenOverlay
@onready var normal_overlay: Sprite2D = $NormalOverlay
@onready var breathing: AudioStreamPlayer = $Breathing
@onready var equip_sfx: AudioStreamPlayer = $EquipSfx
@onready var unequip_sfx: AudioStreamPlayer = $UnequipSfx
@onready var timer: Timer = $Timer
@onready var count_label: Label = $Counter/Count
@onready var counter: Node2D = $Counter

enum MaskType {
	Normal,
	Broken
}

var current_mask: MaskType = MaskType.Normal
var equipped: bool = false

var current_o2: int = 60
var in_gas: bool = false

func _ready() -> void:
	counter.visible = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("mask"):
		if animation_player.is_playing(): return
		if not Grabpack.player.gasmask_toggleable: return
		
		if not equipped: equip_mask()
		else: unequip_mask()

func equip_mask():
	if not Grabpack.player.gasmask: return
	equipped = true
	current_mask = Grabpack.player.gasmask_type
	broken_equip.hide()
	broken_overlay.hide()
	normal_overlay.hide()
	equip_sfx.play()
	animation_player.play("EquipFade")
	counter.hide()
	if current_mask == MaskType.Broken:
		broken_equip.play("equip")
		broken_equip.show()
		await broken_equip.animation_finished
		counter.show()
		count_label.text = str(current_o2)
		broken_equip.hide()
		broken_overlay.show()
		timer.start(1.0)
	elif current_mask == MaskType.Normal:
		normal_overlay.show()
	await animation_player.animation_finished
	breathing.play()

func unequip_mask():
	equipped = false
	broken_equip.hide()
	unequip_sfx.play()
	breathing.stop()
	animation_player.play("UnequipFade")
	if current_mask == MaskType.Broken:
		await get_tree().create_timer(0.1).timeout
		broken_overlay.hide()
		counter.hide()
		broken_equip.show()
		broken_equip.play("unequip")
		await broken_equip.animation_finished
		broken_equip.hide()
	elif current_mask == MaskType.Normal:
		await animation_player.animation_finished
		normal_overlay.hide()

func recharge():
	current_o2 = 60
	count_label.text = str(current_o2)

func _on_timer_timeout() -> void:
	if equipped and current_mask == 1:
		if in_gas: current_o2 -= 1
		if current_o2 < 0:
			Grabpack.kill_player()
		count_label.text = str(current_o2)
		timer.start(1.0)
