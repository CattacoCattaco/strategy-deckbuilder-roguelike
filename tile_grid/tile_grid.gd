class_name TileGrid
extends Node2D

@warning_ignore("unused_signal")
signal tile_targeted(pos: Vector2i)

@export var tile_scene: PackedScene
@export var pause_menu_scene: PackedScene

@export var level_builder: LevelBuilder
@export var round_manager: RoundManager
@export var camera: Camera2D
@export var ui: Control
@export var hand: Hand
@export var your_turn_label: Label
@export var focus_card_holder: ColorRect
@export var focus_card: Card
@export var lose_screen: ColorRect
@export var return_button: Button
@export var win_screen: ColorRect
@export var action_noise_player: ActionNoisePlayer

@export var camera_padding := Vector2i(64, 64)

var size := Vector2i(15, 15)

var world_map: WorldMap
var is_mission: bool = false

var tiles: Array[Array] = []

var deck_selection_scene: PackedScene = load(
		"res://deck_selection_screen/deck_selection_screen.tscn")


func _ready() -> void:
	your_turn_label.hide()
	focus_card_holder.hide()
	lose_screen.hide()
	win_screen.hide()

	focus_card_holder.gui_input.connect(_focus_holder_gui_input)
	return_button.pressed.connect(_return_to_deck_selection)
	
	focus_card.hand = hand
	
	BGMusicManager.bass_player.volume_db = 0
	BGMusicManager.energetic_player.volume_db = 5
	BGMusicManager.quick_player.volume_db = -6


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom"):
		get_viewport().set_input_as_handled()
		if scale == Vector2(1, 1):
			camera.position *= 2
			# Set camera scale to reciprocal of self scale so UI doesn't get scaled
			camera.scale = Vector2(0.5, 0.5)
			scale = Vector2(2, 2)
		else:
			camera.position /= 2
			camera.scale = Vector2(1, 1)
			scale = Vector2(1, 1)
	elif event.is_action_pressed("skip_target"):
		get_viewport().set_input_as_handled()
		tile_targeted.emit(Vector2(-1, -1))
	elif event.is_action_pressed("enter_settings"):
		get_viewport().set_input_as_handled()
		
		var pause_menu: PauseMenu = pause_menu_scene.instantiate()
		pause_menu.tile_grid = self
		
		ui.add_child(pause_menu)


func _focus_holder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unfocus_card()
			focus_card_holder.accept_event()


func generate_level() -> void:
	if world_map.levels_beat < 2:
		size = Vector2i(3, 3)
		level_builder.density = LevelBuilder.ObjectDensity.SPARSE
	elif world_map.levels_beat < 3:
		size = Vector2i(5, 5)
		level_builder.density = LevelBuilder.ObjectDensity.MILD
	elif world_map.levels_beat < 5:
		size = Vector2i(5, 5)
		level_builder.density = LevelBuilder.ObjectDensity.SPARSE
	elif world_map.levels_beat < 7:
		size = Vector2i(7, 7)
		level_builder.density = LevelBuilder.ObjectDensity.MILD
	elif world_map.levels_beat < 11:
		size = Vector2i(7, 7)
		level_builder.density = LevelBuilder.ObjectDensity.SPARSE
	elif world_map.levels_beat < 13:
		size = Vector2i(11, 11)
		level_builder.density = LevelBuilder.ObjectDensity.FEATUREFUL
	elif world_map.levels_beat < 17:
		size = Vector2i(11, 11)
		level_builder.density = LevelBuilder.ObjectDensity.MILD
	elif world_map.levels_beat < 19:
		size = Vector2i(13, 13)
		level_builder.density = LevelBuilder.ObjectDensity.DENSE
	elif world_map.levels_beat < 23:
		size = Vector2i(13, 13)
		level_builder.density = LevelBuilder.ObjectDensity.FEATUREFUL
	elif world_map.levels_beat < 29:
		size = Vector2i(13, 13)
		level_builder.density = LevelBuilder.ObjectDensity.MILD
	elif world_map.levels_beat < 31:
		size = Vector2i(17, 17)
		level_builder.density = LevelBuilder.ObjectDensity.DENSE
	elif world_map.levels_beat < 37:
		size = Vector2i(17, 17)
		level_builder.density = LevelBuilder.ObjectDensity.MILD
	else:
		size = Vector2i(17, 17)
		level_builder.density = LevelBuilder.ObjectDensity.SPARSE
	
	var pixel_size: Vector2 = size * 32
	var offset := -pixel_size / 2
	
	for x in range(size.x):
		var column: Array[Tile] = []
		
		for y in range(size.y):
			var tile: Tile = tile_scene.instantiate()
			
			add_child(tile)
			column.append(tile)
			
			tile.pos = Vector2i(x, y)
			tile.position = Vector2(32 * x, 32 * y) + offset
			
			tile.tile_grid = self
		
		tiles.append(column)
	
	level_builder.place_objects()
	hand.draw_hand()
	round_manager.start_rounds()


func load_level() -> void:
	GameSaver.load_level(self)


func focus(card_data: CardData) -> void:
	focus_card_holder.show()
	focus_card.card_data = card_data
	focus_card.load_data()


func unfocus_card() -> void:
	focus_card_holder.hide()


func win() -> void:
	win_screen.show()
	action_noise_player.play_sound(ActionNoisePlayer.Sound.WIN)
	
	round_manager.done = true
	
	world_map.get_tile_from_vec(world_map.player_pos).completed = true
	world_map.levels_beat += 1
	
	GameSaver.delete_level()
	
	await action_noise_player.finished
	
	get_tree().root.add_child(world_map)
	queue_free()
	
	world_map.update_music()


func lose() -> void:
	round_manager.done = true
	
	lose_screen.show()
	action_noise_player.play_sound(ActionNoisePlayer.Sound.LOSE)
	
	GameSaver.delete_world_map()
	GameSaver.delete_level()


func _return_to_deck_selection() -> void:
	var deck_selection_screen: DeckSelectionScreen = deck_selection_scene.instantiate()
	get_tree().root.add_child(deck_selection_screen)
	queue_free()


func get_dist_with_jumps(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func has_tile(x: int, y: int) -> bool:
	return x < size.x and y < size.y and x >= 0 and y >= 0


func get_tile(x: int, y: int) -> Tile:
	return tiles[x][y]


func show_your_turn() -> void:
	your_turn_label.show()
	await get_tree().create_timer(0.4).timeout
	your_turn_label.hide()


func get_camera_bounds() -> Rect2:
	var bottom_right: Vector2 = size * 16
	var top_left: Vector2 = -bottom_right
	
	var bounds := Rect2()
	bounds.position = top_left * scale - Vector2(camera_padding)
	bounds.size = Vector2(size * 32 * Vector2i(scale) + camera_padding * 2)
	
	return bounds
