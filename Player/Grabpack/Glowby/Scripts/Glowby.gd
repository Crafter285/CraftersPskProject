extends Node3D

@onready var face_sprite = $SubViewportContainer/SubViewport/AnimatedSprite2D
@onready var flashlight_sound = $Flashlight
@onready var blacklight_sound = $BlackLight
@onready var light_off_sound = $lightoff
@onready var Notifacation_sound = $Notifacation

enum Face {
	DEFAULT,
	CURIOUS_CONCERNED,
	SCARED,
	SHOCK_FRIGHTENED,
	DEAD_VERY_SCARED,
	EYES_CLOSED,
	LOADING,
	SUPER_HAPPY,
	VERY_VERY_HAPPY,
	VERY_WORRIED,
}

# Player flag -> face. Order = priority (later entries win if several are set in one frame).
const FLAG_TO_FACE := {
	"glowby_back_to_default": Face.DEFAULT,
	"glowby_Curous_Concerned": Face.CURIOUS_CONCERNED,
	"glowby_Scared": Face.SCARED,
	"glowby_Shock_Frightend": Face.SHOCK_FRIGHTENED,
	"glowby_dead_very_scared": Face.DEAD_VERY_SCARED,
	"glowby_eyes_closed": Face.EYES_CLOSED,
	"glowby_laoding": Face.LOADING,
	"glowby_super_happy": Face.SUPER_HAPPY,
	"glowby_very_very_happy": Face.VERY_VERY_HAPPY,
	"glowby_very_worried": Face.VERY_WORRIED,
}

# Animation names per face. Each entry lists candidates; the first one that exists in
# your SpriteFrames is used, so spelling differences no longer fail silently.
const FACE_ANIMS := {
	Face.DEFAULT: ["Idle"],
	Face.CURIOUS_CONCERNED: ["Curous_Concerned"],
	Face.SCARED: ["Scared"],
	Face.SHOCK_FRIGHTENED: ["Shock_Frightendd", "Shock_Frightend"],
	Face.DEAD_VERY_SCARED: ["dead_very-scared", "dead_very_scared"],
	Face.EYES_CLOSED: ["eyes_closed"],
	Face.LOADING: ["laoding", "loading"],
	Face.SUPER_HAPPY: ["super_happy"],
	Face.VERY_VERY_HAPPY: ["very_very_happy"],
	Face.VERY_WORRIED: ["very_worried"],
}

# Faces that must not be overridden by the flashlight / blacklight animations.
const NO_ANIM_FACES := [Face.SCARED, Face.DEAD_VERY_SCARED, Face.EYES_CLOSED, Face.LOADING]

var current_face: Face = Face.DEFAULT

var flashlight_var: bool = false
var blacklight_var: bool = false
var disable_controls: bool = true

var _player: Node = null
var _busy: bool = false      # true while "Collected" / "Notifaction" is playing
var _busy_token: int = 0     # invalidates stale awaits when the state is reset


func _ready() -> void:
	# These must not loop, otherwise `await animation_finished` never returns
	# and the controls stay locked forever.
	var frames = face_sprite.sprite_frames
	if frames:
		for anim in ["Collected", "Notifaction"]:
			if frames.has_animation(anim):
				frames.set_animation_loop(anim, false)


func _get_player() -> Node:
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("Player")
	return _player


func _process(_delta: float) -> void:
	var player = _get_player()
	if player == null:
		return

	if player.glowby_notifaction == true:
		player.glowby_notifaction = false
		disable_controls = true
		notifaction()

	if player.glowby_disable_controls == true:
		player.glowby_disable_controls = false
		disable_controls = true

	if player.glowby_enable_controls == true:
		player.glowby_enable_controls = false
		disable_controls = false

	if player.start_with_glowby == true:
		startup(player)

	if player.glowby_lose == true:
		lose_glowby(player)

	for flag in FLAG_TO_FACE:
		if player.get(flag) == true:
			player.set(flag, false)
			set_face(FLAG_TO_FACE[flag])


# ---------------------------------------------------------------- state / faces

