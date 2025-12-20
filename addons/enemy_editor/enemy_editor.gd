@tool
class_name EnemyEditorPlugin
extends EditorPlugin

const EDITOR_SCREEN: PackedScene = preload(
		"res://addons/enemy_editor/screen/enemy_editor_screen.tscn")

var editor_screen: EnemyEditorScreen


func _enter_tree() -> void:
	editor_screen = EDITOR_SCREEN.instantiate()
	editor_screen.plugin = self
	get_editor_interface().get_editor_main_screen().add_child(editor_screen)
	editor_screen.hide()


func _exit_tree() -> void:
	editor_screen.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if visible:
		editor_screen.show()
	else:
		editor_screen.hide()


func _handles(object: Object) -> bool:
	return object is TileObjectData


func _edit(object: Object) -> void:
	if not object is TileObjectData:
		return
	
	editor_screen.edit(object)


func _get_plugin_icon() -> Texture2D:
	return get_editor_interface().get_base_control().get_theme_icon("Node", "EditorIcons")


func _get_plugin_name() -> String:
	return "TileObject Editor"
