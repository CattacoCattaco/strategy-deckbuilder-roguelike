@tool
class_name EnemyEditorScreen
extends Control

@export var name_edit: LineEdit
@export var sprite_label: Label
@export var pick_button: Button
@export var texture_type_options: OptionButton
@export var change_variant_button: Button
@export var texture_preview: AnimatedSprite2D
@export var object_type_button: OptionButton
@export var max_health_box: SpinBox
@export var pushable_check: CheckBox
@export var action_source_type_options: OptionButton
@export var action_source_settings_grids: Array[GridContainer]
@export var speed_boxes: Array[SpinBox]
@export var preview_action_checks: Array[CheckBox]
@export var enemy_action_flow_editor: EnemyActionFlowEditor

var tile_object_data: TileObjectData
var plugin: EnemyEditorPlugin


func _ready() -> void:
	name_edit.text_submitted.connect(_rename)
	pick_button.pressed.connect(_pick_sprite)
	texture_type_options.item_selected.connect(_texture_type_selected)
	change_variant_button.pressed.connect(_change_variant)
	object_type_button.item_selected.connect(_set_object_type)
	max_health_box.value_changed.connect(_set_max_health)
	pushable_check.toggled.connect(_set_pushable)
	action_source_type_options.item_selected.connect(_change_action_source_type)
	
	for i in len(speed_boxes):
		speed_boxes[i].value_changed.connect(_set_speed)
		preview_action_checks[i].toggled.connect(_set_preview_actions)
	
	enemy_action_flow_editor.enemy_editor_screen = self
	
	enemy_action_flow_editor.action_flow_updated.connect(_set_action_flow)


func edit(object: TileObjectData) -> void:
	tile_object_data = object
	
	name_edit.text = object.resource_path.get_file().trim_suffix(".tres").capitalize()
	sprite_label.text = "Sprite: " + object.texture.resource_path.get_file()
	texture_type_options.selected = tile_object_data.texture_type
	
	if tile_object_data.texture_type == TileObjectData.TextureType.VARIANTS:
		change_variant_button.show()
	else:
		change_variant_button.hide()
	
	update_preview_sprite()
	
	object_type_button.selected = tile_object_data.object_type
	max_health_box.value = tile_object_data.max_health
	pushable_check.button_pressed = tile_object_data.pushable
	
	var object_type: int
	if tile_object_data.action_source is NullActionSource:
		object_type = 0
	elif tile_object_data.action_source is MoveActionSource:
		object_type = 1
	elif tile_object_data.action_source is PlayerActionSource:
		object_type = 2
	elif tile_object_data.action_source is EnemyActionSource:
		object_type = 3
		var action_source: EnemyActionSource = tile_object_data.action_source
		enemy_action_flow_editor.action_flow = action_source.action_flow
	
	action_source_type_options.selected = object_type
	
	for i in len(action_source_settings_grids):
		if i == object_type:
			action_source_settings_grids[i].show()
		else:
			action_source_settings_grids[i].hide()
	
	for i in len(speed_boxes):
		speed_boxes[i].value = tile_object_data.action_source.speed
		preview_action_checks[i].button_pressed = tile_object_data.action_source.preview_actions


func _rename(new_name: String) -> void:
	var old_path: String = tile_object_data.resource_path
	DirAccess.remove_absolute(old_path)
	
	var folder: String = old_path.trim_suffix(old_path.get_file())
	var new_path: String = folder + new_name.to_snake_case() + ".tres"
	ResourceSaver.save(tile_object_data, new_path)
	
	tile_object_data = ResourceLoader.load(new_path)
	
	plugin.get_editor_interface().get_resource_filesystem().scan()


func _pick_sprite() -> void:
	var file_dialog := FileDialog.new()
	file_dialog.filters = PackedStringArray(["*.png;Sprites"])
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	add_child(file_dialog)
	
	var selected_path: String = await file_dialog.file_selected
	
	sprite_label.text = "Sprite: " + selected_path.get_file()
	tile_object_data.texture = load(selected_path)
	save_data()
	update_preview_sprite()


func _texture_type_selected(type: int) -> void:
	tile_object_data.texture_type = type
	save_data()
	update_preview_sprite()
	
	if tile_object_data.texture_type == TileObjectData.TextureType.VARIANTS:
		change_variant_button.show()
	else:
		change_variant_button.hide()


func _change_variant() -> void:
	var varient_count: int = tile_object_data.texture.get_height() >> 5
	texture_preview.play(str(randi_range(0, varient_count - 1)))


func _set_object_type(object_type: int) -> void:
	tile_object_data.object_type = object_type
	save_data()


func _set_max_health(max_health: int) -> void:
	tile_object_data.max_health = max_health
	save_data()


func _set_pushable(pushable: bool) -> void:
	tile_object_data.pushable = pushable
	save_data()


func _change_action_source_type(type: int) -> void:
	match type:
		0:
			tile_object_data.action_source = NullActionSource.new()
		1:
			tile_object_data.action_source = MoveActionSource.new()
		2:
			tile_object_data.action_source = PlayerActionSource.new()
		3:
			tile_object_data.action_source = EnemyActionSource.new()
	save_data()
	
	for i in len(action_source_settings_grids):
		if i == type:
			action_source_settings_grids[i].show()
		else:
			action_source_settings_grids[i].hide()
	
	speed_boxes[type].value = tile_object_data.action_source.speed
	preview_action_checks[type].button_pressed = tile_object_data.action_source.preview_actions
	enemy_action_flow_editor.action_flow_type_options.selected = -1


func _set_speed(speed: int) -> void:
	tile_object_data.action_source.speed = speed
	save_data()
	
	for i in len(speed_boxes):
		speed_boxes[i].value = speed


func _set_preview_actions(preview_actions: bool) -> void:
	tile_object_data.action_source.preview_actions = preview_actions
	save_data()
	
	for i in len(preview_action_checks):
		preview_action_checks[i].button_pressed = preview_actions


func _set_action_flow() -> void:
	var action_source: EnemyActionSource = tile_object_data.action_source
	action_source.action_flow = enemy_action_flow_editor.action_flow


func update_preview_sprite() -> void:
	texture_preview.pause()
	texture_preview.sprite_frames = tile_object_data.get_sprite_frames()
	
	match tile_object_data.texture_type:
		TileObjectData.TextureType.ANIMATED:
			texture_preview.play("default")
		TileObjectData.TextureType.VARIANTS:
			var varient_count: int = tile_object_data.texture.get_height() >> 5
			texture_preview.play(str(randi_range(0, varient_count - 1)))
		TileObjectData.TextureType.HEALTH_STATES:
			texture_preview.play("0")


func save_data() -> void:
	ResourceSaver.save(tile_object_data, tile_object_data.resource_path)
