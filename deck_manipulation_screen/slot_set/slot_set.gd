class_name SlotSet
extends Control

enum Type {
	MERGE,
	ADD_SYMBOL,
}

@export var hand: Hand
@export var deck_manipulation_screen: DeckManipulationScreen

@export var input_slots: Array[CardSlot]
@export var output_slot: CardSlot

@export var type: Type

var modifier: Modifier


func _ready() -> void:
	for slot in input_slots:
		slot.deck_manipulation_screen = deck_manipulation_screen
		slot.hand = hand
		slot.slot_set = self
	
	output_slot.deck_manipulation_screen = deck_manipulation_screen
	output_slot.hand = hand
	output_slot.slot_set = self
	
	if type == Type.ADD_SYMBOL:
		modifier = [
			Modifier.Attack.new(),
			Modifier.Heal.new(),
			Modifier.Move.new(),
			Modifier.Poison.new(),
		].pick_random()


func add_card(card: Card) -> void:
	for slot in input_slots:
		if not slot.card:
			slot.add_card(card)
			break
	
	for slot in input_slots:
		if not slot.card:
			if output_slot.card:
				output_slot.delete_card()
			
			return
	
	output_slot.create_card(calculate_output())


func calculate_output() -> CardData:
	match type:
		Type.MERGE:
			return calculate_output_merge()
		Type.ADD_SYMBOL:
			return calculate_output_add_symbol()
	
	return CardData.new([], 0, 0)


func calculate_output_merge() -> CardData:
	var result := CardData.new([], 0, 0)
	
	var input_data: Array[CardData] = [
		input_slots[0].card.card_data,
		input_slots[1].card.card_data,
	]
	
	if input_data[0].effect_size >= input_data[1].effect_size:
		result.effect_size = input_data[0].effect_size
	else:
		result.effect_size = input_data[1].effect_size
	
	if input_data[0].effect_range >= input_data[1].effect_range:
		result.effect_range = input_data[0].effect_range
	else:
		result.effect_range = input_data[1].effect_range
	
	for modifier in input_data[0].modifiers:
		result.modifiers.append(modifier)
	
	for modifier in input_data[1].modifiers:
		result.modifiers.append(modifier)
	
	return result


func calculate_output_add_symbol() -> CardData:
	var input_data: CardData = input_slots[0].card.card_data
	
	var result := CardData.new(input_data.modifiers.duplicate(), input_data.effect_range,
			input_data.effect_size)
	
	result.modifiers.append(modifier)
	
	return result
