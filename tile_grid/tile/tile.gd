class_name Tile
extends Node2D

@export var tile_object_scene: PackedScene

@export var bg: Sprite2D

var tile_grid: TileGrid
var pos: Vector2i

var object: TileObject


func add_object(data: TileObjectData) -> void:
	object = tile_object_scene.instantiate()
	
	add_child(object)
	
	object.data = data
	object.tile_grid = tile_grid
	object.tile = self
	object.pos = pos