func set_face(face: Face) -> void:
	current_face = face
	if not _busy:
		_play_face()


func back_to_default() -> void:
	set_face(Face.DEFAULT)


## Shows whatever Glowby should currently be showing (held face or light animation).
func idle() -> void:
	if _busy:
		return
	if current_face not in NO_ANIM_FACES:
		if flashlight_var:
			_play_first(["Flashlight"])
			return
		if blacklight_var:
			_play_first(["Blacklight"])
			return
	_play_face()


func _play_face() -> void:
	if not _play_first(FACE_ANIMS[current_face]) and current_face != Face.DEFAULT:
		_play_first(FACE_ANIMS[Face.DEFAULT])


func _play_first(names: Array) -> bool:
	var frames = face_sprite.sprite_frames
	if frames:
		for n in names:
			if frames.has_animation(n):
				face_sprite.play(n)
				return true
	push_warning("Glowby: no matching animation in %s" % str(names))
	return false


func flashlight() -> void:
	if current_face not in NO_ANIM_FACES:
		_play_first(["Flashlight"])


func blacklight() -> void:
	if current_face not in NO_ANIM_FACES:
		_play_first(["Blacklight"])


# ---------------------------------------------------------------- startup / lose

func startup(player) -> void:
	if player.glowby_check == true:
		player.glowby_check = false
		if player.glowby_collected == true:
			collected()
		else:
			disable_controls = false
			idle()


func collected() -> void:
	_busy = true
	_busy_token += 1
	var token := _busy_token
	if not _play_first(["Collected"]):
		# Animation missing: don't wait for a signal that will never fire.
		_busy = false
		disable_controls = false
		idle()
		return
	await face_sprite.animation_finished
	if token != _busy_token:
		return # state was reset (e.g. Glowby lost) while we were waiting
	_busy = false
	disable_controls = false
	idle()


func notifaction() -> void:
	Notifacation_sound.play()
	_busy = true
	_busy_token += 1
	var token := _busy_token
	if not _play_first(["Notifaction"]):
		_busy = false
		disable_controls = false
		idle()
		return
	await face_sprite.animation_finished
	if token != _busy_token:
		return
	_busy = false
	disable_controls = false
	idle() # handles flashlight / blacklight / held face


func lose_glowby(player) -> void:
	player.glowby_lose = false
	player.glowby_collected = false
	player.glowby_check = true
	player.glowby_back_to_default = false

	# Cancel any running notification / collected sequence.
	_busy = false
	_busy_token += 1

	# Turn the lights off, since the player no longer has Glowby.
	flashlight_var = false
	blacklight_var = false
	if player.glowby_flashlight_player:
		player.glowby_flashlight_player.hide()
	if player.glowby_blacklight_player:
		player.glowby_blacklight_player.hide()

	disable_controls = true
	back_to_default()


# ---------------------------------------------------------------- input

func _input(event: InputEvent) -> void:
	if disable_controls:
		return
	if event.is_action_pressed("glowby_flashlight"):
		_toggle_flashlight()
	elif event.is_action_pressed("glowby_blacklight"):
		_toggle_blacklight()


func _toggle_flashlight() -> void:
	var player = _get_player()
	if player == null:
		return
	if not flashlight_var:
		flashlight_var = true
		blacklight_var = false
		flashlight()
		flashlight_sound.play()
		player.glowby_flashlight_player.show()
		player.glowby_blacklight_player.hide()
	else:
		flashlight_var = false
		idle()
		light_off_sound.play()
		player.glowby_flashlight_player.hide()
		player.glowby_blacklight_player.hide()


func _toggle_blacklight() -> void:
	var player = _get_player()
	if player == null:
		return
	if not blacklight_var:
		blacklight_var = true
		flashlight_var = false
		blacklight()
		blacklight_sound.play()
		player.glowby_blacklight_player.show()
		player.glowby_flashlight_player.hide()
	else:
		blacklight_var = false
		idle()
		light_off_sound.play()
		player.glowby_flashlight_player.hide()
		player.glowby_blacklight_player.hide()
