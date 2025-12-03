class_name DeckView
extends Control

@export var card_scene: PackedScene

@export var card_holder: GridContainer

var world_map: WorldMap


func show_deck() -> void:
	for card_data in world_map.player_deck:
		var card: Card = card_scene.instantiate()
		
		card.card_data = card_data
		card_holder.add_child(card)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("exit"):
			queue_free()
