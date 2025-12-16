class_name EnemyAmountCheckActionFlow
extends ActionFlowComponent
## Chooses an ActionFlowComponent based on comparing the number of enemies to
## a threshold or comparing it to a different distance type

## The threshold being checked
@export var threshold: int = 1

## Do we only care about healable enemies?
@export var healable: bool = false

## What to do if distance is below threshold
@export var below: ActionFlowComponent
## What to do if distance is at threshold
@export var at: ActionFlowComponent
## What to do if distance is above threshold
@export var above: ActionFlowComponent


func _init(p_threshold: int = 1, p_healable: bool = false, p_below: ActionFlowComponent = null,
		p_at: ActionFlowComponent = null, p_above: ActionFlowComponent = null) -> void:
	threshold = p_threshold
	
	healable = p_healable
	
	below = p_below
	at = p_at
	above = p_above


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var enemy_count: int = 0
	
	if healable:
		for enemy in EnemyActionSource.enemies:
			if enemy.health < enemy.data.max_health:
				enemy_count += 1
	else:
		enemy_count = len(EnemyActionSource.enemies)
	
	if enemy_count < threshold:
		below._resolve(object, action_source)
	elif enemy_count == threshold:
		at._resolve(object, action_source)
	elif enemy_count > threshold:
		above._resolve(object, action_source)
