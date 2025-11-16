@abstract
class_name Modifier
extends RefCounted

enum Type {
	BASE_ACTION,
	LOCAL_MOD,
	GLOBAL_MOD,
}


static func sort(modifiers: Array[Modifier]) -> void:
	modifiers.sort_custom(a_before_b)


static func a_before_b(a: Modifier, b: Modifier) -> bool:
	return a._get_sort_order() < b._get_sort_order()


## Returns the name of this modifier in title case
@abstract func _get_name() -> String
## Returns the sprite associated with this modifier
@abstract func _get_image() -> Texture2D
## Lower numbers go to the left of higher numbers
## 0-9: Base actions
## 10-19: Local modifiers
## 20-29: Global modifiers
@abstract func _get_sort_order() -> int
## For base actions, the description of the effect with the first word capitalized
## For Local modifiers, the modification with no capitalization prefixed with a space
## For Global modifiers, a complete sentence of the change with a period prefixed with a space
@abstract func _get_text(effect_range: int, effect_size: int) -> String


func get_mod_type() -> Type:
	var sort_order: int = _get_sort_order()
	
	if sort_order < 10:
		return Type.BASE_ACTION
	elif sort_order < 20:
		return Type.LOCAL_MOD
	else:
		return Type.GLOBAL_MOD


class Move extends Modifier:
	func _get_name() -> String:
		return "Move"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/arrow.png")
	
	
	func _get_sort_order() -> int:
		return 0
	
	
	func _get_text(effect_range: int, _effect_size: int) -> String:
		if effect_range == 1:
			return "Move 1 space"
		
		return "Move up to %d spaces" % effect_range


class Attack extends Modifier:
	func _get_name() -> String:
		return "Attack"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/sword.png")
	
	
	func _get_sort_order() -> int:
		return 1
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Deal %d damage to a target in range %d" % [effect_size, effect_range]


class Heal extends Modifier:
	func _get_name() -> String:
		return "Heal"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/heart.png")
	
	
	func _get_sort_order() -> int:
		return 2
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Heal %d damage from a target in range %d" % [effect_size, effect_range]


class Poison extends Modifier:
	func _get_name() -> String:
		return "Poison"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/poison.png")
	
	
	func _get_sort_order() -> int:
		return 3
	
	
	func _get_text(effect_range: int, effect_size: int) -> String:
		return "Apply %d poison to a target in range %d" % [effect_size, effect_range]


@abstract
class ModifierModifier extends Modifier:
	@abstract func applies_to(modifier: Modifier) -> bool


class Split2 extends ModifierModifier:
	func _get_name() -> String:
		return "Split"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/split-2.png")
	
	
	func _get_sort_order() -> int:
		return 10
	
	
	func applies_to(modifier: Modifier) -> bool:
		return modifier is not Move
	
	
	func _get_text(_effect_range: int, _effect_size: int) -> String:
		return " twice at the same time"


class Split3 extends ModifierModifier:
	func _get_name() -> String:
		return "Split 3 Way"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/split-3.png")
	
	
	func _get_sort_order() -> int:
		return 11
	
	
	func applies_to(modifier: Modifier) -> bool:
		return modifier is not Move
	
	
	func _get_text(_effect_range: int, _effect_size: int) -> String:
		return " thrice at the same time"


class Jump extends ModifierModifier:
	func _get_name() -> String:
		return "Jump"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/jump.png")
	
	
	func _get_sort_order() -> int:
		return 20
	
	
	func applies_to(_modifier: Modifier) -> bool:
		return true
	
	
	func _get_text(effect_range: int, _effect_size: int) -> String:
		# Does nothing if range is only one space
		if effect_range == 1:
			return ""
		
		return " Range jumps over blocked spaces."
