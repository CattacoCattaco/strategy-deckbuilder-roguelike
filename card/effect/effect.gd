class_name Effect
extends RefCounted

var base_action: Modifier
var local_modifiers: Array[Modifier.ModifierModifier]
var global_modifiers: Array[Modifier.ModifierModifier]
var effect_range: int
var effect_size: int


static func create(p_base_action: Modifier, p_local_modifiers: Array[Modifier.ModifierModifier], 
		p_global_modifiers: Array[Modifier.ModifierModifier], p_effect_range: int,
		p_effect_size: int) -> Effect:
	
	var effect: Effect = Effect.new()
	
	effect.base_action = p_base_action
	effect.local_modifiers = p_local_modifiers
	effect.global_modifiers = p_global_modifiers
	effect.effect_range = p_effect_range
	effect.effect_size = p_effect_size
	
	return effect


func get_text() -> String:
	var sentence: String = base_action._get_text(effect_range, effect_size)
	
	for local_mod in local_modifiers:
		sentence += local_mod._get_text(effect_range, effect_size)
	
	sentence += "."
	return sentence
