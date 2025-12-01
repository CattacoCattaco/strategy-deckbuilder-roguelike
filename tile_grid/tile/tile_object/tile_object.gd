@tool
class_name TileObject
extends Node2D

enum ThoughtBubbleType {
	EMPTY,
	ATTACK,
	HEAL,
	MOVE,
	POISON,
	COMPLEX,
}

const THOUGHT_BUBBLES: Array[Texture2D] = [
	preload("res://tile_grid/tile/tile_object/thought_bubble/thought_bubble.png"),
	preload("res://tile_grid/tile/tile_object/thought_bubble/thought_bubble_attack.png"),
	preload("res://tile_grid/tile/tile_object/thought_bubble/thought_bubble_heal.png"),
	preload("res://tile_grid/tile/tile_object/thought_bubble/thought_bubble_move.png"),
	preload("res://tile_grid/tile/tile_object/thought_bubble/thought_bubble_poison.png"),
	preload("res://tile_grid/tile/tile_object/thought_bubble/thought_bubble_complex.png"),
]

@export var sprite: AnimatedSprite2D
@export var poisoned_sprite: AnimatedSprite2D
@export var thought_bubble: Sprite2D

@export var data: TileObjectData:
	set(value):
		data = value.duplicate(true)
		load_sprite_anim()

var tile_grid: TileGrid
var tile: Tile
var pos: Vector2i
var health: int
var poison_level: int = 0


func _ready() -> void:
	poisoned_sprite.play("default")
	poisoned_sprite.hide()
	
	hide_thought_bubble()


func load_sprite_anim() -> void:
	if not sprite:
		return
	
	sprite.sprite_frames = data.get_sprite_frames()
	
	match data.texture_type:
		TileObjectData.TextureType.ANIMATED:
			sprite.play("default")
		TileObjectData.TextureType.VARIANTS:
			var varients: int = data.texture.get_height() >> 5
			sprite.play(str(randi_range(0, varients - 1)))
		TileObjectData.TextureType.HEALTH_STATES:
			show_health()


func do_action(action: CardData, targets: Array[Vector2i]) -> void:
	var effects: Array[Effect] = action.get_effects()
	
	var current_target_index: int = 0
	
	for i in len(effects):
		var effect: Effect = effects[i]
		
		var rep_count: int = 1
		
		for local_mod in effect.local_modifiers:
			if local_mod is Modifier.Split2:
				rep_count *= 2
			elif local_mod is Modifier.Split3:
				rep_count *= 3
		
		for global_mod in effect.global_modifiers:
			if global_mod is Modifier.Jump:
				# Jumping should already be accounted for
				pass
		
		for j in range(rep_count):
			var target: Vector2i = targets[current_target_index]
			current_target_index += 1
			
			if not tile_grid.has_tile(target.x, target.y):
				continue
			
			if effect.base_action is Modifier.Move:
				if target == pos:
					continue
				
				move_to(target)
			elif effect.base_action is Modifier.Attack:
				damage(target, effect.effect_size)
			elif effect.base_action is Modifier.Heal:
				heal(target, effect.effect_size)
			elif effect.base_action is Modifier.Poison:
				poison(target, effect.effect_size)
			
			await get_tree().create_timer(0.8).timeout


func move_to(new_pos: Vector2i) -> void:
	if tile_grid.get_tile(new_pos.x, new_pos.y).object:
		return
	
	tile.object = null
	
	pos = new_pos
	tile = tile_grid.get_tile(pos.x, pos.y)
	reparent(tile, false)
	tile.object = self
	
	if data.action_source is PlayerActionSource:
		EnemyActionSource.recalc_distances(tile_grid)


func damage(target_pos: Vector2i, amount: int) -> void:
	if not tile_grid.get_tile(target_pos.x, target_pos.y).object:
		return
	
	var target: TileObject = tile_grid.get_tile(target_pos.x, target_pos.y).object
	
	target.health -= amount
	target.show_health()
	
	if target.health <= 0:
		target.tile.delete_object()


