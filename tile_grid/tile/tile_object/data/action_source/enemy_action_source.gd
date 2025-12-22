class_name EnemyActionSource
extends ActionSource

## The different distance types that can be measured
enum DistanceType {
	## Distance from the closest damageable
	DAMAGEABLE,
	## Distance from the player
	PLAYER,
	## Distance from the closest defendable
	DEFENDABLE,
}
## Do we need to recalc distances next time we try to get a position?
static var distances_need_recalc: bool = true
## The distance from a tile to the player assuming that no jumps can occur
static var player_distances: Array[Array] = []
## The distance from a tile to the closest defendable assuming that no jumps can occur
static var defendable_distances: Array[Array] = []
## The defendables
static var defendables: Array[TileObject] = []
## The enemies
static var enemies: Array[TileObject] = []

@export var action_flow: ActionFlowComponent


static func get_distance_from_enemy(pos: Vector2i, source: TileObject, healable: bool,
		max_player_distance: int, checked_tiles: Array[Vector2i] = []) -> int:
	checked_tiles.append(pos)
	
	var best_distance: int = -1
	
	for dir in Constants.DIRS:
		var neighbor: Vector2i = pos + dir
		
		if neighbor in checked_tiles:
			continue
		
		if not source.tile_grid.has_tile(neighbor.x, neighbor.y):
			continue
		
		var neighbor_tile: Tile = source.tile_grid.get_tile(neighbor.x, neighbor.y)
		
		var neighbor_object: TileObject = neighbor_tile.object
		if neighbor_object:
			if neighbor_object == source:
				continue
			elif neighbor_object in EnemyActionSource.enemies:
				if is_enemy_valid(neighbor_object, healable, max_player_distance):
					return 0
			elif neighbor_object.data.object_type == TileObjectData.ObjectType.STATIC:
				continue
		
		var distance: int = get_distance_from_enemy(neighbor, source, healable, max_player_distance,
				checked_tiles.duplicate())
		
		if best_distance > distance or best_distance == -1:
			best_distance = distance
	
	return best_distance


static func is_enemy_valid(enemy: TileObject, healable: bool, max_player_distance: int) -> bool:
	if healable and enemy.health < enemy.data.max_health:
		return false
	
	var player_distance: int = get_player_distance_from_vec(enemy.pos, enemy.tile_grid)
	if max_player_distance > -1 and player_distance > max_player_distance:
		return false
	
	return true


static func recalc_distances(tile_grid: TileGrid) -> void:
	distances_need_recalc = false
	
	player_distances = []
	
	for x in range(tile_grid.size.x):
		var column: Array[int] = []
		for y in range(tile_grid.size.y):
			column.append(-1)
		
		player_distances.append(column)
	
	var player_pos: Vector2i = tile_grid.hand.player.pos
	
	var prev_positions: Array[Vector2i] = [player_pos]
	player_distances[player_pos.x][player_pos.y] = 0
	
	for distance in range(1, tile_grid.size.x * tile_grid.size.y):
		var new_positions: Array[Vector2i] = []
		
		for old_pos in prev_positions:
			for dir in Constants.DIRS:
				var neighbor_pos: Vector2i = old_pos + dir
				
				if not tile_grid.has_tile(neighbor_pos.x, neighbor_pos.y):
					continue
				
				if get_player_distance_from_vec(neighbor_pos, tile_grid) != -1:
					continue
				
				var neighbor_tile: Tile = tile_grid.get_tile(neighbor_pos.x, neighbor_pos.y)
				if neighbor_tile.object:
					var neighbor_type: TileObjectData.ObjectType
					neighbor_type = neighbor_tile.object.data.object_type
					
					if neighbor_type in [TileObjectData.ObjectType.STATIC,
							TileObjectData.ObjectType.DEFENDABLE]:
						continue
				
				new_positions.append(neighbor_pos)
				player_distances[neighbor_pos.x][neighbor_pos.y] = distance
		
		prev_positions = new_positions
		
		if len(new_positions) == 0:
			break
	
	defendable_distances = []
	
	for x in range(tile_grid.size.x):
		var column: Array[int] = []
		for y in range(tile_grid.size.y):
			column.append(-1)
		
		defendable_distances.append(column)
	
	prev_positions = []
	
	for defendable in defendables:
		var pos: Vector2i = defendable.pos
		prev_positions.append(pos)
		defendable_distances[pos.x][pos.y] = 0
	
	for distance in range(1, tile_grid.size.x * tile_grid.size.y):
		var new_positions: Array[Vector2i] = []
		
		for old_pos in prev_positions:
			for dir in Constants.DIRS:
				var neighbor_pos: Vector2i = old_pos + dir
				
				if not tile_grid.has_tile(neighbor_pos.x, neighbor_pos.y):
					continue
				
				if get_defendable_distance_from_vec(neighbor_pos, tile_grid) != -1:
					continue
				
				var neighbor_tile: Tile = tile_grid.get_tile(neighbor_pos.x, neighbor_pos.y)
				if neighbor_tile.object:
					if neighbor_tile.object.data.object_type == TileObjectData.ObjectType.STATIC:
						continue
				
				new_positions.append(neighbor_pos)
				defendable_distances[neighbor_pos.x][neighbor_pos.y] = distance
		
		prev_positions = new_positions
		
		if len(new_positions) == 0:
			break
	
	#print_distances(tile_grid)


