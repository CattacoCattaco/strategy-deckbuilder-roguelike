class_name HealEnemyActionFlow
extends ActionFlowComponent
## Chooses an ActionFlowComponent based on comparing the enemies distance to
## a threshold or comparing it to a different distance type

## The range to heal in
@export var heal_range: int = 1
## The amount to heal by
@export var heal_size: int = 1


func _init(p_heal_range: int = 1, p_heal_size: int = 1) -> void:
	heal_range = p_heal_range
	heal_size = p_heal_size


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var healable_others: Array[Vector2i] = []
	
	for neighbor_tile in object.get_tiles_in_range(heal_range, false, Modifier.Heal.new()):
		var neighbor_object: TileObject = neighbor_tile.object
		
		if not neighbor_object:
			continue
		
		if neighbor_object == object:
			continue
		
		if neighbor_object in EnemyActionSource.enemies:
			if neighbor_object.health < neighbor_object.data.max_health:
				healable_others.append(neighbor_object)
	
	action_source.next_action = CardData.new([Modifier.Heal.new()], heal_range, heal_size)
	if len(healable_others) > 0:
		action_source.next_action_targets = [healable_others.pick_random()]
	elif object.health < object.data.max_health:
		action_source.next_action_targets = [object.pos]
	else:
		action_source.next_action = CardData.new()
		action_source.next_action_targets = []
