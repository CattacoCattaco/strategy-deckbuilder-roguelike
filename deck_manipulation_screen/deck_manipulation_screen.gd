class_name DeckManipulationScreen
extends Control

@export var slot_sets: Array[SlotSet]

var world_map: WorldMap
var current_slot_set: SlotSet


func _ready() -> void:
	for slot_set in slot_sets:
		if slot_set != current_slot_set:
			slot_set.hide()
		else:
			slot_set.show()


func set_slot_set(type: SlotSet.Type) -> void:
	current_slot_set = slot_sets[type]


func return_to_map() -> void:
	get_tree().root.add_child(world_map)
	queue_free()
