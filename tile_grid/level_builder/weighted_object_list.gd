class_name WeightedObjectList
extends Resource

@export var objects: Array[TileObjectData]
@export var weights: Array[int]


func _init(p_objects: Array[TileObjectData] = [], p_weights: Array[int] = []) -> void:
	objects = p_objects
	weights = p_weights


func get_random_object() -> TileObjectData:
	var total_weight: int = 0
	for weight in weights:
		total_weight += weight
	
	var probabilities: Array[float] = []
	for weight in weights:
		probabilities.append(weight as float / total_weight)
	
	var random_value: float = randf()
	
	for i in len(probabilities):
		var probability: float = probabilities[i]
		if random_value < probability:
			return objects[i]
		
		random_value -= probability
	
	return null
