extends Node

const SAVE_PATH: String = "user://%s.json"


func save_stats() -> void:
	var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.WRITE)
	file.store_string(JSON.stringify(StatsManager.values, "\t"))
	file.close()


func load_stats() -> bool:
	if FileAccess.file_exists(SAVE_PATH % "stats"):
		return false
	
	var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data is not Array:
		return false
	
	for stat in len(data):
		if stat >= StatsManager.Stat.STAT_COUNT:
			return false
		
		StatsManager.values.append(roundi(data[stat]))
	
	return true


func save_world_map(world_map: WorldMap) -> void:
	var data: Dictionary = {
		"player_x": world_map.player_pos.x,
		"player_y": world_map.player_pos.y,
		"world_num": world_map.world_num,
		"levels_beat": world_map.levels_beat,
	}
	
	var tile_states: Array = []
	for column: Array in world_map.tiles:
		var state_column: Array = []
		for tile: WorldMapTile in column:
			var state: Dictionary = {
				"pos_x": tile.pos.x,
				"pos_y": tile.pos.y,
				"has_path": tile.has_path,
				"is_positive": tile.is_positive,
				"event_type": tile.event_type,
				"completed": tile.completed,
			}
			state_column.append(state)
		
		tile_states.append(state_column)
	
	data["tile_states"] = tile_states
	
	var player_deck: Array = []
	
	for card in world_map.player_deck:
		player_deck.append(card.jsonify())
	
	data["player_deck"] = player_deck
	
	var file := FileAccess.open(SAVE_PATH % "world", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func load_world_map(world_map: WorldMap) -> bool:
	if not FileAccess.file_exists(SAVE_PATH % "world"):
		return false
	
	var file := FileAccess.open(SAVE_PATH % "world", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data is not Dictionary:
		print("Data is not dictionary")
		return false
	
	if "player_x" in data:
		if data["player_x"] is not float:
			print("player_x is not number")
			return false
		
		world_map.player_pos.x = roundi(data["player_x"])
	if "player_y" in data:
		if data["player_y"] is not float:
			print("player_y is not number")
			return false
		
		world_map.player_pos.y = roundi(data["player_y"])
	if "world_num" in data:
		if data["world_num"] is not float:
			print("world_num is not number")
			return false
		
		world_map.world_num = roundi(data["world_num"])
	if "levels_beat" in data:
		if data["levels_beat"] is not float:
			print("levels_beat is not number")
			return false
		
		world_map.levels_beat = roundi(data["levels_beat"])
	if "tile_states" in data:
		if data["tile_states"] is not Array:
			print("tile_states is not array")
			return false
		
		var tile_states: Array = data["tile_states"]
		var is_valid: bool = are_tile_states_valid(tile_states)
		if not is_valid:
			print("tile_states is not valid")
			return false
		
		world_map.tiles = []
		
		var board_length: int = world_map.board_length
		var pixel_size := Vector2(board_length * 32, board_length * 32)
		var offset := -Vector2(pixel_size) / 2
		
		for column_states: Array in tile_states:
			var column: Array = []
			
			for tile_state: Dictionary in column_states:
				var tile: WorldMapTile = world_map.tile_scene.instantiate()
				world_map.add_child(tile)
				column.append(tile)
				
				tile.world_map = world_map
				
				tile.pos = Vector2i(roundi(tile_state["pos_x"]), roundi(tile_state["pos_y"]))
				tile.position = Vector2(tile.pos * 32) + offset
				
				tile.has_path = tile_state["has_path"]
				tile.is_positive = tile_state["is_positive"]
				tile.event_type = roundi(tile_state["event_type"]) as WorldMapTile.EventType
				tile.completed = tile_state["completed"]
			
			world_map.tiles.append(column)
		
		for column: Array in world_map.tiles:
			for tile: WorldMapTile in column:
				if tile.has_path:
					tile.path.show()
					tile.update_path_sprite()
				
				if tile.event_type != WorldMapTile.EventType.NONE:
					tile.event_signs[tile.event_type].show()
	if "player_deck" in data:
		if data["player_deck"] is not Array:
			print("player_deck is not array")
			return false
		
		for card: Variant in data["player_deck"]:
			if card is not Dictionary or not CardData.is_valid_json(card):
				print(card)
				print("player_deck has invalid card")
				return false
		
		world_map.player_deck = []
		for card: Dictionary in data["player_deck"]:
			world_map.player_deck.append(CardData.parse_json(card))
	
	world_map.player.position = world_map.get_tile_from_vec(world_map.player_pos).position
	return true


func are_tile_states_valid(tile_states: Array) -> bool:
	for column: Variant in tile_states:
		if column is not Array:
			return false
		
		for tile_state: Variant in column:
			if tile_state is not Dictionary:
				return false
			
			if "pos_x" not in tile_state or tile_state["pos_x"] is not float:
				return false
			if "pos_y" not in tile_state or tile_state["pos_y"] is not float:
				return false
			if "has_path" not in tile_state or tile_state["has_path"] is not bool:
				return false
			if "is_positive" not in tile_state or tile_state["is_positive"] is not bool:
				return false
			if "event_type" not in tile_state or tile_state["event_type"] is not float:
				return false
			if "completed" not in tile_state or tile_state["completed"] is not bool:
				return false
	
	return true
