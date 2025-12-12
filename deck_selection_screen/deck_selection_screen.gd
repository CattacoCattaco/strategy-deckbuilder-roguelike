class_name DeckSelectionScreen
extends Control

static var DECKS: Dictionary[String, Array] = {
	"Basic Deck": [
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
	"Poison Deck": [
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
	"Shield Deck": [
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
	"Push Deck": [
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
	],
	"Swap Deck": [
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
	"Chaos Deck": [
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
	],
}

@export var world_map_scene: PackedScene
@export var deck_option_scene: PackedScene

@export var deck_options_container: HBoxContainer

var min_deck_options_x: int
var max_deck_options_x: int


func _ready() -> void:
	for deck_name in DECKS:
		var contents: Array[CardData] = []
		for card in DECKS[deck_name]:
			contents.append(card)
		
		_add_deck_option(contents, deck_name)
	
	await RenderingServer.frame_post_draw
	
	deck_options_container.position.y = (size.y - deck_options_container.size.y) / 2
	deck_options_container.position.x = (size.x - 160) / 2
	
	max_deck_options_x = floori(deck_options_container.position.x)
	min_deck_options_x = floori((size.x) / 2 - deck_options_container.size.x + 80)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			deck_options_container.position.x -= 4
			
			if deck_options_container.position.x < min_deck_options_x:
				deck_options_container.position.x = min_deck_options_x
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			deck_options_container.position.x += 4
			
			if deck_options_container.position.x > max_deck_options_x:
				deck_options_container.position.x = max_deck_options_x


func _add_deck_option(deck_contents: Array[CardData], deck_name: String) -> void:
	var deck_option: DeckOption = deck_option_scene.instantiate()
	
	deck_options_container.add_child(deck_option)
	
	deck_option.name_label.text = deck_name
	deck_option.select_button.pressed.connect(_choose_deck.bind(deck_contents))


func _choose_deck(deck: Array[CardData]) -> void:
	var world_map: WorldMap = world_map_scene.instantiate()
	world_map.player_deck = deck
	
	get_tree().root.add_child(world_map)
	queue_free()
