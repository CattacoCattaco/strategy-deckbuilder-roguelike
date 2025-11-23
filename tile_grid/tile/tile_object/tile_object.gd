@tool
class_name TileObject
extends Node2D

@export var sprite: AnimatedSprite2D
@export var data: TileObjectData:
	set(value):
		data = value
		load_sprite_anim()


func load_sprite_anim() -> void:
	if not sprite:
		return
	
	sprite.sprite_frames = data.get_sprite_frames()
	
	sprite.play("default")
