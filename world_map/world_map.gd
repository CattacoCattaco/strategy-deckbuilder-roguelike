class_name WorldMap
extends Node2D

@export var tile_scene: PackedScene
@export var level_scene: PackedScene
@export var deck_manipulation_scene: PackedScene

@export var player: Sprite2D
@export var camera: DraggableCamera

@export var used_size: int = 7

@export var camera_padding := Vector2i(64, 64)

@onready var board_length: int = used_size * 2 + 1

var tiles: Array[Array]

var player_pos: Vector2i

var world_num: int = 0
var levels_beat: int = 0

var player_deck: Array[CardData] = [
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Move.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Attack.new()], 1, 1),
	CardData.new([Modifier.Heal.new()], 1, 1),
	CardData.new([Modifier.Heal.new()], 1, 1),
]


func _ready() -> void:
	generate_map()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("up"):
			try_move_player_in_dir(Vector2i(0, -1))
		elif event.is_action_pressed("left"):
			try_move_player_in_dir(Vector2i(-1, 0))
		elif event.is_action_pressed("down"):
			try_move_player_in_dir(Vector2i(0, 1))
		elif event.is_action_pressed("right"):
			try_move_player_in_dir(Vector2i(1, 0))
		elif event.is_action_pressed("do_event"):
			try_do_event()
		elif event.is_action_pressed("zoom"):
			if scale == Vector2(1, 1):
				camera.position *= 2
				# Set camera scale to reciprocal of self scale so UI doesn't get scaled
				camera.scale = Vector2(0.5, 0.5)
				scale = Vector2(2, 2)
			else:
				camera.position /= 2
				camera.scale = Vector2(1, 1)
				scale = Vector2(1, 1)


func generate_map() -> void:
	for column in tiles:
		for tile: WorldMapTile in column:
			tile.queue_free()
	
	tiles = []
	
	var pixel_size := Vector2(board_length * 32, board_length * 32)
	var offset := -Vector2(pixel_size) / 2
	
	for x in range(board_length):
		var column: Array[WorldMapTile] = []
		
		for y in range(board_length):
			var placed_tile: WorldMapTile = tile_scene.instantiate()
			
			placed_tile.world_map = self
			
			column.append(placed_tile)
			add_child(placed_tile)
			
			placed_tile.pos = Vector2i(x, y)
			placed_tile.position = Vector2(32 * x, 32 * y) + offset
		
		tiles.append(column)
	
	var pos := Vector2i(1, board_length - 2)
	var tile: WorldMapTile = get_tile_from_vec(pos)
	tile.set_as_path()
	tile.add_entrance()
	
	player_pos = pos
	player.position = tile.position
	
	var desired_end := Vector2i(board_length - 2, 1)
	
	# If true, the next event should be a challenge
	# If false, the next event should be a reward
	var is_challenge: bool = true
	
	var backtrackable_path: Array[Vector2i] = [pos]
	
	while len(backtrackable_path) > 0:
		var valid_dirs: Array[Vector2i] = []
		
		for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
			if not has_tile_at_vec(pos + (dir * 2)):
				continue
			
			if get_tile_from_vec(pos + (dir * 2)).has_path:
				continue
			
			valid_dirs.append(dir)
		
		if len(valid_dirs) == 0:
			backtrackable_path.pop_back()
			
			if len(backtrackable_path) == 0:
				break
			
			pos = backtrackable_path[len(backtrackable_path) - 1]
			
			tile = get_tile_from_vec(pos)
			
			is_challenge = tile.is_positive
			
			continue
		
		var dir: Vector2i = valid_dirs.pick_random()
		
		for j in range(2):
			pos += dir
			get_tile_from_vec(pos).set_as_path()
		
		backtrackable_path.append(pos)
		
		tile = get_tile_from_vec(pos)
		
		if randf() < 0.2:
			is_challenge = not is_challenge
		
		if pos == desired_end:
			tile.add_exit()
			is_challenge = true
		elif is_challenge:
			tile.add_encounter()
			is_challenge = false
		else:
			tile.add_reward_event()
			is_challenge = true


