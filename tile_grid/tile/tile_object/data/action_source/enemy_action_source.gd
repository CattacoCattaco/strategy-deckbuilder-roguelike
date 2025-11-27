class_name EnemyActionSource
extends ActionSource

## The distance from a tile to the player assuming that no jumps can occur
static var player_distances: Array[Array] = []

@export var action_flow: ActionFlowComponent


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


func _init(p_speed: int = 0, p_preview_actions: bool = true,
		p_action_flow: ActionFlowComponent = null) -> void:
	action_flow = p_action_flow
	
	super(p_speed, p_preview_actions)


func _generate_next_action(object: TileObject) -> void:
	action_flow._resolve(object, self)
