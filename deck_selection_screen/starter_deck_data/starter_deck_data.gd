class_name StarterDeckData
extends RefCounted

var deck_name: String
var cards: Array[CardData]
var unlock_cond: UnlockCond


func _init(p_deck_name: String = "", p_cards: Array[CardData] = [],
		p_unlock_cond := UnlockCond.new()) -> void:
	deck_name = p_deck_name
	cards = p_cards
	unlock_cond = p_unlock_cond
