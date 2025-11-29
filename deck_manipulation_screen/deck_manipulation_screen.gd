class_name DeckManipulationScreen
extends Control

@export var slot_set: SlotSet

var world_map: WorldMap


func return_to_map() -> void:
	get_tree().root.add_child(world_map)
	queue_free()
