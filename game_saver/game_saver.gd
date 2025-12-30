extends Node

const SAVE_PATH: String = "user://%s.json"


func save_stats() -> void:
	var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.WRITE)
	file.store_string(JSON.stringify(StatsManager.values, "\t"))
	file.close()


func has_stats() -> bool:
	if not FileAccess.file_exists(SAVE_PATH % "stats"):
		return false
	
	var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data is not Array:
		return false
	
	for stat in len(data):
		if stat >= StatsManager.Stat.STAT_COUNT:
			return false
		
		if data[stat] is not float:
			return false
	
	return true


func load_stats() -> void:
	var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	for stat in len(data):
		StatsManager.values.append(roundi(data[stat]))
	
	return


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


func has_world_map() -> bool:
	if not FileAccess.file_exists(SAVE_PATH % "world"):
		return false
	
	var file := FileAccess.open(SAVE_PATH % "world", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data is not Dictionary:
		return false
	
	if "player_x" not in data or data["player_x"] is not float:
			return false
	
	if "player_y" not in data or data["player_y"] is not float:
		return false
	
	if "world_num" not in data or data["world_num"] is not float:
			return false
	
	if "levels_beat" not in data or data["levels_beat"] is not float:
			return false
	
	if "tile_states" not in data or data["tile_states"] is not Array:
		return false
	
	var tile_states: Array = data["tile_states"]
	var is_valid: bool = are_world_tile_states_valid(tile_states)
	if not is_valid:
		return false
	
	if "player_deck" not in data or data["player_deck"] is not Array:
			return false
	
	for card: Variant in data["player_deck"]:
		if card is not Dictionary or not CardData.is_valid_json(card):
			return false
	
	return true


func load_world_map(world_map: WorldMap) -> bool:
	var file := FileAccess.open(SAVE_PATH % "world", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	world_map.player_pos.x = roundi(data["player_x"])
	world_map.player_pos.y = roundi(data["player_y"])
	world_map.world_num = roundi(data["world_num"])
	world_map.levels_beat = roundi(data["levels_beat"])
	
	var tile_states: Array = data["tile_states"]
	
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
	
	world_map.player_deck = []
	for card: Dictionary in data["player_deck"]:
		world_map.player_deck.append(CardData.parse_json(card))
	world_map.player_deck_updated()
	
	world_map.player.position = world_map.get_tile_from_vec(world_map.player_pos).position
	return true


func delete_world_map() -> void:
	while FileAccess.file_exists(SAVE_PATH % "world"):
		DirAccess.remove_absolute(SAVE_PATH % "world")


func are_world_tile_states_valid(tile_states: Array) -> bool:
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


func save_level(tile_grid: TileGrid) -> void:
	var data: Dictionary = {
		"size_x": tile_grid.size.x,
		"size_y": tile_grid.size.y,
		"is_mission": tile_grid.is_mission,
		"current_turn_index": tile_grid.round_manager.current_turn_index,
	}
	
	var turn_order: Array = []
	for object in tile_grid.round_manager.turn_order:
		turn_order.append({"x": object.pos.x, "y": object.pos.y})
	data["turn_order"] = turn_order
	
	var hand: Array = []
	for card in tile_grid.hand.cards:
		hand.append(card.card_data.jsonify())
	data["hand"] = hand
	
	var remaining_cards: Array = []
	for card in tile_grid.hand.deck.remaining_cards:
		remaining_cards.append(card.jsonify())
	data["remaining_cards"] = remaining_cards
	
	var used_cards: Array = []
	for card in tile_grid.hand.deck.used_cards:
		used_cards.append(card.jsonify())
	data["used_cards"] = used_cards
	
	var tiles_data: Array = []
	
	for column in tile_grid.tiles:
		var column_data: Array = []
		
		for tile: Tile in column:
			var tile_data: Dictionary = {}
			
			if tile.object:
				var object: TileObject = tile.object
				var object_data: Dictionary = {
					"health": object.health,
					"poison_level": object.poison_level,
					"shield_level": object.shield_level,
					"object_data": object.data_path,
				}
				
				var next_action := CardData.new()
				
				if object.data.action_source.next_action:
					next_action = object.data.action_source.next_action
				
				object_data["next_action"] = next_action.jsonify()
				
				var next_action_targets: Array = []
				
				for target in object.data.action_source.next_action_targets:
					next_action_targets.append({"x": target.x, "y": target.y})
				
				object_data["next_action_targets"] = next_action_targets
				
				tile_data["object"] = object_data
			
			column_data.append(tile_data)
		
		tiles_data.append(column_data)
	
	data["tiles"] = tiles_data
	
	var file := FileAccess.open(SAVE_PATH % "level", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func has_level() -> bool:
	if not FileAccess.file_exists(SAVE_PATH % "level"):
		return false
	
	var file := FileAccess.open(SAVE_PATH % "level", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data is not Dictionary:
		return false
	
	if "size_x" not in data or data["size_x"] is not float:
		return false
	if "size_y" not in data or data["size_y"] is not float:
		return false
	if "is_mission" not in data or data["is_mission"] is not bool:
		return false
	if "current_turn_index" not in data or data["current_turn_index"] is not float:
		return false
	
	var width: int = roundi(data["size_x"])
	var height: int = roundi(data["size_y"])
	
	if "turn_order" not in data or data["turn_order"] is not Array:
		return false
	
	for item: Variant in data["turn_order"]:
		if item is not Dictionary:
			return false
		
		if "x" not in item or item["x"] is not float:
			return false
		if "y" not in item or item["y"] is not float:
			return false
		
		var x: int = roundi(item["x"])
		var y: int = roundi(item["y"])
		
		if x < 0 or x >= width:
			return false
		if y < 0 or y >= height:
			return false
	
	if "hand" not in data or data["hand"] is not Array:
		return false
	
	for card: Variant in data["hand"]:
		if card is not Dictionary or not CardData.is_valid_json(card):
			return false
	
	if "remaining_cards" not in data or data["remaining_cards"] is not Array:
		return false
	
	for card: Variant in data["remaining_cards"]:
		if card is not Dictionary or not CardData.is_valid_json(card):
			return false
	
	if "used_cards" not in data or data["used_cards"] is not Array:
		return false
	
	for card: Variant in data["used_cards"]:
		if card is not Dictionary or not CardData.is_valid_json(card):
			return false
	
	if "tiles" not in data or data["tiles"] is not Array:
		return false
	
	if len(data["tiles"]) != width:
		return false
	
	for column: Variant in data["tiles"]:
		if column is not Array or len(column) > height:
			return false
		
		for tile: Variant in column:
			if tile is not Dictionary:
				return false
			
			if "object" in tile:
				if tile["object"] is not Dictionary:
					return false
				
				var object: Dictionary = tile["object"]
				if "health" not in object or object["health"] is not float:
					return false
				if "poison_level" not in object or object["poison_level"] is not float:
					return false
				if "shield_level" not in object or object["shield_level"] is not float:
					return false
				if "object_data" not in object or object["object_data"] is not String:
					return false
				if not FileAccess.file_exists(object["object_data"]):
					return false
				var object_data: Variant = load(object["object_data"])
				if (not object_data) or object_data is not TileObjectData:
					return false
				if "next_action" not in object:
					return false
				if not CardData.is_valid_json(object["next_action"]):
					return false
				if "next_action_targets" not in object:
					return false
				if object["next_action_targets"] is not Array:
					return false
				
				for target: Variant in object["next_action_targets"]:
					if target is not Dictionary:
						return false
					
					if "x" not in target or target["x"] is not float:
						return false
					if "y" not in target or target["y"] is not float:
						return false
					
					var x: int = roundi(target["x"])
					var y: int = roundi(target["y"])
					
					if x < 0 or x >= width:
						return false
					if y < 0 or y >= height:
						return false
	
	return true


func load_level(tile_grid: TileGrid) -> void:
	var file := FileAccess.open(SAVE_PATH % "level", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	tile_grid.size.x = roundi(data["size_x"])
	tile_grid.size.y = roundi(data["size_y"])
	tile_grid.is_mission = data["is_mission"]
	
	for card: Dictionary in data["hand"]:
		tile_grid.hand.add_card(CardData.parse_json(card))
	
	for card: Dictionary in data["remaining_cards"]:
		tile_grid.hand.deck.remaining_cards.append(CardData.parse_json(card))
	
	for card: Dictionary in data["used_cards"]:
		tile_grid.hand.deck.used_cards.append(CardData.parse_json(card))
	
	tile_grid.tiles = []
	EnemyActionSource.enemies = []
	EnemyActionSource.defendables = []
	
	var pixel_size: Vector2 = tile_grid.size * 32
	var offset := -pixel_size / 2
	
	for x in len(data["tiles"]):
		var column_data: Array = data["tiles"][x]
		var column: Array = []
		
		for y in len(column_data):
			var tile: Tile = tile_grid.tile_scene.instantiate()
			tile_grid.add_child(tile)
			
			tile.pos = Vector2i(x, y)
			tile.position = Vector2(32 * x, 32 * y) + offset
			tile.tile_grid = tile_grid
			
			column.append(tile)
			
			if "object" in column_data[y]:
				var object_state: Dictionary = column_data[y]["object"]
				
				tile.add_object(load(object_state["object_data"]))
				
				tile.object.health = roundi(object_state["health"])
				tile.object.poison_level = roundi(object_state["poison_level"])
				tile.object.shield_level = roundi(object_state["shield_level"])
				
				if tile.object.data.max_health > -1:
					tile.object.show_health()
				
				var action_source: ActionSource = tile.object.data.action_source
				action_source.next_action = CardData.parse_json(object_state["next_action"])
				
				var targets: Array[Vector2i] = []
				
				for target: Dictionary in object_state["next_action_targets"]:
					targets.append(Vector2i(target["x"], target["y"]))
				
				action_source.next_action_targets = targets
				
				if action_source.preview_actions:
					tile.object.display_action_thought_bubble(action_source.next_action)
				
				if tile.object.data.object_type == TileObjectData.ObjectType.ENEMY:
					EnemyActionSource.enemies.append(tile.object)
				elif tile.object.data.object_type == TileObjectData.ObjectType.DEFENDABLE:
					EnemyActionSource.defendables.append(tile.object)
				elif tile.object.data.object_type == TileObjectData.ObjectType.PLAYER:
					tile_grid.hand.player = tile.object
		
		tile_grid.tiles.append(column)
	
	tile_grid.round_manager.turn_order = []
	
	for item: Dictionary in data["turn_order"]:
		var pos := Vector2i(roundi(item["x"]), roundi(item["y"]))
		var tile: Tile = tile_grid.get_tile(pos.x, pos.y)
		
		if tile.object:
			tile_grid.round_manager.turn_order.append(tile.object)
	
	tile_grid.round_manager.current_turn_index = roundi(data["current_turn_index"])
	tile_grid.round_manager.do_turn()


func delete_level() -> void:
	while FileAccess.file_exists(SAVE_PATH % "level"):
		DirAccess.remove_absolute(SAVE_PATH % "level")


func save_deck_manipulation(deck_manipulation_screen: DeckManipulationScreen) -> void:
	var current_set: SlotSet = deck_manipulation_screen.current_slot_set
	var data: Dictionary = {
		"current_slot_set": current_set.type,
	}
	
	var hand: Array = []
	for card in deck_manipulation_screen.hand.cards:
		hand.append(card.card_data.jsonify())
	data["hand"] = hand
	
	if current_set.type == SlotSet.Type.ADD_SYMBOL:
		data["modifier"] = current_set.modifier._get_sort_order()
	elif current_set.type == SlotSet.Type.DRAFT_CARD:
		var draft_cards: Array = []
		for card_slot in current_set.output_slots:
			draft_cards.append(card_slot.card.card_data.jsonify())
		
		data["draft_cards"] = draft_cards
	
	var file := FileAccess.open(SAVE_PATH % "deck_manipulation", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()


func has_deck_manipulation() -> bool:
	if not FileAccess.file_exists(SAVE_PATH % "deck_manipulation"):
		return false
	
	var file := FileAccess.open(SAVE_PATH % "deck_manipulation", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data is not Dictionary:
		return false
	
	if "current_slot_set" not in data or data["current_slot_set"] is not float:
		return false
	
	if "hand" not in data or data["hand"] is not Array:
		return false
	
	var hand: Array = data["hand"]
	for card: Variant in hand:
		if card is not Dictionary or not CardData.is_valid_json(card):
			return false
	
	var set_type: int = roundi(data["current_slot_set"])
	
	if set_type == SlotSet.Type.ADD_SYMBOL:
		if "modifier" not in data or data["modifier"] is not float:
			return false
	elif set_type == SlotSet.Type.DRAFT_CARD:
		if "draft_cards" not in data or data["draft_cards"] is not Array:
			return false
		
		var draft_cards: Array = data["draft_cards"]
		for card: Variant in draft_cards:
			if card is not Dictionary or not CardData.is_valid_json(card):
				return false
	
	return true


func load_deck_manipulation(deck_manipulation_screen: DeckManipulationScreen) -> void:
	var file := FileAccess.open(SAVE_PATH % "deck_manipulation", FileAccess.READ)
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	deck_manipulation_screen.set_slot_set(roundi(data["current_slot_set"]))
	
	for card: Dictionary in data["hand"]:
		deck_manipulation_screen.hand.add_card(CardData.parse_json(card))
	
	var set_type: SlotSet.Type = deck_manipulation_screen.current_slot_set.type
	
	if set_type == SlotSet.Type.ADD_SYMBOL:
		for modifier in Modifier.all_modifiers:
			if modifier._get_sort_order() == data["modifier"]:
				deck_manipulation_screen.current_slot_set.modifier = modifier
	elif set_type == SlotSet.Type.DRAFT_CARD:
		for i in len(data["hand"]):
			var slot: CardSlot = deck_manipulation_screen.current_slot_set.output_slots[i]
			slot.create_card(CardData.parse_json(data["hand"][i]))


func delete_deck_manipulation() -> void:
	while FileAccess.file_exists(SAVE_PATH % "deck_manipulation"):
		DirAccess.remove_absolute(SAVE_PATH % "deck_manipulation")
