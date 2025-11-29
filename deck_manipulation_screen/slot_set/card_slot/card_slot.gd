class_name CardSlot
extends Control

@export var input: bool = true

@export var card_scene: PackedScene

@export var empty_sprite: Sprite2D
@export var full_sprite: Sprite2D

var deck_manipulation_screen: DeckManipulationScreen
var slot_set: SlotSet
var hand: Hand

var card: Card


func _ready() -> void:
	full_sprite.hide()


func add_card(new_card: Card) -> void:
	card = new_card
	
	card.reparent(self)
	card.position = Vector2(6, 6)
	
	hand.cards.erase(card)
	hand.update_gap_size()


func remove_card() -> void:
	card.reparent(hand)
	
	hand.cards.append(card)
	hand.update_gap_size()
	
	card = null


func create_card(data: CardData) -> void:
	card = card_scene.instantiate()
	
	card.hand = hand
	card.card_data = data
	
	add_child(card)
	card.position = Vector2(6, 6)


func delete_card() -> void:
	card.queue_free()


func take_card() -> void:
	var deck: Array[CardData] = deck_manipulation_screen.world_map.player_deck
	for input_slot in slot_set.input_slots:
		deck.erase(input_slot.card.card_data)
	
	deck.append(card.card_data)
	
	deck_manipulation_screen.return_to_map()
