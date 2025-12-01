class_name Card
extends Control

@export var card_frame: Sprite2D
@export var effect_label: Label
@export var modifier_slots: Array[Sprite2D]
@export var range_label: Label
@export var effect_size_label: Label

var hand: Hand

var card_data: CardData

var needs_targets: bool = false
var cancelled: bool = false


func _ready() -> void:
	load_data()
	
	if hand:
		mouse_entered.connect(hand._hovered_over)
		mouse_exited.connect(hand._check_unhovered)
		
		mouse_entered.connect(_hover)
		mouse_exited.connect(_unhover)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if hand.tile_grid:
					if hand.tile_grid.round_manager.is_player_turn:
						try_play()
				elif hand.deck_manipulation_screen:
					var parent: Control = get_parent_control()
					if parent is Hand:
						hand.deck_manipulation_screen.current_slot_set.add_card(self)
					elif parent is CardSlot:
						if parent.input:
							parent.remove_card()
						else:
							parent.take_card()


func _hover() -> void:
	if get_parent() is Hand:
		var tween: Tween = create_tween()
		tween.tween_property(card_frame, "position", Vector2(0, -65), 0.5)


func _unhover() -> void:
	if get_parent() is Hand:
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


func try_play() -> void:
	if hand.card_currently_playing:
		hand.stop_playing_card()
	
	hand.card_currently_playing = self
	
	var effects: Array[Effect] = card_data.get_effects()
	
	needs_targets = true
	
	var targets: Array[Vector2i] = []
	
	for effect: Effect in effects:
		var player: TileObject = hand.player
		
		var rep_count: int = 1
		var can_jump: bool = false
		
		for local_mod in effect.local_modifiers:
			if local_mod is Modifier.Split2:
				rep_count *= 2
			elif local_mod is Modifier.Split3:
				rep_count *= 3
		
		for global_mod in effect.global_modifiers:
			if global_mod is Modifier.Jump:
				can_jump = true
		
		var targetable_tiles: Array[Tile]
		
		if effect.base_action is Modifier.Move:
			targetable_tiles = player.get_tiles_in_range(effect.effect_range, can_jump, false)
		else:
			targetable_tiles = player.get_tiles_in_range(effect.effect_range, can_jump, true)
		
		var action_marker: Tile.ActionMarker
		
		if effect.base_action is Modifier.Attack:
			action_marker = Tile.ActionMarker.ATTACK
		elif effect.base_action is Modifier.Heal:
			action_marker = Tile.ActionMarker.HEAL
		elif effect.base_action is Modifier.Move:
			action_marker = Tile.ActionMarker.MOVE
		elif effect.base_action is Modifier.Poison:
			action_marker = Tile.ActionMarker.POISON
		
		for i in range(rep_count):
			if i > 0:
				await get_tree().create_timer(0.2).timeout
			
			for tile in targetable_tiles:
				tile.show_action_marker(action_marker)
				tile.become_targetable()
			
			var target: Vector2i = await hand.tile_grid.tile_targeted
			
			targets.append(target)
			
			for tile in targetable_tiles:
				tile.hide_action_marker(action_marker)
				tile.become_untargetable()
	
	needs_targets = false
	
	hand.card_currently_playing = null
	
	if cancelled:
		cancelled = false
		return
	
	hand.discard(self)
	hand.draw_card()
	
	hand.card_played.emit(card_data, targets)
