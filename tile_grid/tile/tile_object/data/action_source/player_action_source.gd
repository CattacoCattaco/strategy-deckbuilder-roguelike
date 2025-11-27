class_name PlayerActionSource
extends ActionSource

signal got_action()

var round_manager: RoundManager


func _init(p_speed: int = 0, p_preview_actions: bool = false) -> void:
	super(p_speed, p_preview_actions)


func _generate_next_action(object: TileObject) -> void:
	object.tile_grid.show_your_turn()
	object.tile_grid.hand.card_played.connect(_card_played)
	round_manager = object.tile_grid.round_manager
	round_manager.is_player_turn = true
	await got_action
	object.tile_grid.hand.card_played.disconnect(_card_played)


func _card_played(card: CardData, targets: Array[Vector2i]) -> void:
	next_action = card
	next_action_targets = targets
	round_manager.is_player_turn = false
	got_action.emit()
