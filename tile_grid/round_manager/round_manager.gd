class_name RoundManager
extends Node2D

@export var tile_grid: TileGrid

var is_player_turn: bool
var current_turn_index: int
var turn_order: Array[TileObject]


func start_rounds() -> void:
	is_player_turn = false
	turn_order = []
	
	for x in range(tile_grid.size.x):
		for y in range(tile_grid.size.y):
			var tile: Tile = tile_grid.get_tile(x, y)
			
			if not tile.object:
				continue
			
			if tile.object.data.action_source is NullActionSource:
				continue
			
			turn_order.append(tile.object)
	
	turn_order.sort_custom(is_first)
	
	current_turn_index = 0
	
	for object in turn_order:
		var action_source: ActionSource = object.data.action_source
		
		if action_source.preview_actions:
			action_source.generate_next_action(object)
			object.display_action_thought_bubble(action_source.next_action)
	
	do_turn()


func do_turn() -> void:
	var current_object: TileObject = turn_order[current_turn_index]
	var action_source: ActionSource = current_object.data.action_source
	
	if action_source.preview_actions:
		if current_object.tile.inspected:
			current_object.tile._uninspect()
			current_object.tile.inspected = true
		
		await current_object.do_action(action_source.next_action, action_source.next_action_targets)
		action_source.generate_next_action(current_object)
		current_object.display_action_thought_bubble(action_source.next_action)
	else:
		@warning_ignore("redundant_await")
		await action_source.generate_next_action(current_object)
		await current_object.do_action(action_source.next_action, action_source.next_action_targets)
	
	current_turn_index += 1
	
	if current_turn_index >= len(turn_order):
		current_turn_index = 0
		await get_tree().create_timer(0.8).timeout
	
	do_turn()


func is_first(a: TileObject, b: TileObject) -> bool:
	if a.data.action_source.speed == -1:
		return true
	elif b.data.action_source.speed == -1:
		return false
	
	return a.data.action_source.speed > b.data.action_source.speed
