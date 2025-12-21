@tool
class_name EnemyActionFlowEditor
extends PanelContainer

const INSTANCE_SCENE = preload(
		"res://addons/enemy_editor/screen/enemy_action_flow_editor/enemy_action_flow_editor.tscn")

signal action_flow_updated()

@export var action_flow_type_options: OptionButton
@export var options_container: GridContainer

var enemy_editor_screen: EnemyEditorScreen

var action_flow: ActionFlowComponent


func _ready() -> void:
	action_flow_type_options.item_selected.connect(_set_action_flow_type)


func edit(new_flow: ActionFlowComponent) -> void:
	action_flow = new_flow
	
	if action_flow is AttackActionFlow:
		action_flow_type_options.selected = 0
	elif action_flow is ClumpOrDisperseActionFlow:
		action_flow_type_options.selected = 1
	elif action_flow is DefendableAmountCheckActionFlow:
		action_flow_type_options.selected = 2
	elif action_flow is DistanceCheckActionFlow:
		action_flow_type_options.selected = 3
	elif action_flow is EnemyAmountCheckActionFlow:
		action_flow_type_options.selected = 4
	elif action_flow is EnemyDistanceCheckActionFlow:
		action_flow_type_options.selected = 5
	elif action_flow is HealEnemyActionFlow:
		action_flow_type_options.selected = 6
	elif action_flow is MoveCloserFurtherActionFlow:
		action_flow_type_options.selected = 7
	elif action_flow is NullActionFlow:
		action_flow_type_options.selected = 8
	elif action_flow is PoisonActionFlow:
		action_flow_type_options.selected = 9
	elif action_flow is RandomActionFlow:
		action_flow_type_options.selected = 10
	
	show_flow_options()


func _set_action_flow_type(type: int) -> void:
	match type:
		0:
			action_flow = AttackActionFlow.new()
		1:
			action_flow = ClumpOrDisperseActionFlow.new()
		2:
			action_flow = DefendableAmountCheckActionFlow.new()
		3:
			action_flow = DistanceCheckActionFlow.new()
		4:
			action_flow = EnemyAmountCheckActionFlow.new()
		5:
			action_flow = EnemyDistanceCheckActionFlow.new()
		6:
			action_flow = HealEnemyActionFlow.new()
		7:
			action_flow = MoveCloserFurtherActionFlow.new()
		8:
			action_flow = NullActionFlow.new()
		9:
			action_flow = PoisonActionFlow.new()
		10:
			action_flow = RandomActionFlow.new()
	
	action_flow_updated.emit()
	
	show_flow_options()


func show_flow_options() -> void:
	for child in options_container.get_children():
		child.queue_free()
	
	options_container.columns = 2
	
	match action_flow_type_options.selected:
		0:
			create_float_editor("player_weight", 0, 1, 0.05)
			create_int_editor("attack_range", 0, 100, 1)
			create_bool_editor("can_jump")
			create_int_editor("attack_damage", 0, 100, 1)
		1:
			create_int_editor("move_range", 0, 100, 1)
			create_bool_editor("can_jump")
			create_bool_editor("clump")
			create_bool_editor("healable")
		2:
			create_int_editor("threshold", 0, 100, 1)
			create_action_flow_editor("below")
			create_action_flow_editor("at")
			create_action_flow_editor("above")
		3:
			create_enum_editor("distance_type", ["Damageable", "Player", "Defendable"])
			create_bool_editor("use_threshold")
			create_int_editor("threshold", 0, 100, 1)
			create_enum_editor("comp_distance_type", ["Damageable", "Player", "Defendable"])
			create_action_flow_editor("below")
			create_action_flow_editor("at")
			create_action_flow_editor("above")
		4:
			create_int_editor("threshold", 0, 100, 1)
			create_bool_editor("healable")
			create_action_flow_editor("below")
			create_action_flow_editor("at")
			create_action_flow_editor("above")
		5:
			create_int_editor("threshold", 0, 100, 1)
			create_bool_editor("healable")
			create_action_flow_editor("below")
			create_action_flow_editor("at")
			create_action_flow_editor("above")
		6:
			create_int_editor("heal_range", 0, 100, 1)
			create_bool_editor("can_jump")
			create_int_editor("heal_size", 0, 100, 1)
		7:
			create_enum_editor("distance_type", ["Damageable", "Player", "Defendable"])
			create_int_editor("move_range", 0, 100, 1)
			create_bool_editor("can_jump")
			create_bool_editor("closer")
		8:
			# Null Action Flow has no params
			pass
		9:
			create_float_editor("player_weight", 0, 1, 0.05)
			create_int_editor("poison_range", 0, 100, 1)
			create_bool_editor("can_jump")
			create_int_editor("poison_damage", 0, 100, 1)
		10:
			options_container.columns = 1
			
			var random_action_flow: RandomActionFlow = action_flow
			for i in len(random_action_flow.options):
				create_random_editor(i)
			
			var new_button := Button.new()
			new_button.text = "New Option"
			new_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
			new_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
			
			new_button.pressed.connect(_add_random_option)
			options_container.add_child(new_button)


