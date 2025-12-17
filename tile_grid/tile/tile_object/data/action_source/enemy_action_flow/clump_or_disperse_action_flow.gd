class_name ClumpOrDisperseActionFlow
extends ActionFlowComponent
## Moves as close or as far from other enemies as possible

const DistanceType = EnemyActionSource.DistanceType

## The range of the movement
@export var move_range: int = 1
## Can this enemy jump?
@export var can_jump: bool = false
## Is the goal to clump together with other enemies?[br]
## If true, will get as close as possible[br]
## If false, will get as far as possible
@export var clump: bool = true

## Do we only care about healable enemies?
@export var healable: bool = false


func _init(p_move_range: int = 1, p_can_jump: bool = false, p_clump: bool = true,
		p_healable: bool = false) -> void:
	move_range = p_move_range
	can_jump = p_can_jump
	clump = p_clump
	
	healable = p_healable


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var best_distance: int = EnemyActionSource.get_distance_from_enemy(object.pos, object, healable)
	var best_pos: Vector2i = object.pos
	
	for tile: Tile in object.get_tiles_in_range(move_range, can_jump, Modifier.Move.new()):
		var distance: int =  EnemyActionSource.get_distance_from_enemy(tile.pos, object,
				healable)
		
		if (distance < best_distance and clump) or (distance > best_distance and not clump):
			best_distance = distance
			best_pos = tile.pos
	
	var modifiers: Array[Modifier] = [Modifier.Move.new()]
	if can_jump:
		modifiers.append(Modifier.Jump.new())
	
	action_source.next_action = CardData.new(modifiers, move_range, 0)
	action_source.next_action_targets = [best_pos]
