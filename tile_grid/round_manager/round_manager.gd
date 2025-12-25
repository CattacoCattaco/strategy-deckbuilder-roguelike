class_name RoundManager
extends Node2D

@export var tile_grid: TileGrid

var is_player_turn: bool
var current_turn_index: int
var turn_order: Array[TileObject]


func start_rounds() -> void:
	is_player_turn = false
	turn_order = []
	EnemyActionSource.enemies = []
	
	for x in range(tile_grid.size.x):
		for y in range(tile_grid.size.y):
			var tile: Tile = tile_grid.get_tile(x, y)
			
			if not tile.object:
				continue
			
			if tile.object.data.object_type == TileObjectData.ObjectType.ENEMY:
				EnemyActionSource.enemies.append(tile.object)
			
			if tile.object.data.action_source is NullActionSource:
				continue
			
			turn_order.append(tile.object)
	
	turn_order.sort_custom(is_first)
	
	current_turn_index = 0
	
	for object in turn_order:
		var action_source: ActionSource = object.data.action_source
		
		if action_source.preview_actions:
			action_source._generate_next_action(object)
			object.display_action_thought_bubble(action_source.next_action)
	
	do_turn()


func do_turn() -> void:
	var current_object: TileObject = turn_order[current_turn_index]
	var action_source: ActionSource = current_object.data.action_source
	
	var from_player: bool = action_source is PlayerActionSource
	
	if action_source.preview_actions:
		var old_tile: Tile = current_object.tile
		var uninspected: bool = false
		
		if current_object.tile.inspected:
			old_tile._uninspect()
			uninspected = true
		
		var action: CardData = action_source.next_action
		var targets: Array[Vector2i] = action_source.next_action_targets
		await current_object.do_action(action, targets, from_player)
		
		action_source._generate_next_action(current_object)
		current_object.display_action_thought_bubble(action_source.next_action)
		
		if uninspected and current_object.tile == old_tile:
			old_tile._inspect()
	else:
		@warning_ignore("redundant_await")
		await action_source._generate_next_action(current_object)
		
		var action: CardData = action_source.next_action
		var targets: Array[Vector2i] = action_source.next_action_targets
		await current_object.do_action(action, targets, from_player)
	
	if current_object.poison_level > 0:
		current_object.do_poison()
		
		await get_tree().create_timer(0.8).timeout
	
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
