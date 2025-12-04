class_name LevelBuilder
extends Node2D

enum ObjectDensity {
	SPARSE,
	MILD,
	FEATUREFUL,
	DENSE,
}

@export var tile_grid: TileGrid

@export var player_data: TileObjectData
@export var movement_region_object_data: TileObjectData
@export var clump_obstacles: WeightedObjectList
@export var single_obstacles: WeightedObjectList
@export var defendable: TileObjectData
@export var enemies_by_level: Array[WeightedObjectList]
@export var mission_enemies_by_level: Array[WeightedObjectList]

var density: ObjectDensity

var untouched_cells: Array[Vector2i]


func place_objects() -> void:
	var world_map: WorldMap = tile_grid.world_map
	
	var tile_count: int = tile_grid.size.x * tile_grid.size.y
	
	untouched_cells = []
	
	for x in range(tile_grid.size.x):
		for y in range(tile_grid.size.y):
			untouched_cells.append(Vector2i(x, y))
	
	var movement_region_origin := Vector2i(randi_range(2, tile_grid.size.x - 2), 
			randi_range(2, tile_grid.size.y - 2))
	var designated_movement_region: Array[Vector2i] = [movement_region_origin]
	var movement_region_size: int
	
	match density:
		ObjectDensity.SPARSE:
			movement_region_size = ceili(randf_range(0.6 * tile_count, 0.8 * tile_count))
		ObjectDensity.MILD:
			movement_region_size = ceili(randf_range(0.45 * tile_count, 0.6 * tile_count))
		ObjectDensity.FEATUREFUL:
			movement_region_size = ceili(randf_range(0.25 * tile_count, 0.45 * tile_count))
		ObjectDensity.DENSE:
			movement_region_size = ceili(randf_range(0.1 * tile_count, 0.25 * tile_count))
	
	untouched_cells.erase(movement_region_origin)
	
	while len(designated_movement_region) < movement_region_size:
		walk(movement_region_origin, designated_movement_region, movement_region_size, 
				[Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)].pick_random())
	
	designated_movement_region.erase(movement_region_origin)
	var origin_tile: Tile = tile_grid.get_tile(movement_region_origin.x, movement_region_origin.y)
	origin_tile.add_object(player_data)
	tile_grid.hand.player = origin_tile.object
	
	var clump_count: int
	match density:
		ObjectDensity.SPARSE:
			clump_count = floori(randf_range(tile_count * 0.01, tile_count * 0.02))
		ObjectDensity.MILD:
			clump_count = floori(randf_range(tile_count * 0.02, tile_count * 0.04))
		ObjectDensity.FEATUREFUL:
			clump_count = floori(randf_range(tile_count * 0.04, tile_count * 0.06))
		ObjectDensity.DENSE:
			clump_count = floori(randf_range(tile_count * 0.06, tile_count * 0.1))
	
	if clump_count < 1:
		clump_count = 1
	
	for i in range(clump_count):
		if len(untouched_cells) == 0:
			break
		
		var clump_object: TileObjectData = clump_obstacles.get_random_object()
		
		var start_pos_index: int = randi_range(0, len(untouched_cells) - 1)
		var pos: Vector2i = untouched_cells[start_pos_index]
		untouched_cells.remove_at(start_pos_index)
		
		var tile: Tile = tile_grid.get_tile(pos.x, pos.y)
		tile.add_object(clump_object)
		
		var clump_size: int
		match density:
			ObjectDensity.SPARSE:
				clump_size = randi_range(1, 3)
			ObjectDensity.MILD:
				clump_size = randi_range(2, 5)
			ObjectDensity.FEATUREFUL:
				clump_size = randi_range(3, 7)
			ObjectDensity.DENSE:
				clump_size = randi_range(4, 10)
		
		for j in range(clump_size):
			var empty_neighbors: Array[Vector2i] = []
			for dir in [Vector2i(0, 1), Vector2i(1,0), Vector2i(0, -1), Vector2i(-1,0)]:
				if pos + dir in untouched_cells:
					empty_neighbors.append(pos + dir)
			
			if len(empty_neighbors) == 0:
				break
			
			pos = empty_neighbors.pick_random()
			untouched_cells.erase(pos)
			
			tile = tile_grid.get_tile(pos.x, pos.y)
			tile.add_object(clump_object)
	
	var single_obstacle_count: int
	match density:
		ObjectDensity.SPARSE:
			single_obstacle_count = floori(randf_range(tile_count * 0.025, tile_count * 0.5))
		ObjectDensity.MILD:
			single_obstacle_count = floori(randf_range(tile_count * 0.05, tile_count * 0.1))
		ObjectDensity.FEATUREFUL:
			single_obstacle_count = floori(randf_range(tile_count * 0.1, tile_count * 0.15))
		ObjectDensity.DENSE:
			single_obstacle_count = floori(randf_range(tile_count * 0.15, tile_count * 0.2))
	
	if single_obstacle_count < 1:
		single_obstacle_count = 1
	
	for i in range(single_obstacle_count):
		if len(untouched_cells) == 0:
			break
		
		var pos_index: int = randi_range(0, len(untouched_cells) - 1)
		var pos: Vector2i = untouched_cells[pos_index]
		untouched_cells.remove_at(pos_index)
		
		var tile: Tile = tile_grid.get_tile(pos.x, pos.y)
		tile.add_object(single_obstacles.get_random_object())
	
	EnemyActionSource.defendables = []
	
	var enemy_count: int = world_map.levels_beat + 2 * world_map.world_num + 1
	
	if tile_grid.is_mission:
		enemy_count = ceili(enemy_count / 4.0)
		
		var defendable_count: int = ceili((world_map.levels_beat + 1) / 7.0)
		
		for i in range(defendable_count):
			var pos_index: int = randi_range(0, len(designated_movement_region) - 1)
			var pos: Vector2i = designated_movement_region[pos_index]
			designated_movement_region.remove_at(pos_index)
			
			var tile: Tile = tile_grid.get_tile(pos.x, pos.y)
			tile.add_object(defendable)
			EnemyActionSource.defendables.append(tile.object)
	
	var current_enemies: WeightedObjectList
	if tile_grid.is_mission:
		current_enemies = mission_enemies_by_level[world_map.world_num]
	else:
		current_enemies = enemies_by_level[world_map.world_num]
	
	for i in range(enemy_count):
		var pos_index: int = randi_range(0, len(designated_movement_region) - 1)
		var pos: Vector2i = designated_movement_region[pos_index]
		designated_movement_region.remove_at(pos_index)
		
		var tile: Tile = tile_grid.get_tile(pos.x, pos.y)
		tile.add_object(current_enemies.get_random_object())
	
	EnemyActionSource.recalc_distances(tile_grid)


