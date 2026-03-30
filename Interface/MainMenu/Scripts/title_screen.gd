extends Control

@onready var title_intro = $title_intro
@onready var before_intro_screens = $BeforeIntroScreens
@onready var menu = $menu
@onready var menu_popup = $menu_popup
@onready var music = $MenuMusic/Music
@onready var render_bg = $menu/RenderBG
@onready var load_game = $menu/LoadGame
@onready var settings_menu = $menu/SettingsMenu

var ch4blue_hex = "69dbff"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu.visible = false
func screens_finished():
	title_intro.start()
	before_intro_screens.queue_free()
func logo_finished():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	title_intro.queue_free()
	render_bg.play()
	music.play()
	menu.visible = true
	get_node("menu/Buttons/Continue").visible = Game.checkpoint > 0

func _on_continue_pressed():
	#ADD YOUR CONTINUE GAME BUTTON CODE HERE!
	var result = await menu_popup.prompt("Continue", "This will load your latest save.")
	if result:
		Game.load_checkpoint()

func new_game():
	#ADD YOUR NEW GAME BUTTON CODE HERE!
	var result = await menu_popup.prompt("NEW GAME", "This will overwrite any saved progress.")
	if result:
		Game.reset_checkpoint()
		Game.load_scene("res://Interface/Credits/intro_tape.tscn")

func _on_load_pressed():
	load_game.toggle()

func _on_settings_pressed():
	settings_menu.toggle()

func _on_credits_pressed():
	Game._load_no_screen("res://Interface/Credits/credits.tscn")

func quit():
	var result = await menu_popup.prompt("Exit Game", "Are you sure you wanted to exit the game?")
	if result:
		get_tree().quit()
