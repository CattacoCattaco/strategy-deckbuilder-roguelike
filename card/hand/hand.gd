class_name Hand
extends HBoxContainer

signal card_played(card: CardData, targets: Array[Vector2i])

@export var card_scene: PackedScene

@export var tile_grid: TileGrid
@export var deck: Deck
@export var pass_button: TextureButton

@export var hand_size: int = 5

var cards: Array[Card]

var player: TileObject

var card_currently_playing: Card


func _ready() -> void:
	mouse_entered.connect(_hovered_over)
	mouse_exited.connect(_check_unhovered)
	
	pass_button.pressed.connect(_pass)
	
	for i in range(hand_size):
		draw_card()


func _hovered_over() -> void:
	var tween: Tween = create_tween()
	tween.tween_method(set_bottom_offset, get_bottom_offset(), 65, 0.5)


func _check_unhovered() -> void:
	if Rect2(Vector2.ZERO, size).has_point(get_local_mouse_position()):
		# Hovered over card, didn't actually leave
		return
	
	var tween: Tween = create_tween()
	tween.tween_method(set_bottom_offset, get_bottom_offset(), 120, 0.5)


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


func discard(card: Card) -> void:
	deck.discard(card.card_data)
	
	cards.erase(card)
	card.queue_free()
