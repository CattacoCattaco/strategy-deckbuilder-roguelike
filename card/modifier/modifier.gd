@abstract
class_name Modifier
extends Resource

@abstract func _get_name() -> String
@abstract func _get_image() -> Texture2D
@abstract func _get_sort_order() -> int


static func sort(modifiers: Array[Modifier]) -> void:
	modifiers.sort_custom(a_before_b)


static func a_before_b(a: Modifier, b: Modifier) -> bool:
	return a._get_sort_order() < b._get_sort_order()


class Move extends Modifier:
	func _get_name() -> String:
		return "move"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/arrow.png")
	
	
	func _get_sort_order() -> int:
		return 0


class Attack extends Modifier:
	func _get_name() -> String:
		return "attack"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/sword.png")
	
	
	func _get_sort_order() -> int:
		return 1


class Heal extends Modifier:
	func _get_name() -> String:
		return "heal"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/heart.png")
	
	
	func _get_sort_order() -> int:
		return 2


class Poison extends Modifier:
	func _get_name() -> String:
		return "poison"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/poison.png")
	
	
	func _get_sort_order() -> int:
		return 3


@abstract
class ModifierModifier extends Modifier:
	pass


class Jump extends ModifierModifier:
	func _get_name() -> String:
		return "jump"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/jump.png")
	
	
	func _get_sort_order() -> int:
		return 10


class Split2 extends ModifierModifier:
	func _get_name() -> String:
		return "split2"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/split-2.png")
	
	
	func _get_sort_order() -> int:
		return 11


class Split3 extends ModifierModifier:
	func _get_name() -> String:
		return "split3"
	
	
	func _get_image() -> Texture2D:
		return preload("res://card/modifier/split-3.png")
	
	
	func _get_sort_order() -> int:
		return 12
