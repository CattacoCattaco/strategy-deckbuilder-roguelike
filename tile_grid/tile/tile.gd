class_name Tile
extends Node2D

enum ActionMarker {
	PUSH,
	SWAP,
	ATTACK,
	DEFEND,
	POISON,
	MOVE,
	HEAL,
	ENEMY_PUSH,
	ENEMY_SWAP,
	ENEMY_ATTACK,
	ENEMY_DEFEND,
	ENEMY_POISON,
	ENEMY_MOVE,
	ENEMY_HEAL,
}

@export var tile_object_scene: PackedScene

@export var bg: Sprite2D
@export var action_markers: Array[Sprite2D]
@export var inspect_button: Button
@export var target_button: Button

var tile_grid: TileGrid
var pos: Vector2i
var inspected: bool = false
var inspect_marks: Dictionary[Tile, Array]

var object: TileObject


func _ready() -> void:
	for i in len(action_markers):
		hide_action_marker(i)
	
	inspect_button.mouse_entered.connect(_inspect)
	inspect_button.mouse_exited.connect(_uninspect)
	inspect_button.pressed.connect(_show_card)
	
	target_button.mouse_entered.connect(_inspect)
	target_button.mouse_exited.connect(_uninspect)
	target_button.hide()
	target_button.pressed.connect(_targeted)


func _inspect() -> void:
	if not object:
		return
	
	var action_source: ActionSource = object.data.action_source
	
	if not action_source.preview_actions:
		return
	
	inspect_marks = {}
	
	inspected = true
	
	var effects: Array[Effect] = action_source.next_action.get_effects()
	for i in len(effects):
		var effect: Effect = effects[i]
		var target: Vector2i = action_source.next_action_targets[i]
		
		if not tile_grid.has_tile(target.x, target.y):
			continue
		
		var target_tile: Tile = tile_grid.get_tile(target.x, target.y)
		
		var marker_type: ActionMarker
		
		if effect.base_action is Modifier.Push:
			marker_type = ActionMarker.ENEMY_PUSH
		elif effect.base_action is Modifier.Swap:
			marker_type = ActionMarker.ENEMY_SWAP
		elif effect.base_action is Modifier.Attack:
			marker_type = ActionMarker.ENEMY_ATTACK
		elif effect.base_action is Modifier.Defend:
			marker_type = ActionMarker.ENEMY_DEFEND
		elif effect.base_action is Modifier.Poison:
			marker_type = ActionMarker.ENEMY_POISON
		elif effect.base_action is Modifier.Move:
			marker_type = ActionMarker.ENEMY_MOVE
		elif effect.base_action is Modifier.Heal:
			marker_type = ActionMarker.ENEMY_HEAL
		
		target_tile.show_action_marker(marker_type)
		
		if target_tile in inspect_marks:
			inspect_marks[target_tile].append(marker_type)
		else:
			inspect_marks[target_tile] = [marker_type]


func _uninspect() -> void:
	if not inspected:
		return
	
	for tile in inspect_marks:
		for marker: ActionMarker in inspect_marks[tile]:
			tile.hide_action_marker(marker)


func _show_card() -> void:
	if not object:
		return
	
	tile_grid.focus(object.data.action_source.next_action)


func _targeted() -> void:
	become_untargetable()
	tile_grid.tile_targeted.emit(pos)


func get_distance(other: Vector2i, can_jump: bool) -> int:
	if can_jump:
		return absi(pos.x - other.x) + absi(pos.y - other.y)
	
	if pos == other:
		return 0
	
	var prev_gen: Array[Vector2i] = [pos]
	var checked: Array[Vector2i] = [pos]
	
	var distance: int = 0
	
	while len(prev_gen) > 0:
		distance += 1
		
		var new_gen: Array[Vector2i] = []
		
		for old_pos in prev_gen:
			for dir in Constants.DIRS:
				var neighbor: Vector2i = old_pos + dir
				
				if neighbor == other:
					return distance
				
				if (not tile_grid.has_tile(neighbor.x, neighbor.y)) or neighbor in checked:
					continue
				
				checked.append(neighbor)
				
				var neighbor_tile: Tile = tile_grid.get_tile(neighbor.x, neighbor.y)
				
				if neighbor_tile.object:
					continue
				
				new_gen.append(neighbor)
		
		prev_gen = new_gen
	
	return -1


func add_object(data: TileObjectData) -> void:
	object = tile_object_scene.instantiate()
	
	object.health = data.max_health
	object.data = data
	object.tile_grid = tile_grid
	object.tile = self
	object.pos = pos
	
	add_child(object)


func delete_object() -> void:
	if not object:
		return
	
	if object in tile_grid.round_manager.turn_order:
		tile_grid.round_manager.turn_order.erase(object)
	
	if object in EnemyActionSource.enemies:
		EnemyActionSource.enemies.erase(object)
		
		if len(EnemyActionSource.enemies) == 0:
			tile_grid.win()
	
	if object in EnemyActionSource.defendables:
		EnemyActionSource.defendables.erase(object)
		tile_grid.lose()
	
	if object == tile_grid.hand.player:
		tile_grid.hand.player = null
		tile_grid.lose()
	
	object.queue_free()
	object = null


func show_action_marker(marker: ActionMarker) -> void:
	action_markers[marker].show()


func hide_action_marker(marker: ActionMarker) -> void:
	action_markers[marker].hide()


func become_targetable() -> void:
	target_button.show()


func become_untargetable() -> void:
	target_button.hide()
