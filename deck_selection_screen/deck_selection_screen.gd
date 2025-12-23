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
	],
	UnlockCond.new()),
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
	],
	UnlockCond.new(StatsManager.Stat.HIGHEST_POISON_LEVEL, 5, "Get an enemy to have 5 poison.")),
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
	],
	UnlockCond.new(StatsManager.Stat.TOTAL_DAMAGE_BLOCKED, 50, "Block 50 damage.")),
	StarterDeckData.new("Push Deck", [
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Move.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
		CardData.new([Modifier.Push.new()], 1, 1),
	],
	UnlockCond.new(StatsManager.Stat.TOTAL_PUSH_DAMAGE, 10, "Deal 10 push damage.")),
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
	],
	UnlockCond.new(StatsManager.Stat.SWAP_COUNT, 20, "Swap 20 times.")),
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
		CardData.new([Modifier.Swap.new()], 1, 6),
		CardData.new([Modifier.Defend.new()], 3, 1),
		CardData.new([Modifier.Defend.new(), Modifier.Swap.new(), Modifier.Push.new()], 1, 1),
	],
	UnlockCond.new(StatsManager.Stat.TOTAL_DAMAGE_CAUSED, 500, "Deal 500 damage.")),
]

@export var deck_view_scene: PackedScene
@export var world_map_scene: PackedScene

@export var deck_name_label: Label
@export var locked_label: Label
@export var unlock_cond_label: Label
@export var preview_button: Button
@export var select_button: Button
@export var previous_button: Button
@export var next_button: Button

var current_deck_index: int = 0


func _ready() -> void:
	_update_current_deck()
	
	previous_button.disabled = true
	
	previous_button.pressed.connect(_previous_deck)
	preview_button.pressed.connect(_preview_deck)
	next_button.pressed.connect(_next_deck)
	select_button.pressed.connect(_choose_deck)


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


func _preview_deck() -> void:
	var deck_view: DeckView = deck_view_scene.instantiate()
	add_child(deck_view)
	deck_view.set_anchors_preset(Control.PRESET_CENTER)
	deck_view.full_deck = DECKS[current_deck_index].cards
	deck_view.show_deck()


func _choose_deck() -> void:
	var deck: StarterDeckData = DECKS[current_deck_index]
	
	var world_map: WorldMap = world_map_scene.instantiate()
	world_map.player_deck = deck.cards.duplicate(true)
	
	get_tree().root.add_child(world_map)
	queue_free()


func _update_current_deck() -> void:
	var deck: StarterDeckData = DECKS[current_deck_index]
	deck_name_label.text = deck.deck_name
	
	var unlock_cond: UnlockCond = deck.unlock_cond
	
	if unlock_cond.is_complete():
		locked_label.hide()
		unlock_cond_label.hide()
		preview_button.show()
		select_button.show()
	else:
		locked_label.show()
		unlock_cond_label.show()
		preview_button.hide()
		select_button.hide()
		
		unlock_cond_label.text = unlock_cond.get_text()
