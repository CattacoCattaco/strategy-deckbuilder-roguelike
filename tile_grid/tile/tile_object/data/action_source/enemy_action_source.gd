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
## The distance from a tile to the player assuming that no jumps can occur
static var player_distances: Dictionary[Vector2i, int] = {}
## The distance from a tile to the closest defendable assuming that no jumps can occur
static var defendable_distances: Dictionary[Vector2i, int] = {}
## The defendables
static var defendables: Array[TileObject] = []
## The enemies
static var enemies: Array[TileObject] = []

@export var action_flow: ActionFlowComponent


static func get_distance_from_enemy(pos: Vector2i, source: TileObject, healable: bool,
		max_player_distance: int, can_jump: bool) -> int:
	if can_jump:
		var best_distance: int = -1
		
		for enemy in enemies:
			var jump_distance: int = absi(pos.x - enemy.pos.x) + absi(pos.y - enemy.pos.y)
			
			if best_distance == -1 or jump_distance < best_distance:
				best_distance = jump_distance
		
		return best_distance
	
	if pos != source.pos:
		var current_tile: Tile = source.tile_grid.get_tile(pos.x, pos.y)
		if current_tile.object:
			var type: TileObjectData.ObjectType = current_tile.object.data.object_type
			if type == TileObjectData.ObjectType.ENEMY:
				return 0
	
	var prev_gen: Array[Vector2i] = [pos]
	var checked: Array[Vector2i] = [pos, source.pos]
	
	var distance: int = 0
	
	while len(prev_gen) > 0:
		distance += 1
		
		var new_gen: Array[Vector2i] = []
		
		for old_pos in prev_gen:
			for dir in Constants.DIRS:
				var neighbor: Vector2i = old_pos + dir
				
				var no_tile: bool = not source.tile_grid.has_tile(neighbor.x, neighbor.y)
				if no_tile or neighbor in checked:
					continue
				
				checked.append(neighbor)
				
				var neighbor_tile: Tile = source.tile_grid.get_tile(neighbor.x, neighbor.y)
				
				if neighbor_tile.object:
					var type: TileObjectData.ObjectType = neighbor_tile.object.data.object_type
					if type == TileObjectData.ObjectType.ENEMY:
						if is_enemy_valid(neighbor_tile.object, healable, max_player_distance):
							return distance
					elif not neighbor_tile.object.data.moves():
						continue
				
				new_gen.append(neighbor)
		
		prev_gen = new_gen
	
	return -1


static func is_enemy_valid(enemy: TileObject, healable: bool, max_player_distance: int) -> bool:
	if healable and enemy.health < enemy.data.max_health:
		return false
	
	var player_distance: int = get_player_distance_from_vec(enemy.pos, enemy.tile_grid, false)
	if max_player_distance > -1 and player_distance > max_player_distance:
		return false
	
	return true


static func get_distance_from_vec(pos: Vector2i, type: DistanceType, tile_grid: TileGrid,
		can_jump: bool) -> int:
	return get_distance(pos.x, pos.y, type, tile_grid, can_jump)


static func get_distance(x: int, y: int, type: DistanceType, tile_grid: TileGrid, can_jump: bool
		) -> int:
	match type:
		DistanceType.DAMAGEABLE:
			return EnemyActionSource.get_damageable_distance(x, y, tile_grid, can_jump)
		DistanceType.PLAYER:
			return EnemyActionSource.get_player_distance(x, y, tile_grid, can_jump)
		DistanceType.DEFENDABLE:
			return EnemyActionSource.get_defendable_distance(x, y, tile_grid, can_jump)
	
	return 0


static func get_damageable_distance_from_vec(pos: Vector2i, tile_grid: TileGrid, can_jump: bool
		) -> int:
	return get_damageable_distance(pos.x, pos.y, tile_grid, can_jump)


static func get_damageable_distance(x: int, y: int, tile_grid: TileGrid, can_jump: bool) -> int:
	var player_distance: int = get_player_distance(x, y, tile_grid, can_jump)
	var defendable_distance: int = get_defendable_distance(x, y, tile_grid, can_jump)
	
	if len(defendables) == 0:
		return player_distance
	
	if player_distance <= defendable_distance:
		return player_distance
	else:
		return defendable_distance


