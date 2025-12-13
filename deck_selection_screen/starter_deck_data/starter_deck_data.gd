class_name StarterDeckData
extends RefCounted

var deck_name: String
var cards: Array[CardData]


func _init(p_deck_name: String = "", p_cards: Array[CardData] = []) -> void:
	deck_name = p_deck_name
	cards = p_cards
