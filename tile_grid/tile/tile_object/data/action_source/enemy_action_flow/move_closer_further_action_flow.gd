class_name MoveCloserFurtherActionFlow
extends ActionFlowComponent
## Moves as close or as far from the player as possible

## The range of the movement
@export var move_range: int = 1
## Is the goal to get closer?[br]
## If true, will get as close as possible[br]
## If false, will get as far as possible
@export var closer: bool = true


func _init(p_move_range: int = 1, p_closer: bool = true) -> void:
	move_range = p_move_range
	closer = p_closer


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var best_distance: int = EnemyActionSource.get_player_distance_from_vec(object.pos)
	var best_pos: Vector2i = object.pos
	
	for tile: Tile in object.get_tiles_in_range(move_range, false, false):
		var distance: int =  EnemyActionSource.get_player_distance_from_vec(tile.pos)
		
		if (distance < best_distance and closer) or (distance > best_distance and not closer):
			best_distance = distance
			best_pos = tile.pos
	
	action_source.next_action = CardData.new([Modifier.Move.new()], move_range, 0)
	action_source.next_action_targets = [best_pos]
