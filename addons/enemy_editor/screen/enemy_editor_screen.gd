@tool
class_name EnemyEditorScreen
extends Control

@export var name_edit: LineEdit
@export var sprite_label: Label
@export var pick_button: Button
@export var texture_type_options: OptionButton
@export var change_variant_button: Button
@export var texture_preview: AnimatedSprite2D

var tile_object_data: TileObjectData
var plugin: EnemyEditorPlugin


func _ready() -> void:
	name_edit.text_submitted.connect(_rename)
	pick_button.pressed.connect(_pick_sprite)
	texture_type_options.item_selected.connect(_texture_type_selected)
	change_variant_button.pressed.connect(_change_variant)


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
