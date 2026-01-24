class_name PauseMenu
extends Control

@export var deck_view_scene: PackedScene

@export var main_options_list: VBoxContainer
@export var audio_settings_button: Button
@export var deck_button: Button
@export var close_button: Button
@export var quit_button: Button

@export var audio_settings_menu: GridContainer
@export var audio_settings_sliders: Array[Slider]
@export var action_noise_player: ActionNoisePlayer

var deck_selection_screen: DeckSelectionScreen
var world_map: WorldMap
var tile_grid: TileGrid


func _ready() -> void:
	get_tree().paused = true
	
	audio_settings_button.pressed.connect(open_audio_settings)
	close_button.pressed.connect(close)
	
	for i in len(audio_settings_sliders):
		var audio_settings_slider: Slider = audio_settings_sliders[i]
		audio_settings_slider.value_changed.connect(change_audio_setting.bind(i))
	
	grab_focus.call_deferred()
	
	if deck_selection_screen:
		deck_button.hide()
	else:
		deck_button.show()
		deck_button.pressed.connect(view_deck)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		if audio_settings_menu.visible:
			close_audio_settings()
		else:
			close()


func close() -> void:
	queue_free()
	get_tree().paused = false


func open_audio_settings() -> void:
	main_options_list.hide()
	audio_settings_menu.show()


func close_audio_settings() -> void:
	main_options_list.show()
	audio_settings_menu.hide()


func change_audio_setting(new_value: float, setting: Settings.AudioSetting) -> void:
	Settings.audio_settings[setting] = roundi(new_value)
	
	match setting:
		Settings.AudioSetting.LOSE_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.LOSE)
		Settings.AudioSetting.WIN_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.WIN)
		Settings.AudioSetting.ACTION_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.DAMAGE)
		Settings.AudioSetting.ATTACK_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.DAMAGE)
		Settings.AudioSetting.DESTROY_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.DESTROY)
		Settings.AudioSetting.HEAL_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.HEAL)
		Settings.AudioSetting.MOVE_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.MOVE)
		Settings.AudioSetting.POISON_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.POISON)
		Settings.AudioSetting.PUSH_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.PUSH)
		Settings.AudioSetting.SHIELD_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.DEFEND)
		Settings.AudioSetting.SWAP_VOLUME:
			action_noise_player.play_sound(ActionNoisePlayer.Sound.SWAP)


func view_deck() -> void:
	var deck_view: DeckView = deck_view_scene.instantiate()
	add_child(deck_view)
	
	if world_map:
		deck_view.source = world_map
		deck_view.full_deck = world_map.player_deck
	elif tile_grid:
		deck_view.source = tile_grid
		deck_view.full_deck = tile_grid.world_map.player_deck
	
	deck_view.show_deck()
