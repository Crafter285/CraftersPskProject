extends Control

@export var menu_popup_path: NodePath

@onready var vbox = $buttons/ScrollContainer/VBoxContainer
@onready var current = $buttons/Current
@onready var defualt = $buttons/defualt
var menu_popup: Control = null
@onready var none = $None

const LOADGAMEBUTTON = preload("res://Interface/Loading/LoadGameMenu/loadgamebutton.tscn")

func _ready():
	unload_menu()
	menu_popup = get_node(menu_popup_path)

func load_menu():
	$AnimationPlayer.play("loaded")
	visible = true
	current.visible = false
	if not Game.saves.size() > 0:
		none.visible = true
		return
	else:
		none.visible = false
	for i in Game.saves.size():
		var new_button = LOADGAMEBUTTON.instantiate()
		new_button.name = str("Load", i)
		vbox.add_child(new_button)
		new_button.load_data(Game.saves[i])
 
func toggle():
	if visible:
		unload_menu()
	else:
		load_menu()

func unload_menu():
	visible = false
	if vbox.get_child_count() > 0:
		for i in vbox.get_child_count()-1:
			var path: String = str("Load", i)
			vbox.get_node(path).queue_free()

func confirm_load(load_number):
	var result = await menu_popup.prompt("Load Game", "This will load the game from the selected checkpoint.")
	if result:
		Game.checkpoint = load_number
		Game.load_checkpoint()
