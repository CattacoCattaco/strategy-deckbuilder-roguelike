class_name MainMenu
extends Control

@export var pause_menu_scene: PackedScene
@export var deck_selection_scene: PackedScene

@export var play_button: TextureButton
@export var options_button: TextureButton
@export var quit_button: TextureButton


func _ready() -> void:
	play_button.pressed.connect(play)
	options_button.pressed.connect(open_options)
	quit_button.pressed.connect(quit)
	
	BGMusicManager.bass_player.volume_db = 2
	BGMusicManager.energetic_player.volume_db = 0
	BGMusicManager.quick_player.volume_db = -100


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("enter_settings"):
		open_options()


func play() -> void:
	var deck_selection: DeckSelectionScreen = deck_selection_scene.instantiate()
	get_tree().root.add_child(deck_selection)
	queue_free()


func open_options() -> void:
	get_viewport().set_input_as_handled()
	
	var pause_menu: PauseMenu = pause_menu_scene.instantiate()
	pause_menu.main_menu = self
	
	get_tree().root.add_child(pause_menu)


func quit() -> void:
	get_tree().quit()