static func print_distances(tile_grid: TileGrid) -> void:
	var print_message: String = "Player distances:\n"
	for y in range(len(player_distances[0])):
		print_message += "["
		for x in range(len(player_distances)):
			print_message += "%2d " % get_player_distance(x, y, tile_grid)
		print_message = print_message.rstrip(" ")
		print_message += "]\n"
	
	print_message += "\n"
	
	print_message += "Defendable distances:\n"
	for y in range(len(player_distances[0])):
		print_message += "["
		for x in range(len(player_distances)):
			print_message += "%2d " % get_defendable_distance(x, y, tile_grid)
		print_message = print_message.rstrip(" ")
		print_message += "]\n"
	
	print_message += "\n"
	
	print_message += "Damageable distances:\n"
	for y in range(len(player_distances[0])):
		print_message += "["
		for x in range(len(player_distances)):
			print_message += "%2d " % get_damageable_distance(x, y, tile_grid)
		print_message = print_message.rstrip(" ")
		print_message += "]\n"
	
	print(print_message)


static func get_distance_from_vec(pos: Vector2i, type: DistanceType, tile_grid: TileGrid) -> int:
	return get_distance(pos.x, pos.y, type, tile_grid)


static func get_distance(x: int, y: int, type: DistanceType, tile_grid: TileGrid) -> int:
	match type:
		DistanceType.DAMAGEABLE:
			return EnemyActionSource.get_damageable_distance(x, y, tile_grid)
		DistanceType.PLAYER:
			return EnemyActionSource.get_player_distance(x, y, tile_grid)
		DistanceType.DEFENDABLE:
			return EnemyActionSource.get_defendable_distance(x, y, tile_grid)
	
	return 0


static func get_damageable_distance_from_vec(pos: Vector2i, tile_grid: TileGrid) -> int:
	return get_damageable_distance(pos.x, pos.y, tile_grid)


static func get_damageable_distance(x: int, y: int, tile_grid: TileGrid) -> int:
	var player_distance: int = get_player_distance(x, y, tile_grid)
	var defendable_distance: int = get_defendable_distance(x, y, tile_grid)
	
	if len(defendables) == 0:
		return player_distance
	
	if player_distance <= defendable_distance:
		return player_distance
	else:
		return defendable_distance


static func get_player_distance_from_vec(pos: Vector2i, tile_grid: TileGrid) -> int:
	return get_player_distance(pos.x, pos.y, tile_grid)


static func get_player_distance(x: int, y: int, tile_grid: TileGrid) -> int:
	if distances_need_recalc:
		recalc_distances(tile_grid)
	
	return player_distances[x][y]


static func get_defendable_distance_from_vec(pos: Vector2i, tile_grid: TileGrid) -> int:
	return get_defendable_distance(pos.x, pos.y, tile_grid)


static func get_defendable_distance(x: int, y: int, tile_grid: TileGrid) -> int:
	if distances_need_recalc:
		recalc_distances(tile_grid)
	
	return defendable_distances[x][y]


func _init(p_speed: int = 0, p_preview_actions: bool = true,
		p_action_flow: ActionFlowComponent = null) -> void:
	action_flow = p_action_flow
	
	super(p_speed, p_preview_actions)


func _generate_next_action(object: TileObject) -> void:
	action_flow._resolve(object, self)