func walk(current_pos: Vector2i, region: Array[Vector2i], goal_size: int, from: Vector2i,
		branch_length: int = 0) -> void:
	if len(region) >= goal_size:
		return
	
	var valid_neighbors: Array[Vector2i] = []
	var semivalid_neighbors: Array[Vector2i] = []
	
	for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
		if current_pos + dir in untouched_cells:
			valid_neighbors.append(current_pos + dir)
		elif len(valid_neighbors) == 0 and current_pos + dir in region:
			semivalid_neighbors.append(current_pos + dir)
	
	if randf() < 0.025 * branch_length:
		return
	
	# Add 1 to 3 tiles, with a bias towards making 1
	for i in range([1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3].pick_random()):
		# 60% chance to keep going in current direction if possible
		if current_pos + from in valid_neighbors and randf() < 0.6:
			var next_pos: Vector2i = current_pos + from
			
			region.append(next_pos)
			untouched_cells.erase(next_pos)
			walk(next_pos, region, goal_size, from)
			
			valid_neighbors.erase(next_pos)
		# Try to add new spaces before walking to existing spaces
		elif len(valid_neighbors) > 0:
			var next_pos: Vector2i = valid_neighbors.pick_random()
			
			region.append(next_pos)
			untouched_cells.erase(next_pos)
			walk(next_pos, region, goal_size, next_pos - current_pos)
			
			valid_neighbors.erase(next_pos)
		# Try to walk to existing spaces before giving up
		elif len(semivalid_neighbors) > 0:
			var next_pos: Vector2i = semivalid_neighbors.pick_random()
			
			walk(next_pos, region, goal_size, next_pos - current_pos)
			
			# We shouldn't make too many branches here
			continue