func heal(target_pos: Vector2i, amount: int) -> void:
	if not tile_grid.get_tile(target_pos.x, target_pos.y).object:
		return
	
	var target: TileObject = tile_grid.get_tile(target_pos.x, target_pos.y).object
	
	target.health += amount
	
	if target.health > target.data.max_health:
		target.health = target.data.max_health
	
	target.show_health()


func poison(target_pos: Vector2i, amount: int) -> void:
	if not tile_grid.get_tile(target_pos.x, target_pos.y).object:
		return
	
	var target: TileObject = tile_grid.get_tile(target_pos.x, target_pos.y).object
	
	target.poison_level += amount
	
	target.poisoned_sprite.show()


func do_poison() -> void:
	health -= poison_level
	
	poison_level -= 1
	
	if poison_level == 0:
		poisoned_sprite.hide()
	
	show_health()
	
	if health <= 0:
		print("deleted")
		tile.delete_object()


func get_tiles_in_range(range_size: int, can_jump: bool, target_characters: bool) -> Array[Tile]:
	var tiles: Array[Tile] = []
	var positions: Array[Vector2i] = [pos]
	var prev_layer: Array[Vector2i] = [pos]
	
	if target_characters:
		if data.object_type != TileObjectData.ObjectType.STATIC:
			tiles.append(tile)
	
	for distance in range(1, range_size + 1):
		var new_layer: Array[Vector2i]
		for prev_pos in prev_layer:
			for dir in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]:
				var neighbor_pos: Vector2i = prev_pos + dir
				
				# Not on board
				if not tile_grid.has_tile(neighbor_pos.x, neighbor_pos.y):
					continue
				
				# Already found
				if neighbor_pos in positions:
					continue
				
				var neighbor: Tile = tile_grid.get_tile(neighbor_pos.x, neighbor_pos.y)
				
				if not neighbor.object:
					new_layer.append(neighbor_pos)
					positions.append(neighbor_pos)
					
					if not target_characters:
						tiles.append(neighbor)
					
					continue
				
				positions.append(neighbor_pos)
				
				if can_jump:
					new_layer.append(neighbor_pos)
				
				if target_characters and neighbor.object.data.max_health >= 0:
					tiles.append(neighbor)
		
		prev_layer = new_layer
	
	return tiles


func display_action_thought_bubble(action: CardData) -> void:
	var is_attack: bool = false
	var is_heal: bool = false
	var is_move: bool = false
	var is_poison: bool = false
	
	for modifier in action.modifiers:
		if modifier is Modifier.Attack:
			is_attack = true
			
			if is_heal or is_move or is_poison:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
		elif modifier is Modifier.Heal:
			is_heal = true
			
			if is_attack or is_move or is_poison:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
		elif modifier is Modifier.Move:
			is_move = true
			
			if is_attack or is_heal or is_poison:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
		elif modifier is Modifier.Poison:
			is_poison = true
			
			if is_attack or is_heal or is_move:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
	
	if is_attack:
		set_thought_bubble(ThoughtBubbleType.ATTACK)
	elif is_heal:
		set_thought_bubble(ThoughtBubbleType.HEAL)
	elif is_move:
		set_thought_bubble(ThoughtBubbleType.MOVE)
	elif is_poison:
		set_thought_bubble(ThoughtBubbleType.POISON)


func set_thought_bubble(type: ThoughtBubbleType) -> void:
	thought_bubble.show()
	thought_bubble.texture = THOUGHT_BUBBLES[type]


func hide_thought_bubble() -> void:
	thought_bubble.hide()


func show_health() -> void:
	var health_chunks: int = data.texture.get_height() >> 5
	var current_health_chunk: int = (
			health_chunks - 1 - roundi(health as float / data.max_health * (health_chunks - 1)))
	sprite.play(str(current_health_chunk))
