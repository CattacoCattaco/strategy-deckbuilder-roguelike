class_name NullActionSource
extends ActionSource


func _init(p_speed: int = 0, p_preview_actions: bool = false) -> void:
	super(p_speed, p_preview_actions)


func generate_next_action(_object: TileObject) -> void:
	next_action = CardData.new([], 0, 0)
	next_action_targets = []
