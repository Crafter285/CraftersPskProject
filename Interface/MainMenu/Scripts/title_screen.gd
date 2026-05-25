extends Control

enum interfacetype {
	Ch5,
	Ch4
}

@export var interface_type: interfacetype = interfacetype.Ch4

#ch5
@onready var ch5_title_intro = $PP5/title_intro
@onready var ch5_before_intro_screens = $PP5/BeforeIntroScreens
@onready var ch5_menu = $PP5/menu
@onready var ch5_menu_popup = $PP5/menu_popup
@onready var ch5_music = $PP5/MenuMusic/Music
@onready var ch5_music2 = $PP5/title_intro/Music2
@onready var ch5_render_bg = $PP5/menu/RenderBG
@onready var ch5_render_bg_any = $PP5/title_intro/RenderBG
@onready var ch5_load_game = $PP5/menu/LoadGame
@onready var ch5_settings_menu = $PP5/menu/SettingsMenu

#ch4
@onready var title_intro = $title_intro
@onready var before_intro_screens = $BeforeIntroScreens
@onready var menu = $menu
@onready var menu_popup = $menu_popup
@onready var music = $MenuMusic/Music
@onready var render_bg = $menu/RenderBG
@onready var load_game = $menu/LoadGame
@onready var settings_menu = $menu/SettingsMenu

var ch4blue_hex = "69dbff"
var ch5red_hex = "d72924"

func _ready():
	match interface_type:
		interfacetype.Ch4:
			ch4()
			menu.visible = false
			Game.interface = "Ch4"
		interfacetype.Ch5:
			ch5()
			ch5_menu.visible = false
			Game.interface = "Ch5"
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
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

func ch5():
	$PP5.show()
	$BG.queue_free()
	$BeforeIntroScreens.queue_free()
	$title_intro.queue_free()
	$menu.queue_free()
	$menu_popup.queue_free()
	$MenuMusic.queue_free()
	$MenuTransition.queue_free()

func ch4():
	$PP5.queue_free()

#Ch5

func ch5_screens_finished():
	ch5_title_intro.start()
	ch5_before_intro_screens.queue_free()

func ch5_logo_finished():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ch5_title_intro.queue_free()
	ch5_render_bg.play()
	ch5_music.play()
	ch5_menu.visible = true
	get_node("PP5/menu/Buttons/Continue").visible = Game.checkpoint > 0

func ch5_on_continue_pressed():
	#ADD YOUR CONTINUE GAME BUTTON CODE HERE!
	var result = await ch5_menu_popup.prompt("Continue", "This will load your latest save.")
	if result:
		Game.load_checkpoint()

func ch5_new_game():
	#ADD YOUR NEW GAME BUTTON CODE HERE!
	var result = await ch5_menu_popup.prompt("NEW GAME", "This will overwrite any saved progress.")
	if result:
		Game.reset_checkpoint()
		Game.load_scene("res://Interface/Credits/intro_tape.tscn")

func ch5_on_load_pressed():
	ch5_load_game.toggle()

func ch5_on_settings_pressed():
	ch5_settings_menu.toggle()

func ch5_on_credits_pressed():
	Game._load_no_screen("res://Interface/Credits/credits.tscn")

func ch5_quit():
	var result = await ch5_menu_popup.prompt("Exit Game", "Are you sure you wanted to exit the game?")
	if result:
		get_tree().quit()
