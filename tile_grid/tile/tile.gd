class_name Tile
extends Node2D

enum ActionMarker {
	ATTACK,
	POISON,
	MOVE,
	HEAL,
}

@export var tile_object_scene: PackedScene

@export var bg: Sprite2D
@export var action_markers: Array[Sprite2D]
@export var target_button: Button

var tile_grid: TileGrid
var pos: Vector2i

var object: TileObject


func _ready() -> void:
	for i in len(action_markers):
		hide_action_marker(i)
	
	target_button.hide()
	target_button.pressed.connect(_targeted)


func add_object(data: TileObjectData) -> void:
	object = tile_object_scene.instantiate()
	
	add_child(object)
	
	object.data = data
	object.tile_grid = tile_grid
	object.tile = self
	object.pos = pos
	object.health = data.max_health


func delete_object() -> void:
	if object in tile_grid.round_manager.turn_order:
		tile_grid.round_manager.turn_order.erase(object)
	
	if object == tile_grid.hand.player:
		tile_grid.hand.player = null
	
	object.queue_free()
	object = null


func _targeted() -> void:
	become_untargetable()
	tile_grid.tile_targeted.emit(pos)


func show_action_marker(marker: ActionMarker) -> void:
	action_markers[marker].show()


func hide_action_marker(marker: ActionMarker) -> void:
	action_markers[marker].hide()


func become_targetable() -> void:
	target_button.show()


func become_untargetable() -> void:
	target_button.hide()
