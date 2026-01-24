class_name DeckView
extends Control

@export var card_scene: PackedScene

@export var card_holder: GridContainer
@export var focus_card_holder: ColorRect
@export var focus_card: Card

var full_deck: Array[CardData]
var source: Node


func _ready() -> void:
	focus_card_holder.hide()

	focus_card_holder.gui_input.connect(_focus_holder_gui_input)
	
	focus_card.deck_view = self


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("exit"):
		get_viewport().set_input_as_handled()
		queue_free()


func _focus_holder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unfocus_card()
			focus_card_holder.accept_event()


func focus(card_data: CardData) -> void:
	focus_card_holder.show()
	focus_card.card_data = card_data
	focus_card.load_data()


func unfocus_card() -> void:
	focus_card_holder.hide()


func show_deck() -> void:
	for card_data in full_deck:
		var card: Card = card_scene.instantiate()
		
		card.card_data = card_data
		card_holder.add_child(card)
		
		card.deck_view = self
