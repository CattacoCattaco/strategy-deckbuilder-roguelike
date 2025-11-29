class_name TileGrid
extends Node2D

@warning_ignore("unused_signal")
signal tile_targeted(pos: Vector2i)

@export var tile_scene: PackedScene
@export var level_builder: LevelBuilder
@export var round_manager: RoundManager
@export var camera: Camera2D
@export var hand: Hand
@export var your_turn_label: Label
@export var lose_screen: ColorRect

@export var camera_padding := Vector2i(64, 64)

@export var size := Vector2i(15, 15)

var world_map: WorldMap

var tiles: Array[Array] = []


func _ready() -> void:
	your_turn_label.hide()
	lose_screen.hide()
	
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


func win() -> void:
	world_map.levels_beat += 1
	get_tree().root.add_child(world_map)
	queue_free()


func lose() -> void:
	lose_screen.show()


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
