extends CanvasLayer

#Objective System:
@onready var objective_animation: AnimationPlayer = $ObjectiveAnimation
@onready var obj_msg: Label = $objective/obj_msg
@onready var obj_sound = $objective/obj_sound
#Tutorial:
@onready var tutorial_text = $tutorial/text
@onready var tip_sound = $tutorial/tooltip
@onready var tutorial_animation = $TutorialAnimation
#Tooltip:
@onready var tooltip_animation = $TooltipAnimation
@onready var tooltiplabel = $tooltip/tooltiplabel
#Saving:
@onready var saving_animation = $SavingAnimation
#Inventory
@onready var inventory = $inventory
@onready var open_inv = $inventory/Open
@onready var close_inv = $inventory/Close
@onready var keys = $inventory/Tabs/Keys
@onready var reading: Panel = $inventory/section/Reading

#Basic Interface
@onready var crosshair = $crosshair
@onready var gas_mask: Node2D = $GasMask
@onready var damage: Node2D = $damage
@onready var displayed_fps: Label = $DisplayedFPS

var showFPS: bool = false

func _ready() -> void: GameSettings.connect("setting_changed", setting_changed)
func _input(_event):
	if Input.is_action_just_pressed("inventory"):
		if $Pause.visible and not inventory.visible: return
		
		inventory.visible = !inventory.visible
		Grabpack.player.capture_mouse(!inventory.visible)
		
		get_tree().paused = inventory.visible
		if inventory.visible:
			open_inv.play()
			inventory.load_section("Keys", keys)
		else:
			close_inv.play()
			reading.visible = false
func _physics_process(_delta: float) -> void: if showFPS: displayed_fps.text = str("FPS: ", int(Engine.get_frames_per_second()))
func setting_changed(setting, value):
	if setting == "film_grain": get_node("Grain").visible = value
	elif setting == "vignette": get_node("Vignette").visible = value
	elif setting == "show_fps":
		displayed_fps.visible = value
		showFPS = value

func new_objective(objective: String):
	obj_msg.text = objective
	objective_animation.play("new_goal")
	obj_sound.play()
func tutorial_notify(tutorial: String):
	tutorial_text.text = tutorial
	tutorial_animation.play("tutorial")
	tip_sound.play()
func remove_tutorial():
	if not $tutorial.visible: return
	tutorial_animation.play("remove")
func tooltip(tooltip_text: String):
	tooltiplabel.text = "Oh"
	tooltiplabel.size.x = 22.0
	tooltiplabel.position.x = 12.0
	tooltiplabel.text = tooltip_text
	tooltip_animation.play("tooltip")
	tip_sound.play()
func save():
	saving_animation.play("saving")

func set_crosshair(enabled: bool):
	crosshair.visible = enabled
