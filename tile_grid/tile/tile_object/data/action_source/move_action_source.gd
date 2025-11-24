class_name MoveActionSource
extends ActionSource


func _init(p_speed: int = 0, p_preview_actions: bool = true) -> void:
	super(p_speed, p_preview_actions)


func generate_next_action(object: TileObject) -> void:
	var pos: Vector2i = object.pos
	var empty_neighbors: Array[Vector2i]
	
	for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
		var neighbor: Vector2i = pos + dir
		var tile_grid: TileGrid = object.tile_grid
		
		if not tile_grid.has_tile(neighbor.x, neighbor.y):
			continue
		
		var neighbor_tile: Tile = tile_grid.get_tile(neighbor.x, neighbor.y)
		
		if not neighbor_tile.object:
			empty_neighbors.append(neighbor)
	
	if len(empty_neighbors) == 0:
		next_action = CardData.new([], 0, 0)
		next_action_targets = []
	else:
		next_action = CardData.new([Modifier.Move.new()], 1, 0)
		next_action_targets = [empty_neighbors.pick_random()]