static func get_player_distance_from_vec(pos: Vector2i, tile_grid: TileGrid, can_jump: bool) -> int:
	return get_player_distance(pos.x, pos.y, tile_grid, can_jump)


static func get_player_distance(x: int, y: int, tile_grid: TileGrid, can_jump: bool) -> int:
	var pos := Vector2i(x, y)
	
	var player_pos: Vector2i = tile_grid.hand.player.pos
	
	print("pos: ", pos)
	print("player: ", player_pos)
	
	if can_jump:
		return absi(pos.x - player_pos.x) + absi(pos.y - player_pos.y)
	
	if pos in player_distances:
		return player_distances[pos]
	
	if pos == player_pos:
		player_distances[pos] = 0
		return 0
	
	var prev_gen: Array[Vector2i] = [player_pos]
	var checked: Array[Vector2i] = [player_pos]
	
	var distance: int = 0
	
	while len(prev_gen) > 0:
		distance += 1
		
		var new_gen: Array[Vector2i] = []
		
		for old_pos in prev_gen:
			for dir in Constants.DIRS:
				var neighbor: Vector2i = old_pos + dir
				
				var no_tile: bool = not tile_grid.has_tile(neighbor.x, neighbor.y)
				if no_tile or neighbor in checked:
					continue
				
				player_distances[neighbor] = distance
				
				print("Neighbor: ", neighbor)
				print("Neighbor Distance: ", distance)
				
				if neighbor == pos:
					return distance
				
				checked.append(neighbor)
				
				var neighbor_tile: Tile = tile_grid.get_tile(neighbor.x, neighbor.y)
				
				if neighbor_tile.object:
					if not neighbor_tile.object.data.moves():
						continue
				
				new_gen.append(neighbor)
		
		prev_gen = new_gen
	
	return -1


static func get_defendable_distance_from_vec(pos: Vector2i, tile_grid: TileGrid, can_jump: bool
		) -> int:
	return get_defendable_distance(pos.x, pos.y, tile_grid, can_jump)


static func get_defendable_distance(x: int, y: int, tile_grid: TileGrid, can_jump: bool) -> int:
	if len(defendables) == 0:
		return -1
	
	var pos := Vector2i(x, y)
	
	var current_tile: Tile = tile_grid.get_tile(pos.x, pos.y)
	
	if current_tile.object:
		var type: TileObjectData.ObjectType = current_tile.object.data.object_type
		if type == TileObjectData.ObjectType.DEFENDABLE:
			return 0
	
	if can_jump:
		var best_distance: int = -1
		for defendable in defendables:
			var defendable_distance: int = current_tile.get_distance(defendable.pos, true)
			
			if best_distance == -1 or defendable_distance < best_distance:
				best_distance = defendable_distance
		
		return best_distance
	
	if pos in defendable_distances:
		return defendable_distances[pos]
	
	var prev_gen: Array[Vector2i] = [pos]
	var checked: Array[Vector2i] = [pos]
	
	var distance: int = 0
	
	while len(prev_gen) > 0:
		distance += 1
		
		var new_gen: Array[Vector2i] = []
		
		for old_pos in prev_gen:
			for dir in Constants.DIRS:
				var neighbor: Vector2i = old_pos + dir
				
				var no_tile: bool = not tile_grid.has_tile(neighbor.x, neighbor.y)
				if no_tile or neighbor in checked:
					continue
				
				checked.append(neighbor)
				
				var neighbor_tile: Tile = tile_grid.get_tile(neighbor.x, neighbor.y)
				
				if neighbor_tile.object:
					var type: TileObjectData.ObjectType = neighbor_tile.object.data.object_type
					if type == TileObjectData.ObjectType.DEFENDABLE:
						defendable_distances[pos] = distance
						return distance
					elif type == TileObjectData.ObjectType.STATIC:
						continue
				
				new_gen.append(neighbor)
		
		prev_gen = new_gen
	
	return -1


func _init(p_speed: int = 0, p_preview_actions: bool = true,
		p_action_flow: ActionFlowComponent = null) -> void:
	action_flow = p_action_flow
	
	super(p_speed, p_preview_actions)


func _generate_next_action(object: TileObject) -> void:
	action_flow._resolve(object, self)
