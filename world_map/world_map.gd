class_name WorldMap
extends Node2D

@export var tile_scene: PackedScene

@export var player: Sprite2D
@export var camera: DraggableCamera

@export var used_size: int = 7

@export var camera_padding := Vector2i(64, 64)

@onready var board_length: int = used_size * 2 + 1

var tiles: Array[Array]

var player_pos: Vector2i


func _ready() -> void:
	var pixel_size := Vector2(board_length * 32, board_length * 32)
	var offset := -Vector2(pixel_size) / 2
	
	for x in range(board_length):
		var column: Array[WorldMapTile] = []
		
		for y in range(board_length):
			var tile: WorldMapTile = tile_scene.instantiate()
			
			tile.world_map = self
			
			column.append(tile)
			add_child(tile)
			
			tile.pos = Vector2i(x, y)
			tile.position = Vector2(32 * x, 32 * y) + offset
		
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
			print(backtrackable_path)
			
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


func try_move_player_in_dir(dir: Vector2i) -> void:
	var neighbor_pos: Vector2i = player_pos + dir
	
	if not has_tile_at_vec(neighbor_pos):
		return
	
	var tile: WorldMapTile = get_tile_from_vec(neighbor_pos)
	if not tile.has_path:
		return
	
	player_pos = neighbor_pos
	player.position = tile.position


func try_do_event() -> void:
	var tile: WorldMapTile = get_tile_from_vec(player_pos)


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
