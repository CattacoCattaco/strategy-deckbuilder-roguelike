class_name TileGrid
extends Node2D

@export var tile_scene: PackedScene
@export var level_builder: LevelBuilder
@export var round_manager: RoundManager
@export var camera: Camera2D

@export var camera_padding := Vector2i(64, 64)

@export var size := Vector2i(15, 15)

var tiles: Array[Array] = []


func _ready() -> void:
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


func has_tile(x: int, y: int) -> bool:
	return x < size.x and y < size.y and x > 0 and y > 0


func get_tile(x: int, y: int) -> Tile:
	return tiles[x][y]


func get_camera_bounds() -> Rect2:
	var bottom_right: Vector2 = size * 16
	var top_left: Vector2 = -bottom_right
	
	var bounds := Rect2()
	bounds.position = top_left * scale - Vector2(camera_padding)
	bounds.size = Vector2(size * 32 * Vector2i(scale) + camera_padding * 2)
	
	return bounds
