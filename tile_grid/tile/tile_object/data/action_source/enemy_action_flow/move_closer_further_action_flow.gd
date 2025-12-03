class_name MoveCloserFurtherActionFlow
extends ActionFlowComponent
## Moves as close or as far from the player as possible

const DistanceType = EnemyActionSource.DistanceType

## The distance type used to check closeness or farness
@export var distance_type: DistanceType
## The range of the movement
@export var move_range: int = 1
## Can this enemy jump?
@export var can_jump: bool = false
## Is the goal to get closer?[br]
## If true, will get as close as possible[br]
## If false, will get as far as possible
@export var closer: bool = true


func _init(p_distance_type: DistanceType = DistanceType.DAMAGEABLE, p_move_range: int = 1,
		p_can_jump: bool = false, p_closer: bool = true) -> void:
	distance_type = p_distance_type
	move_range = p_move_range
	can_jump = p_can_jump
	closer = p_closer


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var best_distance: int = EnemyActionSource.get_distance_from_vec(object.pos, distance_type)
	var best_pos: Vector2i = object.pos
	
	for tile: Tile in object.get_tiles_in_range(move_range, can_jump, false):
		var distance: int =  EnemyActionSource.get_distance_from_vec(tile.pos, distance_type)
		
		if (distance < best_distance and closer) or (distance > best_distance and not closer):
			best_distance = distance
			best_pos = tile.pos
	
	var modifiers: Array[Modifier] = [Modifier.Move.new()]
	if can_jump:
		modifiers.append(Modifier.Jump.new())
	
	action_source.next_action = CardData.new(modifiers, move_range, 0)
	action_source.next_action_targets = [best_pos]
