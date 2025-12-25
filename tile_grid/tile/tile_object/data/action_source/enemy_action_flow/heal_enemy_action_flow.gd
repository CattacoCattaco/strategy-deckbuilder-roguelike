class_name HealEnemyActionFlow
extends ActionFlowComponent
## Heals a nearby enemy

## The range to heal in
@export var heal_range: int = 1
## Can the range jump
@export var can_jump: bool = false
## The amount to heal by
@export var heal_size: int = 1


func _init(p_heal_range: int = 1, p_can_jump: bool = false, p_heal_size: int = 1) -> void:
	heal_range = p_heal_range
	can_jump = p_can_jump
	heal_size = p_heal_size


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var healable_others: Array[Vector2i] = []
	
	for neighbor_tile in object.get_tiles_in_range(heal_range, can_jump, Modifier.Heal.new()):
		var neighbor_object: TileObject = neighbor_tile.object
		
		if not neighbor_object:
			continue
		
		if neighbor_object == object:
			continue
		
		if neighbor_object in EnemyActionSource.enemies:
			if neighbor_object.health < neighbor_object.data.max_health:
				healable_others.append(neighbor_object.pos)
	
	action_source.next_action = CardData.new([Modifier.Heal.new()], heal_range, heal_size)
	if len(healable_others) > 0:
		var lowest_health_other: TileObject = (
				object.tile_grid.get_tile(healable_others[0].x, healable_others[0].y).object)
		var lowest_health: int = lowest_health_other.health
		
		for i in range(1, len(healable_others)):
			var other: TileObject = (
					object.tile_grid.get_tile(healable_others[i].x, healable_others[i].y).object)
			
			if other.health < lowest_health:
				lowest_health_other = other
				lowest_health = other.health
		
		action_source.next_action_targets = [lowest_health_other.pos]
	elif object.health < object.data.max_health:
		action_source.next_action_targets = [object.pos]
	else:
		action_source.next_action = CardData.new()
		action_source.next_action_targets = []
