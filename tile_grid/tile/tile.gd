class_name Tile
extends Node2D

enum ActionMarker {
	ATTACK,
	POISON,
	MOVE,
	HEAL,
	ENEMY_ATTACK,
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
		
		var target_tile: Tile = tile_grid.get_tile(target.x, target.y)
		
		var marker_type: ActionMarker
		
		if effect.base_action is Modifier.Attack:
			marker_type = ActionMarker.ENEMY_ATTACK
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


func _targeted() -> void:
	become_untargetable()
	tile_grid.tile_targeted.emit(pos)


func add_object(data: TileObjectData) -> void:
	object = tile_object_scene.instantiate()
	
	object.health = data.max_health
	object.data = data
	object.tile_grid = tile_grid
	object.tile = self
	object.pos = pos
	
	add_child(object)


func delete_object() -> void:
	if object in tile_grid.round_manager.turn_order:
		tile_grid.round_manager.turn_order.erase(object)
	
	if object in tile_grid.round_manager.enemies:
		tile_grid.round_manager.enemies.erase(object)
		
		if len(tile_grid.round_manager.enemies) == 0:
			tile_grid.win()
	
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
