class_name Deck
extends Control

@export var tile_grid: TileGrid

@export var deck_manipulation_screen: DeckManipulationScreen

var remaining_cards: Array[CardData] = []
var used_cards: Array[CardData] = []


func _ready() -> void:
	var starting_deck: Array[CardData]
	if tile_grid:
		starting_deck = tile_grid.world_map.player_deck
	elif deck_manipulation_screen:
		starting_deck = deck_manipulation_screen.world_map.player_deck
	
	for card in starting_deck:
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
