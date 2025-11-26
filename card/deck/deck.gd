class_name Deck
extends Control

var all_cards: Array[CardData] = [
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Heal.new()], 1, 1),
	CardData.new([Modifier.Heal.new()], 1, 1),
]

var remaining_cards: Array[CardData] = []
var used_cards: Array[CardData] = []


func _ready() -> void:
	for card in all_cards:
		remaining_cards.append(card)
	
	remaining_cards.shuffle()


func draw_card() -> CardData:
	if len(remaining_cards) == 0:
		if len(used_cards) == 0:
			return CardData.new([], 0, 0)
		
		for card in used_cards:
			remaining_cards.append(card)
		
		used_cards = []
		remaining_cards.shuffle()
	
	return remaining_cards.pop_back()


func discard(card: CardData) -> void:
	used_cards.append(card)
