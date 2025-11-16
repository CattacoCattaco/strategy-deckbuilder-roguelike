class_name Card
extends Control


@export var effect_label: Label
@export var modifier_slots: Array[Sprite2D]
@export var range_label: Label
@export var effect_size_label: Label

@export var effect_range: int
@export var effect_size: int

var modifiers: Array[Modifier] = [
	Modifier.Heal.new(),
	Modifier.Attack.new(),
	Modifier.Poison.new(),
	Modifier.Jump.new(),
	Modifier.Split2.new(),
]


func _ready() -> void:
	load_data()


func load_data() -> void:
	Modifier.sort(modifiers)
	
	for i in range(5):
		if i < len(modifiers):
			var modifier: Modifier = modifiers[i]
			modifier_slots[i].texture = modifier._get_image()
			modifier_slots[i].show()
		else:
			modifier_slots[i].hide()
	
	range_label.text = str(effect_range)
	effect_size_label.text = str(effect_size)
	
	var effects: Array[Effect] = get_effects()
	
	effect_label.text = get_effect_text(effects)


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
		
		effects.append(Effect.create(base_action, applicable_local_mods, global_mods))
	
	return effects


func get_effect_text(effects: Array[Effect]) -> String:
	if len(effects) == 0:
		return "(Blank)"
	
	var effect_text: String = ""
	
	for effect in effects:
		if effect_text != "":
			effect_text += " "
		
		effect_text += effect.get_text(effect_range, effect_size)
	
	for global_mod in effects[0].global_modifiers:
		effect_text += global_mod._get_text(effect_range, effect_size)
	
	return effect_text


class Effect extends RefCounted:
	var base_action: Modifier
	var local_modifiers: Array[Modifier.ModifierModifier]
	var global_modifiers: Array[Modifier.ModifierModifier]
	
	static func create(p_base_action: Modifier, p_local_modifiers: Array[Modifier.ModifierModifier], 
			p_global_modifiers: Array[Modifier.ModifierModifier]) -> Effect:
		
		var effect: Effect = Effect.new()
		
		effect.base_action = p_base_action
		effect.local_modifiers = p_local_modifiers
		effect.global_modifiers = p_global_modifiers
		
		return effect
	
	
	func get_text(effect_range: int, effect_size: int) -> String:
		var sentence: String = base_action._get_text(effect_range, effect_size)
		
		for local_mod in local_modifiers:
			sentence += local_mod._get_text(effect_range, effect_size)
		
		sentence += "."
		return sentence
