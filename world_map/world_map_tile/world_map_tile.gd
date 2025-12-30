class_name WorldMapTile
extends Node2D

enum EventType {
	NONE,
	ENTRANCE,
	EXIT,
	ENCOUNTER,
	MISSION,
	MERGE,
	ADD_SYMBOL,
	PLUS_RANGE,
	PLUS_EFFECT_SIZE,
	DESTROY_CARD,
	DRAFT,
	STAT_SWAP,
}

const POSITIVE_EVENT_UNLOCKS: Dictionary[EventType, int] = {
	EventType.MERGE: 0,
	EventType.ADD_SYMBOL: 0,
	EventType.PLUS_RANGE: 0,
	EventType.PLUS_EFFECT_SIZE: 0,
	EventType.DRAFT: 0,
	EventType.DESTROY_CARD: 1,
	EventType.STAT_SWAP: 1,
}

@export var bg: Sprite2D
@export var path: Sprite2D
@export var event_signs: Array[Sprite2D]

var pos: Vector2i
var world_map: WorldMap

var has_path: bool = false

var is_positive: bool = false
var event_type: EventType = EventType.NONE
var completed: bool = false:
	set(value):
		completed = value
		if world_map.generated:
			GameSaver.save_world_map(world_map)

@onready var path_atlas: AtlasTexture


func _ready() -> void:
	path.hide()
	for event_sign in event_signs:
		event_sign.hide()


func set_as_path() -> void:
	path.show()
	has_path = true
	
	update_path_sprite(true)


func update_path_sprite(update_neighbors: bool = false) -> void:
	if not path_atlas:
		path_atlas = path.texture
	
	var dir_has_path: Dictionary[Vector2i, bool] = {}
	for dir in Constants.DIRS:
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
			path_atlas.region.position.x = 0
		[false, true]:
			path_atlas.region.position.x = 32
		[true, true]:
			path_atlas.region.position.x = 64
		[true, false]:
			path_atlas.region.position.x = 96
	
	match [dir_has_path[Vector2i(0, -1)], dir_has_path[Vector2i(0, 1)]]:
		[false, false]:
			path_atlas.region.position.y = 0
		[false, true]:
			path_atlas.region.position.y = 32
		[true, true]:
			path_atlas.region.position.y = 64
		[true, false]:
			path_atlas.region.position.y = 96


func add_entrance() -> void:
	event_signs[EventType.ENTRANCE].show()
	is_positive = true
	event_type = EventType.ENTRANCE
	completed = true


func add_exit() -> void:
	event_signs[EventType.EXIT].show()
	is_positive = true
	event_type = EventType.EXIT
	completed = false


func add_encounter() -> void:
	if randf() < 0.8:
		event_type = EventType.ENCOUNTER
	else:
		event_type = EventType.MISSION
	
	#event_type = EventType.DESTROY_CARD
	event_signs[event_type].show()
	is_positive = false
	completed = false


func add_reward_event() -> void:
	var unlocked_events: Array[EventType] = []
	for event in POSITIVE_EVENT_UNLOCKS:
		if world_map.world_num >= POSITIVE_EVENT_UNLOCKS[event]:
			unlocked_events.append(event)
	
	event_type = unlocked_events.pick_random()
	event_signs[event_type].show()
	is_positive = true
	completed = false
