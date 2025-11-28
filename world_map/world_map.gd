class_name WorldMap
extends Node2D

@export var tile_scene: PackedScene
@export var size := Vector2i(15, 15)

var tiles: Array[Array]


func _ready() -> void:
	var pixel_size: Vector2 = size * 32
	var offset := -Vector2(pixel_size) / 2
	
	for x in range(size.x):
		var column: Array[WorldMapTile] = []
		
		for y in range(size.y):
			var tile: WorldMapTile = tile_scene.instantiate()
			
			tile.world_map = self
			
			column.append(tile)
			add_child(tile)
			
			tile.pos = Vector2i(x, y)
			tile.position = Vector2(32 * x, 32 * y) + offset
		
		tiles.append(column)
	
	var pos := Vector2i((size.x - 1) >> 1, size.y - 2)
	var tile: WorldMapTile = get_tile_from_vec(pos)
	tile.set_as_path()
	tile.add_entrance()
	
	var desired_end := Vector2i(pos.x, 1)
	var reached_end: bool = false
	
	# If true, the next event should be a challenge
	# If false, the next event should be a reward
	var is_challenge: bool = true
	
	for i in range(100):
		var valid_dirs: Array[Vector2i] = []
		
		for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
			if not has_tile_at_vec(pos + (dir * 2)):
				continue
			
			var weight: int = 1
			
			if not reached_end:
				var end_direction: Vector2i = desired_end - pos
				
				if end_direction.x > 0 and dir.x > 0:
					weight += 2
				elif end_direction.x < 0 and dir.x < 0:
					weight += 2
				
				if end_direction.y > 0 and dir.y > 0:
					weight += 4
			
			if not get_tile_from_vec(pos + (dir * 2)).has_path:
				weight += 1
			
			for j in range(weight):
				valid_dirs.append(dir)
		
		var dir: Vector2i = valid_dirs.pick_random()
		
		for j in range(2):
			pos += dir
			get_tile_from_vec(pos).set_as_path()
		
		tile = get_tile_from_vec(pos)
		
		if pos == desired_end and not reached_end:
			reached_end = true
			tile.add_exit()
			continue
		
		if tile.has_event:
			is_challenge = not is_challenge
			continue
		
		if is_challenge:
			tile.add_encounter()
		else:
			tile.add_positive_event()
		
		is_challenge = not is_challenge


func has_tile_at_vec(pos: Vector2i) -> bool:
	return has_tile(pos.x, pos.y)


func has_tile(x: int, y: int) -> bool:
	return x < size.x and y < size.y and x >= 0 and y >= 0


func get_tile_from_vec(pos: Vector2i) -> WorldMapTile:
	return get_tile(pos.x, pos.y)


func get_tile(x: int, y: int) -> WorldMapTile:
	return tiles[x][y]