func try_move_player_in_dir(dir: Vector2i) -> void:
	var current_tile: WorldMapTile = get_tile_from_vec(player_pos)
	
	var neighbor_pos: Vector2i = player_pos + dir
	
	if not has_tile_at_vec(neighbor_pos):
		return
	
	var neighbor_tile: WorldMapTile = get_tile_from_vec(neighbor_pos)
	if not neighbor_tile.has_path:
		return
	
	if not current_tile.completed:
		if current_tile.event_type != WorldMapTile.EventType.NONE:
			var going_to: Vector2i = player_pos + 2 * dir
			var going_to_tile: WorldMapTile = get_tile_from_vec(going_to)
			if not going_to_tile.completed:
				return
	
	player_pos = neighbor_pos
	player.position = neighbor_tile.position


func try_do_event() -> void:
	var tile: WorldMapTile = get_tile_from_vec(player_pos)
	
	match tile.event_type:
		WorldMapTile.EventType.ENTRANCE:
			# There is nothing to do at an entrance
			pass
		WorldMapTile.EventType.EXIT:
			world_num += 1
			generate_map()
		WorldMapTile.EventType.ENCOUNTER:
			if not tile.completed:
				var level: TileGrid = level_scene.instantiate()
				level.world_map = self
				
				get_tree().root.add_child(level)
				get_tree().root.remove_child(self)
		WorldMapTile.EventType.MISSION:
			if not tile.completed:
				var level: TileGrid = level_scene.instantiate()
				level.world_map = self
				level.is_mission = true
				
				get_tree().root.add_child(level)
				get_tree().root.remove_child(self)
		WorldMapTile.EventType.MERGE:
			if not tile.completed:
				var deck_manipulation_screen: DeckManipulationScreen 
				deck_manipulation_screen = deck_manipulation_scene.instantiate()
				
				deck_manipulation_screen.set_slot_set(SlotSet.Type.MERGE)
				deck_manipulation_screen.world_map = self
				
				get_tree().root.add_child(deck_manipulation_screen)
				get_tree().root.remove_child(self)
		WorldMapTile.EventType.ADD_SYMBOL:
			if not tile.completed:
				var deck_manipulation_screen: DeckManipulationScreen 
				deck_manipulation_screen = deck_manipulation_scene.instantiate()
				
				deck_manipulation_screen.set_slot_set(SlotSet.Type.ADD_SYMBOL)
				deck_manipulation_screen.world_map = self
				
				get_tree().root.add_child(deck_manipulation_screen)
				get_tree().root.remove_child(self)
		WorldMapTile.EventType.PLUS_RANGE:
			if not tile.completed:
				var deck_manipulation_screen: DeckManipulationScreen 
				deck_manipulation_screen = deck_manipulation_scene.instantiate()
				
				deck_manipulation_screen.set_slot_set(SlotSet.Type.PLUS_RANGE)
				deck_manipulation_screen.world_map = self
				
				get_tree().root.add_child(deck_manipulation_screen)
				get_tree().root.remove_child(self)
		WorldMapTile.EventType.PLUS_EFFECT_SIZE:
			if not tile.completed:
				var deck_manipulation_screen: DeckManipulationScreen 
				deck_manipulation_screen = deck_manipulation_scene.instantiate()
				
				deck_manipulation_screen.set_slot_set(SlotSet.Type.PLUS_EFFECT_SIZE)
				deck_manipulation_screen.world_map = self
				
				get_tree().root.add_child(deck_manipulation_screen)
				get_tree().root.remove_child(self)
	
	tile.completed = true


func has_tile_at_vec(pos: Vector2i) -> bool:
	return has_tile(pos.x, pos.y)


func has_tile(x: int, y: int) -> bool:
	return x < board_length and y < board_length and x >= 0 and y >= 0


func get_tile_from_vec(pos: Vector2i) -> WorldMapTile:
	return get_tile(pos.x, pos.y)


func get_tile(x: int, y: int) -> WorldMapTile:
	return tiles[x][y]


func get_camera_bounds() -> Rect2:
	var bottom_right_coord: int = board_length * 16
	var top_left_coord: int = -bottom_right_coord
	
	var bounds := Rect2()
	bounds.position = top_left_coord * scale - Vector2(camera_padding)
	bounds.size = Vector2(board_length * 32 * Vector2i(scale) + camera_padding * 2)
	
	return bounds
