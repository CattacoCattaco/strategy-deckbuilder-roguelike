class_name CardData
extends RefCounted

var modifiers: Array[Modifier]
var effect_range: int
var effect_size: int


func _init(p_modifiers: Array[Modifier] = [], p_effect_range: int = 0,
		p_effect_size: int = 0) -> void:
	modifiers = p_modifiers
	effect_range = p_effect_range
	effect_size = p_effect_size


func duplicate() -> CardData:
	return CardData.new(modifiers.duplicate(), effect_range, effect_size)


func get_effects() -> Array[Effect]:
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
	
	for base_action in base_actions:
		var applicable_local_mods: Array[Modifier.ModifierModifier] = []
		for local_mod in local_mods:
			if local_mod.applies_to(base_action):
				applicable_local_mods.append(local_mod)
		
		effects.append(Effect.create(base_action, applicable_local_mods, global_mods, effect_range,
				effect_size))
	
	return effects


func get_effects_text() -> String:
	if len(modifiers) == 0:
		return "(Blank)"
	
	var effects: Array[Effect] = get_effects()
	
	var effect_text: String = ""
	
	for effect in effects:
		if effect_text != "":
			effect_text += " "
		
		effect_text += effect.get_text()
	
	for global_mod in effects[0].global_modifiers:
		effect_text += global_mod._get_text(effects[0].effect_range, effects[0].effect_size)
	
	return effect_text
