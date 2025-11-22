@abstract
class_name ActionSource
extends Resource
## A resource which defines what actions an object can take

## Higher [param speed] = goes earlier in turn order[br][br]
## If [param speed] = -1, always acts at the start of round[br]
## If [param speed] = -2, always goes last
@export var speed: int = 0

## Should actions be shown in advance?
@export var preview_actions: bool = true

var next_action: Array[Modifier] = []


func _init(p_speed: int = 0, p_preview_actions: bool = true) -> void:
	speed = p_speed
	preview_actions = p_preview_actions


@abstract func generate_next_action() -> void
