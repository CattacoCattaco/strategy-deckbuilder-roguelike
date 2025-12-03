class_name DistanceCheckActionFlow
extends ActionFlowComponent
## Chooses an ActionFlowComponent based on comparing the enemies distance to
## a threshold or comparing it to a different distance type

const DistanceType = EnemyActionSource.DistanceType

## The distance type being measured
@export var distance_type: DistanceType

## If true, compare the distance to a threshold[br]
## If false, compare the distance to distance_2
@export var use_threshold: bool = true
## The threshold being checked
@export var threshold: int = 1
## The distance type being compared to if [param use_threshold] is false
@export var comp_distance_type: DistanceType

## What to do if distance is below threshold
@export var below: ActionFlowComponent
## What to do if distance is at threshold
@export var at: ActionFlowComponent
## What to do if distance is above threshold
@export var above: ActionFlowComponent


func _init(p_distance_type: DistanceType = DistanceType.DAMAGEABLE, p_use_threshold: bool = true,
		p_threshold: int = 1, p_comp_distance_type: DistanceType = DistanceType.DAMAGEABLE,
		p_below: ActionFlowComponent = null, p_at: ActionFlowComponent = null,
		p_above: ActionFlowComponent = null) -> void:
	distance_type = p_distance_type
	
	use_threshold = p_use_threshold
	threshold = p_threshold
	comp_distance_type = p_comp_distance_type
	
	below = p_below
	at = p_at
	above = p_above


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var base_distance: int = EnemyActionSource.get_distance_from_vec(object.pos, distance_type)
	var comp_value: int
	
	if use_threshold:
		comp_value = threshold
	else:
		comp_value = EnemyActionSource.get_distance_from_vec(object.pos, comp_distance_type)
	
	if base_distance < comp_value:
		print("below")
		below._resolve(object, action_source)
	elif base_distance == comp_value:
		print("at")
		at._resolve(object, action_source)
	else:
		above._resolve(object, action_source)
