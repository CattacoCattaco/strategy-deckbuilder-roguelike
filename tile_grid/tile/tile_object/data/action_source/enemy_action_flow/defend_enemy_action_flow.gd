class_name DefendEnemyActionFlow
extends ActionFlowComponent
## Defends a nearby enemy

## The range to heal in
@export var defend_range: int = 1
## Can the range jump
@export var can_jump: bool = false
## The amount to heal by
@export var defend_size: int = 1

## Do we only care about healable enemies?
@export var healable: bool = false
## Enemies must be at most this distance from player
## -1 = no requirement
@export var max_player_distance: int = -1


func _init(p_defend_range: int = 1, p_can_jump: bool = false, p_defend_size: int = 1,
		p_healable: bool = false, p_max_player_distance: int = -1) -> void:
	defend_range = p_defend_range
	can_jump = p_can_jump
	defend_size = p_defend_size
	
	healable = p_healable
	max_player_distance = p_max_player_distance


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var best_defendable_other: TileObject = null
	var min_player_distance: int = -1
	
	for neighbor_tile in object.get_tiles_in_range(defend_range, can_jump, Modifier.Defend.new()):
		var neighbor_object: TileObject = neighbor_tile.object
		
		if not neighbor_object:
			continue
		
		if neighbor_object == object:
			continue
		
		if neighbor_object in EnemyActionSource.enemies:
			if EnemyActionSource.is_enemy_valid(neighbor_object, healable, max_player_distance):
				var player_distance: int = EnemyActionSource.get_damageable_distance_from_vec(
						neighbor_object.pos, object.tile_grid, can_jump)
				
				if min_player_distance == -1 or player_distance < min_player_distance:
					best_defendable_other = neighbor_object
	
	if best_defendable_other:
		action_source.next_action = CardData.new([Modifier.Defend.new()], defend_range, defend_size)
		action_source.next_action_targets = [best_defendable_other.pos]
	else:
		action_source.next_action = CardData.new()
		action_source.next_action_targets = []
