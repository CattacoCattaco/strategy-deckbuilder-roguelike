class_name WorldMapTile
extends Node2D

@export var bg: Sprite2D
@export var path: Sprite2D
@export var entrance_sign: Sprite2D
@export var exit_sign: Sprite2D
@export var encounter_sign: Sprite2D
@export var merge_sign: Sprite2D

var pos: Vector2i
var world_map: WorldMap

var has_path: bool = false
var has_event: bool = false
var _path_atlas: AtlasTexture


func _ready() -> void:
	_path_atlas = path.texture
	
	path.hide()
	entrance_sign.hide()
	exit_sign.hide()
	encounter_sign.hide()
	merge_sign.hide()


func set_as_path() -> void:
	path.show()
	has_path = true
	
	update_path_sprite(true)


func update_path_sprite(update_neighbors: bool = false) -> void:
	var dir_has_path: Dictionary[Vector2i, bool] = {}
	for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
		var neighbor_pos: Vector2i = pos + dir
		
		if not world_map.has_tile_at_vec(neighbor_pos):
			dir_has_path[dir] = false
			continue
		
		var neighbor_tile: WorldMapTile = world_map.get_tile_from_vec(neighbor_pos)
		
		if not neighbor_tile.has_path:
			dir_has_path[dir] = false
			continue
		
		dir_has_path[dir] = true
		
		if update_neighbors:
			neighbor_tile.update_path_sprite()
	
	match [dir_has_path[Vector2i(-1, 0)], dir_has_path[Vector2i(1, 0)]]:
		[false, false]:
			_path_atlas.region.position.x = 0
		[false, true]:
			_path_atlas.region.position.x = 32
		[true, true]:
			_path_atlas.region.position.x = 64
		[true, false]:
			_path_atlas.region.position.x = 96
	
	match [dir_has_path[Vector2i(0, -1)], dir_has_path[Vector2i(0, 1)]]:
		[false, false]:
			_path_atlas.region.position.y = 0
		[false, true]:
			_path_atlas.region.position.y = 32
		[true, true]:
			_path_atlas.region.position.y = 64
		[true, false]:
			_path_atlas.region.position.y = 96


func add_entrance() -> void:
	entrance_sign.show()
	has_event = true


func add_exit() -> void:
	exit_sign.show()
	has_event = true


func add_encounter() -> void:
	encounter_sign.show()
	has_event = true


func add_positive_event() -> void:
	merge_sign.show()
	has_event = true