func create_float_editor(property_name: String, min: float, max: float, step: float) -> void:
	var label := Label.new()
	label.text = property_name.capitalize()
	
	options_container.add_child(label)
	
	var spin_box := SpinBox.new()
	spin_box.value = action_flow.get(property_name)
	spin_box.min_value = min
	spin_box.max_value = max
	spin_box.step = step
	
	spin_box.value_changed.connect(_set_float.bind(property_name))
	options_container.add_child(spin_box)


func create_int_editor(property_name: String, min: int, max: int, step: int) -> void:
	var label := Label.new()
	label.text = property_name.capitalize()
	
	options_container.add_child(label)
	
	var spin_box := SpinBox.new()
	spin_box.value = action_flow.get(property_name)
	spin_box.min_value = min
	spin_box.max_value = max
	spin_box.step = step
	spin_box.rounded = true
	
	spin_box.value_changed.connect(_set_int.bind(property_name))
	options_container.add_child(spin_box)


func create_bool_editor(property_name: String) -> void:
	var label := Label.new()
	label.text = property_name.capitalize()
	
	options_container.add_child(label)
	
	var check_box := CheckBox.new()
	check_box.button_pressed = action_flow.get(property_name)
	
	check_box.toggled.connect(_set_bool.bind(property_name))
	options_container.add_child(check_box)


func create_enum_editor(property_name: String, options: Array[String]) -> void:
	var label := Label.new()
	label.text = property_name.capitalize()
	
	options_container.add_child(label)
	
	var option_button := OptionButton.new()
	for option in options:
		option_button.add_item(option)
	
	option_button.selected = action_flow.get(property_name)
	
	option_button.item_selected.connect(_set_int.bind(property_name))
	options_container.add_child(option_button)


func create_action_flow_editor(property_name: String) -> void:
	var label := Label.new()
	label.text = property_name.capitalize()
	
	options_container.add_child(label)
	
	var action_flow_editor: EnemyActionFlowEditor = INSTANCE_SCENE.instantiate()
	action_flow_editor.edit(action_flow.get(property_name))
	
	var bound_func: Callable = _set_action_flow.bind(action_flow_editor, property_name)
	
	action_flow_editor.action_flow_updated.connect(bound_func)
	options_container.add_child(action_flow_editor)


func create_random_editor(index: int) -> void:
	var random_action_flow: RandomActionFlow = action_flow
	
	var panel_container := PanelContainer.new()
	panel_container.add_theme_stylebox_override("Panel", theme.get_stylebox("panel", "Panel"))
	
	options_container.add_child(panel_container)
	
	var margin_container := MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", 5)
	margin_container.add_theme_constant_override("margin_top", 5)
	margin_container.add_theme_constant_override("margin_right", 5)
	margin_container.add_theme_constant_override("margin_bottom", 5)
	
	panel_container.add_child(margin_container)
	
	var vbox_container := VBoxContainer.new()
	margin_container.add_child(vbox_container)
	
	var grid_container := GridContainer.new()
	grid_container.columns = 2
	
	vbox_container.add_child(grid_container)
	
	var label := Label.new()
	label.text = "Option %s Chance" % index
	
	grid_container.add_child(label)
	
	var spin_box := SpinBox.new()
	spin_box.value = random_action_flow.probabilities[index]
	spin_box.min_value = 0
	spin_box.max_value = 1
	spin_box.step = 0.05
	
	spin_box.value_changed.connect(_set_probability.bind(index))
	grid_container.add_child(spin_box)
	
	var action_label := Label.new()
	action_label.text = "Option %s Action" % index
	
	grid_container.add_child(action_label)
	
	var action_flow_editor: EnemyActionFlowEditor = INSTANCE_SCENE.instantiate()
	action_flow_editor.edit(random_action_flow.options[index])
	
	var bound_func: Callable = _set_random_action.bind(action_flow_editor, index)
	
	action_flow_editor.action_flow_updated.connect(bound_func)
	grid_container.add_child(action_flow_editor)
	
	var delete_button := Button.new()
	delete_button.text = "Delete Option"
	delete_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	delete_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	delete_button.pressed.connect(_remove_random_option.bind(index))
	vbox_container.add_child(delete_button)


func _set_float(value: float, property_name: StringName) -> void:
	action_flow.set(property_name, value)
	action_flow_updated.emit()


func _set_int(value: int, property_name: StringName) -> void:
	action_flow.set(property_name, value)
	action_flow_updated.emit()


func _set_bool(value: bool, property_name: StringName) -> void:
	action_flow.set(property_name, value)
	action_flow_updated.emit()


func _set_action_flow(editor: EnemyActionFlowEditor, property_name: StringName) -> void:
	action_flow.set(property_name, editor.action_flow)
	action_flow_updated.emit()


func _set_probability(value: float, index: int) -> void:
	var random_action_flow: RandomActionFlow = action_flow
	random_action_flow.probabilities[index] = value


func _set_random_action(editor: EnemyActionFlowEditor, index: int) -> void:
	var random_action_flow: RandomActionFlow = action_flow
	random_action_flow.options[index] = editor.action_flow


func _remove_random_option(index: int) -> void:
	var random_action_flow: RandomActionFlow = action_flow
	random_action_flow.options.remove_at(index)
	random_action_flow.probabilities.remove_at(index)
	show_flow_options()


func _add_random_option() -> void:
	var random_action_flow: RandomActionFlow = action_flow
	random_action_flow.options.append(null)
	random_action_flow.probabilities.append(0)
	show_flow_options()
