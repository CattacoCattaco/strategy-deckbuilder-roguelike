class_name EnemyDistanceCheckActionFlow
extends ActionFlowComponent
## Chooses an ActionFlowComponent based on comparing the enemie's distance from the nearest
## other enemy to a threshold or comparing it to a different distance type

## The threshold being checked
@export var threshold: int = 1

## Must the enemies be healable?
@export var healable: bool = false
## Enemies must be at most this distance from player
## -1 = no requirement
@export var max_player_distance: int = -1

## What to do if distance is below threshold
@export var below: ActionFlowComponent
## What to do if distance is at threshold
@export var at: ActionFlowComponent
## What to do if distance is above threshold
@export var above: ActionFlowComponent


func _init(p_threshold: int = 1, p_healable: bool = false, p_max_player_distance: int = -1,
		p_below: ActionFlowComponent = null, p_at: ActionFlowComponent = null,
		p_above: ActionFlowComponent = null) -> void:
	threshold = p_threshold
	
	healable = p_healable
	max_player_distance = p_max_player_distance
	
	below = p_below
	at = p_at
	above = p_above


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var enemy_distance: int = EnemyActionSource.get_distance_from_enemy(object.pos, object,
			healable, max_player_distance, false)
	
	if enemy_distance < threshold:
		below._resolve(object, action_source)
	elif enemy_distance == threshold:
		at._resolve(object, action_source)
	elif enemy_distance > threshold:
		above._resolve(object, action_source)
