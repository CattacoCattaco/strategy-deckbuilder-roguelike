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
@export var thought_bubble: Sprite2D

@export var data: TileObjectData:
	set(value):
		data = value.duplicate(true)
		load_sprite_anim()

var tile_grid: TileGrid
var tile: Tile
var pos: Vector2i


func _ready() -> void:
	hide_thought_bubble()


func load_sprite_anim() -> void:
	if not sprite:
		return
	
	sprite.sprite_frames = data.get_sprite_frames()
	
	sprite.play("default")


func do_action(action: Array[Effect], targets: Array[Vector2i]) -> void:
	for i in len(action):
		var effect: Effect = action[i]
		var target: Vector2i = targets[i]
		
		if effect.base_action is Modifier.Move:
			move_to(target)


func move_to(new_pos: Vector2i) -> void:
	if tile_grid.get_tile(new_pos.x, new_pos.y).object:
		return
	
	tile.object = null
	
	pos = new_pos
	tile = tile_grid.get_tile(pos.x, pos.y)
	reparent(tile, false)
	tile.object = self


func display_action_thought_bubble(action: Array[Effect]) -> void:
	var is_attack: bool = false
	var is_heal: bool = false
	var is_move: bool = false
	var is_poison: bool = false
	
	for effect in action:
		if effect.base_action is Modifier.Attack:
			is_attack = true
			
			if is_heal or is_move or is_poison:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
		elif effect.base_action is Modifier.Heal:
			is_heal = true
			
			if is_attack or is_move or is_poison:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
		elif effect.base_action is Modifier.Move:
			is_move = true
			
			if is_attack or is_heal or is_poison:
				set_thought_bubble(ThoughtBubbleType.COMPLEX)
				return
		elif effect.base_action is Modifier.Poison:
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
