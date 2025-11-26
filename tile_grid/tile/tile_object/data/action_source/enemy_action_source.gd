class_name EnemyActionSource
extends ActionSource

## The distance from a tile to the player assuming that no jumps can occur
static var player_distances: Array[Array] = []

@export var move_range: int = 1
@export var attack_range: int = 1
@export var attack_damage: int = 1
@export var heal_range: int = 1
@export var heal_size: int = 1

## A number from 0 to 1 representing how aggressively an enemy acts[br][br]
## Aggressive enemies tend to try to attack the player if possible or
## decrease their distance from the player
@export var aggressiveness: float = 0.8
## A number from 0 to 1 representing how fearfully an enemy acts[br][br]
## Fearful enemies tend to try to increase their distance from the player
@export var fearfulness: float = 0.1


static func recalc_distances(tile_grid: TileGrid) -> void:
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
			for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
				var neighbor_pos: Vector2i = old_pos + dir
				
				if not tile_grid.has_tile(neighbor_pos.x, neighbor_pos.y):
					continue
				
				if get_player_distance_from_vec(neighbor_pos) != -1:
					continue
				
				var neighbor_tile: Tile = tile_grid.get_tile(neighbor_pos.x, neighbor_pos.y)
				if neighbor_tile.object:
					if neighbor_tile.object.data.object_type == TileObjectData.ObjectType.STATIC:
						continue
				
				new_positions.append(neighbor_pos)
				player_distances[neighbor_pos.x][neighbor_pos.y] = distance
		
		prev_positions = new_positions
		
		if len(new_positions) == 0:
			break


static func print_player_distances() -> void:
	var print_message: String = "Player_distances:\n"
	for y in range(len(player_distances[0])):
		print_message += "["
		for x in range(len(player_distances)):
			print_message += "%2d " % get_player_distance(x, y)
		print_message = print_message.rstrip(" ")
		print_message += "]\n"
	
	print(print_message)


static func get_player_distance_from_vec(pos: Vector2i) -> int:
	return get_player_distance(pos.x, pos.y)


static func get_player_distance(x: int, y: int) -> int:
	return player_distances[x][y]


func _init(p_speed: int = 0, p_preview_actions: bool = true, p_move_range: int = 1,
		p_attack_range: int = 1, p_attack_damage: int = 1, p_heal_range: int = 1,
		p_heal_size: int = 1, p_aggressiveness: float = 0.8, p_fearfulness: float = 0.1) -> void:
	move_range = p_move_range
	attack_range = p_attack_range
	attack_damage = p_attack_damage
	heal_range = p_heal_range
	heal_size = p_heal_size
	
	aggressiveness = p_aggressiveness
	fearfulness = p_fearfulness
	
	super(p_speed, p_preview_actions)


func generate_next_action(object: TileObject) -> void:
	var pos: Vector2i = object.pos
	
	var player_distance: int = get_player_distance_from_vec(pos)
	
	if randf() < aggressiveness:
		if player_distance <= attack_range:
			next_action = CardData.new([Modifier.Attack.new()], attack_range, attack_damage)
			next_action_targets = [object.tile_grid.hand.player.pos]
			return
		
		var closest_distance: int = get_player_distance_from_vec(object.pos)
		var closest_pos: Vector2i = object.pos
		
		for tile: Tile in object.get_tiles_in_range(move_range, false, false):
			var distance: int = get_player_distance_from_vec(tile.pos)
			
			if distance < closest_distance:
				closest_distance = distance
				closest_pos = tile.pos
		
		next_action = CardData.new([Modifier.Move.new()], move_range, 0)
		next_action_targets = [closest_pos]
		return
	
	if randf() < fearfulness:
		var furthest_distance: int = get_player_distance_from_vec(object.pos)
		var furthest_pos: Vector2i = object.pos
		
		for tile: Tile in object.get_tiles_in_range(move_range, false, false):
			var distance: int = get_player_distance_from_vec(tile.pos)
			
			if distance > furthest_distance:
				furthest_distance = distance
				furthest_pos = tile.pos
		
		next_action = CardData.new([Modifier.Move.new()], move_range, 0)
		next_action_targets = [furthest_pos]
		return
	
	next_action = CardData.new([Modifier.Move.new()], move_range, 0)
	next_action_targets = [object.get_tiles_in_range(move_range, false, false).pick_random().pos]
