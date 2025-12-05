class_name TileGrid
extends Node2D

@warning_ignore("unused_signal")
signal tile_targeted(pos: Vector2i)

@export var tile_scene: PackedScene
@export var deck_view_scene: PackedScene

@export var level_builder: LevelBuilder
@export var round_manager: RoundManager
@export var camera: Camera2D
@export var hand: Hand
@export var your_turn_label: Label
@export var focus_card_holder: ColorRect
@export var focus_card: Card
@export var lose_screen: ColorRect

@export var camera_padding := Vector2i(64, 64)

@export var size := Vector2i(15, 15)

var world_map: WorldMap
var is_mission: bool = false

var tiles: Array[Array] = []


func _ready() -> void:
	your_turn_label.hide()
	focus_card_holder.hide()
	lose_screen.hide()

	focus_card_holder.gui_input.connect(_focus_holder_gui_input)
	
	focus_card.hand = hand
	
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
	else:
		size = Vector2i(17, 17)
		level_builder.density = LevelBuilder.ObjectDensity.MILD
	
	var pixel_size: Vector2 = size * 32
	var offset := -Vector2(pixel_size) / 2
	
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
	round_manager.start_rounds()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("zoom"):
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
			tile_targeted.emit(Vector2(-1, -1))
		elif event.is_action_pressed("view_deck"):
			var deck_view: DeckView = deck_view_scene.instantiate()
			add_child(deck_view)
			deck_view.set_anchors_preset(Control.PRESET_CENTER)
			deck_view.world_map = world_map
			deck_view.show_deck()


func _focus_holder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unfocus_card()


func focus(card_data: CardData) -> void:
	focus_card_holder.show()
	focus_card.card_data = card_data
	focus_card.load_data()


func unfocus_card() -> void:
	focus_card_holder.hide()


func win() -> void:
	world_map.levels_beat += 1
	get_tree().root.add_child(world_map)
	queue_free()


func lose() -> void:
	lose_screen.show()


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
