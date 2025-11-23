class_name Tile
extends Node2D

@export var tile_object_scene: PackedScene

@export var bg: Sprite2D

var object: TileObject

var pos: Vector2i


func add_object(data: TileObjectData) -> void:
	object = tile_object_scene.instantiate()
	add_child(object)
	object.data = data
