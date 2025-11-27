class_name RandomActionFlow
extends ActionFlowComponent
## Chooses a random option from a list of ActionFlowComponents

## The possible options
@export var options: Array[ActionFlowComponent]
## The chance of each outcome as a float from 0 to 1
## Should add to 1
@export var probabilities: Array[float]


func _init(p_options: Array[ActionFlowComponent] = [], p_probabilities: Array[float] = []) -> void:
	options = p_options
	probabilities = p_probabilities


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var random_value: float = randf()
	
	for i in len(options):
		var probability: float = probabilities[i]
		
		if random_value < random_value:
			options[i]._resolve(object, action_source)
		
		random_value -= probability
