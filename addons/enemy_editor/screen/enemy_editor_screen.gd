@tool
class_name EnemyEditorScreen
extends Control

@export var name_edit: LineEdit

var tile_object_data: TileObjectData
var plugin: EnemyEditorPlugin


func _ready() -> void:
	name_edit.text_submitted.connect(rename)


func edit(object: TileObjectData) -> void:
	tile_object_data = object
	name_edit.text = object.resource_path.get_file().trim_suffix(".tres").capitalize()


func rename(new_name: String) -> void:
	var old_path: String = tile_object_data.resource_path
	DirAccess.remove_absolute(old_path)
	
	var folder: String = old_path.trim_suffix(old_path.get_file())
	var new_path: String = folder + new_name.to_snake_case() + ".tres"
	ResourceSaver.save(tile_object_data, new_path)
	
	tile_object_data = ResourceLoader.load(new_path)
	
	plugin.get_editor_interface().get_resource_filesystem().scan()


func save_data() -> void:
	ResourceSaver.save(tile_object_data, tile_object_data.resource_path)
