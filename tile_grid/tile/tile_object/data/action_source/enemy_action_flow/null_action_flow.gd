class_name NullActionFlow
extends ActionFlowComponent
## Does nothing


func _resolve(_object: TileObject, action_source: EnemyActionSource) -> void:
	action_source.next_action = CardData.new()
	action_source.next_action_targets = []
