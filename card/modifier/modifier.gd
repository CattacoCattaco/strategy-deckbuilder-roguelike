@abstract
class_name Modifier
extends RefCounted

enum Type {
	BASE_ACTION,
	LOCAL_MOD,
	GLOBAL_MOD,
}


static func lists_match(a: Array[Modifier], b: Array[Modifier]) -> bool:
	if len(a) != len(b):
		return false
	
	for i in len(a):
		if not a[i].matches(b[i]):
			return false
	
	return true


static func remove_duplicates(modifiers: Array[Modifier]) -> void:
	var old_modifiers: Array[Modifier] = modifiers.duplicate()
	for i in len(old_modifiers):
		var modifier: Modifier = old_modifiers[i]
		var sort_value: int = modifier._get_sort_order()
		
		for j in range(i):
			if old_modifiers[j]._get_sort_order() == sort_value:
				modifiers.remove_at(i)
				break


static func sort(modifiers: Array[Modifier]) -> void:
	modifiers.sort_custom(a_before_b)


static func a_before_b(a: Modifier, b: Modifier) -> bool:
	return a._get_sort_order() < b._get_sort_order()


## Returns the name of this modifier in title case
@abstract func _get_name() -> String
## Returns the sprite associated with this modifier
@abstract func _get_image() -> Texture2D
## Lower numbers go to the left of higher numbers
## 0-19: Base actions
## 20-39: Local modifiers
## 40-59: Global modifiers
@abstract func _get_sort_order() -> int
## For base actions, the description of the effect with the first word capitalized
## For Local modifiers, the modification with no capitalization prefixed with a space
## For Global modifiers, a complete sentence of the change with a period prefixed with a space
@abstract func _get_text(effect_range: int, effect_size: int) -> String


func matches(other: Modifier) -> bool:
	return other._get_sort_order() == _get_sort_order()


func get_mod_type() -> Type:
	var sort_order: int = _get_sort_order()
	
	if sort_order < 20:
		return Type.BASE_ACTION
	elif sort_order < 40:
		return Type.LOCAL_MOD
	else:
		return Type.GLOBAL_MOD


@abstract
class BaseAction extends Modifier:
	## Check if the object at a tile can be targetted by this effect
	@abstract func _can_target(tile: Tile, source: TileObject) -> bool


class Attack extends BaseAction:
	func _get_name() -> String:
		return "Attack"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/sword.png")
	
	
	func _get_sort_order() -> int:
		return 0
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Deal %d damage to a target in range %d" % [effect_size, effect_range]
	
	
	func _can_target(tile: Tile, _source: TileObject) -> bool:
		if not tile.object:
			return false
		
		return tile.object.data.max_health != -1


class Heal extends BaseAction:
	func _get_name() -> String:
		return "Heal"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/heart.png")
	
	
	func _get_sort_order() -> int:
		return 1
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Heal a target in range %d by %d" % [effect_range, effect_size]
	
	
	func _can_target(tile: Tile, _source: TileObject) -> bool:
		if not tile.object:
			return false
		
		return tile.object.data.max_health != -1


class Poison extends BaseAction:
	func _get_name() -> String:
		return "Poison"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/poison.png")
	
	
	func _get_sort_order() -> int:
		return 2
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Apply %d poison to a target in range %d" % [effect_size, effect_range]
	
	
	func _can_target(tile: Tile, _source: TileObject) -> bool:
		if not tile.object:
			return false
		
		return tile.object.data.max_health != -1


class Defend extends BaseAction:
	func _get_name() -> String:
		return "Defend"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/defend.png")
	
	
	func _get_sort_order() -> int:
		return 3
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Give a target in range %d %d shield" % [effect_range, effect_size]
	
	
	func _can_target(tile: Tile, _source: TileObject) -> bool:
		if not tile.object:
			return false
		
		return tile.object.data.max_health != -1


class Push extends BaseAction:
	func _get_name() -> String:
		return "Push"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/push.png")
	
	
	func _get_sort_order() -> int:
		return 17
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Push a target in range %d %d spaces" % [effect_range, effect_size]
	
	
	func _can_target(tile: Tile, source: TileObject) -> bool:
		if not tile.object:
			return false
		
		if tile.object == source:
			return false
		
		return tile.object.data.pushable


class Swap extends BaseAction:
	func _get_name() -> String:
		return "Swap"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/swap.png")
	
	
	func _get_sort_order() -> int:
		return 18
	
	
	func _get_text(effect_range: int, _effect_size: int) -> String:
		return "Swap positions with a target in range %d" % effect_range
	
	
	func _can_target(tile: Tile, source: TileObject) -> bool:
		if tile.object:
			if tile.object == source:
				return false
			
			return true
		
		return false


class Move extends BaseAction:
	func _get_name() -> String:
		return "Move"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/arrow.png")
	
	
	func _get_sort_order() -> int:
		return 19
	
	
	func _get_text(effect_range: int, _effect_size: int) -> String:
		if effect_range == 1:
			return "Move 1 space"
		
		return "Move up to %d spaces" % effect_range
	
	
	func _can_target(tile: Tile, _source: TileObject) -> bool:
		return not tile.object


@abstract
class ModifierModifier extends Modifier:
	## Can this modifier apply to a given base action
	@abstract func applies_to(modifier: BaseAction) -> bool


class Split2 extends ModifierModifier:
	func _get_name() -> String:
		return "Split"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/split-2.png")
	
	
	func _get_sort_order() -> int:
		return 20
	
	
	func applies_to(modifier: Modifier) -> bool:
		return modifier is not Move and modifier is not Swap
	
	
	func _get_text(_effect_range: int, _effect_size: int) -> String:
		return " twice at the same time"


class Split3 extends ModifierModifier:
	func _get_name() -> String:
		return "Split 3 Way"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/split-3.png")
	
	
	func _get_sort_order() -> int:
		return 21
	
	
	func applies_to(modifier: Modifier) -> bool:
		return modifier is not Move and modifier is not Swap
	
	
	func _get_text(_effect_range: int, _effect_size: int) -> String:
		return " thrice at the same time"


class Jump extends ModifierModifier:
	func _get_name() -> String:
		return "Jump"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/jump.png")
	
	
	func _get_sort_order() -> int:
		return 40
	
	
	func applies_to(_modifier: Modifier) -> bool:
		return true
	
	
	func _get_text(effect_range: int, _effect_size: int) -> String:
		# Does nothing if range is only one space
		if effect_range == 1:
			return ""
		
		return " Range jumps over blocked spaces."
