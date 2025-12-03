class_name WorldMapTile
extends Node2D

enum EventType {
	ENTRANCE,
	EXIT,
	ENCOUNTER,
	MISSION,
	MERGE,
	ADD_SYMBOL,
	PLUS_RANGE,
	PLUS_EFFECT_SIZE,
	NONE,
}

const POSITIVE_EVENTS: Array[EventType] = [
	EventType.MERGE,
	EventType.ADD_SYMBOL,
	EventType.PLUS_RANGE,
	EventType.PLUS_EFFECT_SIZE,
]

@export var bg: Sprite2D
@export var path: Sprite2D
@export var event_signs: Array[Sprite2D]

var pos: Vector2i
var world_map: WorldMap

var has_path: bool = false

var is_positive: bool = false
var event_type: EventType = EventType.NONE
var completed: bool = false

var _path_atlas: AtlasTexture


func _ready() -> void:
	_path_atlas = path.texture
	
	path.hide()
	for event_sign in event_signs:
		event_sign.hide()


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
	event_signs[EventType.ENTRANCE].show()
	is_positive = true
	event_type = EventType.ENTRANCE
	completed = true


func add_exit() -> void:
	event_signs[EventType.EXIT].show()
	is_positive = true
	event_type = EventType.EXIT
	completed = true


func add_encounter() -> void:
	if randf() < 0.8:
		event_type = EventType.ENCOUNTER
	else:
		event_type = EventType.MISSION
	
	event_signs[event_type].show()
	is_positive = false
	completed = false


func add_reward_event() -> void:
	event_type = POSITIVE_EVENTS.pick_random()
	event_signs[event_type].show()
	is_positive = true
	completed = false
