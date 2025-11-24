class_name Card
extends Control

@export var card_frame: Sprite2D
@export var effect_label: Label
@export var modifier_slots: Array[Sprite2D]
@export var range_label: Label
@export var effect_size_label: Label

var hand: Hand

var card_data: CardData


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
	Modifier.sort(card_data.modifiers)
	
	for i in range(5):
		if i < len(card_data.modifiers):
			var modifier: Modifier = card_data.modifiers[i]
			modifier_slots[i].texture = modifier._get_image()
			modifier_slots[i].show()
		else:
			modifier_slots[i].hide()
	
	range_label.text = str(card_data.effect_range)
	effect_size_label.text = str(card_data.effect_size)
	
	effect_label.text = card_data.get_effects_text()
