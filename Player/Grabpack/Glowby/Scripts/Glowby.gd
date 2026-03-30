extends Node3D

@onready var mesh: MeshInstance3D = $SM_Glowby_mo3

var _mat: BaseMaterial3D

const FACES := {
	"eye_full":   { "offset": Vector3(0.673, 0.227, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"eye_mid":    { "offset": Vector3(0.783, 0.227, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"eye_low":    { "offset": Vector3(0.893, 0.227, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"flash_1":    { "offset": Vector3(0.343, 0.227, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"flash_2":    { "offset": Vector3(0.453, 0.227, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"flash_3":    { "offset": Vector3(0.563, 0.227, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"bl_full":    { "offset": Vector3(0.893, 0.337, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"bl_notif_1": { "offset": Vector3(0.343, 0.117, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"bl_notif_2": { "offset": Vector3(0.453, 0.117, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
	"bl_notif_3": { "offset": Vector3(0.563, 0.117, 0.0), "scale": Vector3(0.1, 0.1, 0.1) },
}

const BLINK_ANIM    := ["eye_full", "eye_mid", "eye_low", "eye_mid", "eye_full"]
const FLASH_ANIM    := ["flash_1", "flash_2", "flash_3"]
const BL_NOTIF_ANIM := ["bl_notif_1", "bl_notif_2", "bl_notif_3", "bl_notif_2", "bl_notif_3"]

const BLINK_INTERVAL_MIN := 9.0
const BLINK_INTERVAL_MAX := 11.0
const BLINK_FRAME_SPEED  := 0.07

var _flash_active: bool = false
var _bl_active: bool = false

var _anim_timer: float = 0.0
var _anim_frame: int = 0
var _anim_speed: float = 0.15
var _current_anim: Array = []
var _is_animating: bool = false

var _blink_timer: float = 0.0
var _blink_interval: float = 0.0
var _is_blinking: bool = false

# ✅ FIX
var _notif_playing: bool = false

func _ready() -> void:
	_mat = mesh.get_active_material(1).duplicate()
	mesh.set_surface_override_material(1, _mat)
	_apply_uv(FACES["eye_full"])
	_reset_blink_timer()

func _process(delta: float) -> void:
	# --- Animation ---
	if _is_animating:
		_anim_timer += delta
		if _anim_timer >= _anim_speed:
			_anim_timer = 0.0
			_anim_frame += 1
			if _anim_frame >= _current_anim.size():
				_is_animating = false
				return
			_apply_uv(FACES[_current_anim[_anim_frame]])
		return

	# --- Blink ---
	if _is_blinking:
		_anim_timer += delta
		if _anim_timer >= BLINK_FRAME_SPEED:
			_anim_timer = 0.0
			_anim_frame += 1
			if _anim_frame >= BLINK_ANIM.size():
				_is_blinking = false
				_apply_uv(FACES["eye_full"])
				_reset_blink_timer()
				return
			_apply_uv(FACES[BLINK_ANIM[_anim_frame]])
		return

	_blink_timer += delta
	if _blink_timer >= _blink_interval:
		_start_blink()

	# ✅ FIXED notification trigger
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.glowby_notifaction and not _notif_playing:
		_play_blacklight_notification(player)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F: _on_f_pressed()
			KEY_V: _on_v_pressed()

# --- Mode control ---
func _set_mode(flash: bool, bl: bool) -> void:
	_flash_active = flash
	_bl_active = bl

	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		return

	player.glowby_flashlight = false
	player.glowby_blacklight = false

	if flash:
		player.glowby_flashlight = true
		_apply_uv(FACES["flash_3"])
	elif bl:
		player.glowby_blacklight = true
		_apply_uv(FACES["bl_full"])
	else:
		_return_to_idle()

func _on_f_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player or not player.can_use_flashlight:
		return

	if _flash_active:
		_set_mode(false, false)
		if player:
			if player.glowby_flashlight_check == true:
				$lightoff.play()
	else:
		_set_mode(true, false)
		_is_blinking = false
		if player:
			if player.glowby_flashlight_check == true:
				$Flashlight.play()
		_play_anim(FLASH_ANIM, 0.15)

func _on_v_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player or not player.can_use_blacklight:
		return

	if _bl_active:
		_set_mode(false, false)
		if player:
			if player.glowby_blacklight_check == true:
				$lightoff.play()
	else:
		_set_mode(false, true)
		_is_animating = false
		_is_blinking = false
		if player:
			if player.glowby_blacklight_check == true:
				$BlackLight.play()

# --- FIXED Notification ---
func _play_blacklight_notification(player: Node3D) -> void:
	if not player or _notif_playing:
		return

	_notif_playing = true

	var prev_flash = _flash_active
	var prev_bl    = _bl_active

	_flash_active = false
	_bl_active = false
	_is_animating = false
	_is_blinking = false

	_play_anim(BL_NOTIF_ANIM, 0.15)
	$Notifacation.play()
	player.glowby_notifaction = false

	_finish_notification(prev_flash, prev_bl)

func _finish_notification(prev_flash: bool, prev_bl: bool) -> void:
	var duration = BL_NOTIF_ANIM.size() * 0.15
	await get_tree().create_timer(duration).timeout

	_set_mode(prev_flash, prev_bl)

	_notif_playing = false

# --- Helpers ---
func _start_blink() -> void:
	_is_blinking = true
	_anim_frame = 0
	_anim_timer = 0.0
	_apply_uv(FACES[BLINK_ANIM[0]])

func _reset_blink_timer() -> void:
	_blink_timer = 0.0
	_blink_interval = randf_range(BLINK_INTERVAL_MIN, BLINK_INTERVAL_MAX)

func _play_anim(frames: Array, speed: float = 0.15) -> void:
	_is_blinking = false
	_current_anim = frames
	_anim_speed = speed
	_anim_frame = 0
	_anim_timer = 0.0
	_is_animating = true
	_apply_uv(FACES[_current_anim[0]])

func _return_to_idle() -> void:
	_is_animating = false
	_is_blinking = false
	_anim_timer = 0.0
	_anim_frame = 0
	_apply_uv(FACES["eye_full"])
	_reset_blink_timer()

func _apply_uv(face: Dictionary) -> void:
	_mat.uv1_offset = face["offset"]
	_mat.uv1_scale  = face["scale"]

func _input(_event):
	if Input.is_action_just_pressed("glowby_flashlight"):
		_on_f_pressed()

	if Input.is_action_just_pressed("glowby_blacklight"):
		_on_v_pressed()
