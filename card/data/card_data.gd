class_name CardData
extends RefCounted

var modifiers: Array[Modifier]
var effect_range: int
var effect_size: int


static func sort(cards: Array[CardData]) -> void:
	for card in cards:
		Modifier.sort(card.modifiers)
	
	cards.sort_custom(is_before)


static func is_before(a: CardData, b: CardData) -> bool:
	for i in len(a.modifiers):
		if i >= len(b.modifiers):
			return false
		
		var a_mod: Modifier = a.modifiers[i]
		var b_mod: Modifier = b.modifiers[i]
		
		if a_mod._get_sort_order() < b_mod._get_sort_order():
			return true
		elif a_mod._get_sort_order() > b_mod._get_sort_order():
			return false
	
	if len(b.modifiers) > len(a.modifiers):
		return true
	
	if a.effect_range < b.effect_range:
		return true
	elif a.effect_range > b.effect_range:
		return false
	
	if a.effect_size < b.effect_size:
		return true
	elif a.effect_size > b.effect_size:
		return false
	
	return false


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
		effect_text += global_mod._get_text(effect_range, effect_size)
	
	return effect_text
