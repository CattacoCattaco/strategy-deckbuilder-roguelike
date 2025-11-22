@tool
class_name TileObjectData
extends Resource

static var fps: float = 1.25

@export var texture: Texture2D


func get_sprite_frames() -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	# Each frame is 32 pixels wide so frame count = width / 32 = width >> 5
	var frame_count: int = texture.get_width() >> 5
	
	for i in range(frame_count):
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region.size = Vector2(32, 32)
		atlas_texture.region.position = Vector2(i << 5, 0)
		
		sprite_frames.add_frame("default", atlas_texture)
	
	sprite_frames.set_animation_speed("default", fps)
	
	return sprite_frames
