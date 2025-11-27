class_name DistanceCheckActionFlow
extends ActionFlowComponent
## Chooses an ActionFlowComponent based on distance from player

## The threshold being checked
@export var threshold: int = 1
## What to do if distance is below threshold
@export var below: ActionFlowComponent
## What to do if distance is at threshold
@export var at: ActionFlowComponent
## What to do if distance is above threshold
@export var above: ActionFlowComponent


func _init(p_threshold: int = 1, p_below: ActionFlowComponent = null,
		p_at: ActionFlowComponent = null, p_above: ActionFlowComponent = null) -> void:
	threshold = p_threshold
	below = p_below
	at = p_at
	above = p_above


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var player_distance: int = EnemyActionSource.get_player_distance_from_vec(object.pos)
	
	if player_distance < threshold:
		below._resolve(object, action_source)
	elif player_distance == threshold:
		at._resolve(object, action_source)
	else:
		above._resolve(object, action_source)
