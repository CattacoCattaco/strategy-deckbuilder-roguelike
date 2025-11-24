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


static func get_effects(modifiers: Array[Modifier], p_effect_range: int, p_effect_size: int
		) -> Array[Effect]:
	var effects: Array[Effect] = []
	
	var base_actions: Array[Modifier] = []
	var local_mods: Array[Modifier.ModifierModifier] = []
	var global_mods: Array[Modifier.ModifierModifier] = []
	
	for modifier in modifiers:
		match modifier.get_mod_type():
			Modifier.Type.BASE_ACTION:
				base_actions.append(modifier)
			Modifier.Type.LOCAL_MOD:
				local_mods.append(modifier)
			Modifier.Type.GLOBAL_MOD:
				global_mods.append(modifier)
	
	for p_base_action in base_actions:
		var applicable_local_mods: Array[Modifier.ModifierModifier] = []
		for local_mod in local_mods:
			if local_mod.applies_to(p_base_action):
				applicable_local_mods.append(local_mod)
		
		effects.append(create(p_base_action, applicable_local_mods, global_mods, p_effect_range,
				p_effect_size))
	
	return effects


static func get_effects_text(effects: Array[Effect]) -> String:
	if len(effects) == 0:
		return "(Blank)"
	
	var effect_text: String = ""
	
	for effect in effects:
		if effect_text != "":
			effect_text += " "
		
		effect_text += effect.get_text()
	
	for global_mod in effects[0].global_modifiers:
		effect_text += global_mod._get_text(effects[0].effect_range, effects[0].effect_size)
	
	return effect_text


func get_text() -> String:
	var sentence: String = base_action._get_text(effect_range, effect_size)
	
	for local_mod in local_modifiers:
		sentence += local_mod._get_text(effect_range, effect_size)
	
	sentence += "."
	return sentence
