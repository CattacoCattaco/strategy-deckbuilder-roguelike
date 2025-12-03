class_name Hand
extends HBoxContainer

signal card_played(card: CardData, targets: Array[Vector2i])

@export var card_scene: PackedScene

@export var deck: Deck

@export var tile_grid: TileGrid
@export var pass_button: TextureButton

@export var deck_manipulation_screen: DeckManipulationScreen

@export var hand_size: int = 5

var cards: Array[Card]

var player: TileObject
var card_currently_playing: Card

var zoom_tween: Tween
var hovering: bool = false
var unhovering: bool = false


func _ready() -> void:
	mouse_entered.connect(_hovered_over)
	mouse_exited.connect(_check_unhovered)
	
	if tile_grid:
		pass_button.pressed.connect(_pass)
	
	for i in range(hand_size):
		draw_card()


func _hovered_over() -> void:
	if hovering:
		return
	
	if tile_grid:
		if zoom_tween:
			zoom_tween.stop()
			unhovering = false
		
		hovering = true
		
		zoom_tween = create_tween()
		zoom_tween.tween_method(set_bottom_offset, get_bottom_offset(), 65, 0.5)
		zoom_tween.tween_callback(set_not_hovering)


func _check_unhovered() -> void:
	if unhovering:
		return
	
	if Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
		# Hovered over card, didn't actually leave
		return
	
	if tile_grid:
		if zoom_tween:
			zoom_tween.stop()
			hovering = false
		
		unhovering = true
		
		zoom_tween = create_tween()
		zoom_tween.tween_method(set_bottom_offset, get_bottom_offset(), 120, 0.5)
		zoom_tween.tween_callback(set_not_unhovering)


func set_not_hovering() -> void:
	hovering = true


func set_not_unhovering() -> void:
	unhovering = false


func _pass() -> void:
	if not tile_grid.round_manager.is_player_turn:
		return
	
	if card_currently_playing:
		stop_playing_card()
	
	draw_card()
	
	var no_targets: Array[Vector2i] = []
	card_played.emit(CardData.new([], 0, 0), no_targets)


func stop_playing_card() -> void:
	card_currently_playing.cancelled = true
	
	while card_currently_playing and card_currently_playing.needs_targets:
		tile_grid.tile_targeted.emit(Vector2i(0, 0))


func set_bottom_offset(offset: int) -> void:
	set_offset(SIDE_BOTTOM, offset)


func get_bottom_offset() -> int:
	return roundi(get_offset(SIDE_BOTTOM))


func draw_card() -> void:
	var card: Card = card_scene.instantiate()
	
	card.hand = self
	card.card_data = deck.draw_card()
	
	cards.append(card)
	add_child(card)
	
	update_gap_size()


func discard(card: Card) -> void:
	deck.discard(card.card_data)
	
	cards.erase(card)
	card.queue_free()
	
	update_gap_size()


func update_gap_size() -> void:
	var card_width: int = len(cards) * 107
	var desired_width: int = roundi(custom_minimum_size.x)
	var gap_size: int = floori((desired_width - card_width) as float / (len(cards) - 1) / 2) * 2
	if gap_size > 4:
		gap_size = 4
	
	add_theme_constant_override("separation", gap_size)
