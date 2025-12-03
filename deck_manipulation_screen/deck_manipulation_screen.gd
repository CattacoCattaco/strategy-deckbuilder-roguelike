class_name DeckManipulationScreen
extends Control

@export var deck_view_scene: PackedScene

@export var slot_sets: Array[SlotSet]
@export var hand: Hand
@export var focus_card_holder: ColorRect
@export var focus_card: Card

var world_map: WorldMap
var current_slot_set: SlotSet


func _ready() -> void:
	focus_card_holder.hide()

	focus_card_holder.gui_input.connect(_focus_holder_gui_input)
	
	focus_card.hand = hand
	
	for slot_set in slot_sets:
		if slot_set != current_slot_set:
			slot_set.hide()
		else:
			slot_set.show()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("view_deck"):
			var deck_view: DeckView = deck_view_scene.instantiate()
			add_child(deck_view)
			deck_view.set_anchors_preset(Control.PRESET_CENTER)
			deck_view.world_map = world_map
			deck_view.show_deck()


func _focus_holder_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			unfocus_card()


func focus(card_data: CardData) -> void:
	focus_card_holder.show()
	focus_card.card_data = card_data
	focus_card.load_data()


func unfocus_card() -> void:
	focus_card_holder.hide()


func set_slot_set(type: SlotSet.Type) -> void:
	current_slot_set = slot_sets[type]


func return_to_map() -> void:
	get_tree().root.add_child(world_map)
	queue_free()
