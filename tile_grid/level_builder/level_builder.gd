class_name LevelBuilder
extends Node2D

@export var tile_grid: TileGrid

@export var clump_obstacles: Array[TileObjectData]
@export var clump_obstacle_weights: Array[int]
@export var single_obstacles: Array[TileObjectData]
@export var single_obstacle_weights: Array[int]


func place_objects() -> void:
	var tile_count: int = tile_grid.size.x * tile_grid.size.y
	
	var untouched_cells: Array[Vector2i] = []
	
	for x in range(tile_grid.size.x):
		for y in range(tile_grid.size.y):
			untouched_cells.append(Vector2i(x, y))
	
	var clump_count: int = floori(randf_range(tile_count / 80.0, tile_count / 25.0))
	for i in range(clump_count):
		var clump_object: TileObjectData = (
				pick_random_weighted(clump_obstacles, clump_obstacle_weights))
		
		var start_pos_index: int = randi_range(0, len(untouched_cells) - 1)
		var pos: Vector2i = untouched_cells[start_pos_index]
		untouched_cells.remove_at(start_pos_index)
		
		var tile: Tile = tile_grid.tiles[pos.x][pos.y]
		tile.add_object(clump_object)
		
		for j in range(randi_range(2, 7)):
			var empty_neighbors: Array[Vector2i] = []
			for dir in [Vector2i(0, 1), Vector2i(1,0), Vector2i(0, -1), Vector2i(-1,0)]:
				if pos + dir in untouched_cells:
					empty_neighbors.append(pos + dir)
			
			if len(empty_neighbors) == 0:
				break
			
			pos = empty_neighbors.pick_random()
			untouched_cells.erase(pos)
			
			tile = tile_grid.tiles[pos.x][pos.y]
			tile.add_object(clump_object)
	
	var single_obstacle_count: int = floori(randf_range(tile_count / 20.0, tile_count / 10.0))
	for i in range(single_obstacle_count):
		var pos_index: int = randi_range(0, len(untouched_cells) - 1)
		var pos: Vector2i = untouched_cells[pos_index]
		untouched_cells.remove_at(pos_index)
		
		var tile: Tile = tile_grid.tiles[pos.x][pos.y]
		tile.add_object(pick_random_weighted(single_obstacles, single_obstacle_weights))


func pick_random_weighted(data_list: Array[TileObjectData], weights: Array[int]) -> TileObjectData:
	var weighted_list: Array[TileObjectData] = []
	
	for i in range(len(data_list)):
		for j in range(weights[i]):
			weighted_list.append(data_list[i])
	
	return weighted_list.pick_random()
