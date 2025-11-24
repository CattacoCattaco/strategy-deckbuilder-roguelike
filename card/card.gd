class_name Card
extends Control

@export var card_frame: Sprite2D
@export var effect_label: Label
@export var modifier_slots: Array[Sprite2D]
@export var range_label: Label
@export var effect_size_label: Label

@export var effect_range: int
@export var effect_size: int

var hand: Hand

var modifiers: Array[Modifier] = [
	Modifier.Heal.new(),
	Modifier.Attack.new(),
	Modifier.Poison.new(),
	Modifier.Jump.new(),
	Modifier.Split2.new(),
]


func _ready() -> void:
	load_data()
	
	if hand:
		mouse_entered.connect(hand._hovered_over)
		mouse_exited.connect(hand._check_unhovered)
		
		mouse_entered.connect(_hover)
		mouse_exited.connect(_unhover)


func _hover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(card_frame, "position", Vector2(0, -65), 0.5)


func _unhover() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(card_frame, "position", Vector2(0, 0), 0.5)


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
	
	var effects: Array[Effect] = Effect.get_effects(modifiers, effect_range, effect_size)
	
	effect_label.text = Effect.get_effects_text(effects)
