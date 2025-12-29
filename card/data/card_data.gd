class_name CardData
extends RefCounted

var modifiers: Array[Modifier]
var effect_range: int
var effect_size: int


static func is_valid_json(data: Dictionary) -> bool:
	if "effect_range" not in data or data["effect_range"] is not float:
		return false
	if "effect_size" not in data or data["effect_size"] is not float:
		return false
	if "modifiers" not in data or data["modifiers"] is not Array:
		return false
	
	for sort_order_f: float in data["modifiers"]:
		var sort_order: int = roundi(sort_order_f)
		var found_match: bool = false
		for modifier in Modifier.all_modifiers:
			if modifier._get_sort_order() == sort_order:
				found_match = true
				break
		
		if not found_match:
			return false
	
	return true


static func parse_json(data: Dictionary) -> CardData:
	var card_data := CardData.new()
	card_data.effect_range = roundi(data["effect_range"])
	card_data.effect_size = roundi(data["effect_size"])
	
	card_data.modifiers = []
	for sort_order_f: float in data["modifiers"]:
		var sort_order: int = roundi(sort_order_f)
		for modifier in Modifier.all_modifiers:
			if modifier._get_sort_order() == sort_order:
				card_data.modifiers.append(modifier)
				break
	
	return card_data


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


func jsonify() -> Dictionary:
	var data: Dictionary = {
		"effect_range": effect_range,
		"effect_size": effect_size,
	}
	
	var modifier_sort_orders: Array = []
	for modifier in modifiers:
		modifier_sort_orders.append(modifier._get_sort_order())
	
	data["modifiers"] = modifier_sort_orders
	
	return data
