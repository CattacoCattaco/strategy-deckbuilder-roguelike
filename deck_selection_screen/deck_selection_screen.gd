class_name DeckSelectionScreen
extends Control

## All available starter decks
static var DECKS: Array[StarterDeckData] = [
	StarterDeckData.new("Basic Deck", [
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
	]),
	StarterDeckData.new("Poison Deck", [
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Poison.new()], 1, 1),
	]),
	StarterDeckData.new("Shield Deck", [
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Defend.new()], 1, 1),
		CardData.new([Modifier.Defend.new()], 1, 1),
		CardData.new([Modifier.Defend.new()], 1, 1),
		CardData.new([Modifier.Defend.new()], 1, 1),
	]),
	StarterDeckData.new("Push Deck", [
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
		CardData.new([Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
	]),
	StarterDeckData.new("Swap Deck", [
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
		CardData.new([Modifier.Swap.new()], 1, 1),
	]),
	StarterDeckData.new("Chaos Deck", [
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new(), Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Move.new(), Modifier.Attack.new(), Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Move.new(), Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 5, 1),
		CardData.new([Modifier.Attack.new(), Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Attack.new(), Modifier.Poison.new()], 1, 2),
		CardData.new([Modifier.Attack.new(), Modifier.Poison.new()], 2, 1),
		CardData.new([Modifier.Attack.new(), Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Attack.new()], 1, 1),
		CardData.new([Modifier.Heal.new(), Modifier.Poison.new()], 1, 1),
		CardData.new([Modifier.Heal.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 2, 3),
		CardData.new([Modifier.Push.new()], 1, 1),
	]),
]

@export var world_map_scene: PackedScene

@export var deck_name_label: Label
@export var select_button: Button
@export var previous_button: Button
@export var next_button: Button

var current_deck_index: int = 0


func _ready() -> void:
	previous_button.disabled = true
	previous_button.pressed.connect(_previous_deck)
	next_button.pressed.connect(_next_deck)
	_update_current_deck()


func _previous_deck() -> void:
	current_deck_index -= 1
	
	if current_deck_index == 0:
		previous_button.disabled = true
	
	next_button.disabled = false
	
	_update_current_deck()


func _next_deck() -> void:
	current_deck_index += 1
	
	if current_deck_index == len(DECKS) - 1:
		next_button.disabled = true
	
	previous_button.disabled = false
	
	_update_current_deck()


func _update_current_deck() -> void:
	var deck: StarterDeckData = DECKS[current_deck_index]
	deck_name_label.text = deck.deck_name
	select_button.pressed.connect(_choose_deck.bind(deck.cards))


func _choose_deck() -> void:
	var deck: StarterDeckData = DECKS[current_deck_index]
	
	var world_map: WorldMap = world_map_scene.instantiate()
	world_map.player_deck = deck.cards.duplicate(true)
	
	get_tree().root.add_child(world_map)
	queue_free()
