@tool
class_name TileObjectData
extends Resource
## A resource which stores the properties of an object

## The fps of all animations
static var fps: float = 1.25

## The texture of this object [br][br]
## [b]NOTE[/b]: texture should be 32px tall and (32 * frame count)px wide,
## with each frame being 32px wide
@export var texture: Texture2D
## The maximum health that this object can be at [br][br]
## If [param max_health] is -1, this object will not use health and can't be targeted
@export var max_health: int = -1
## What does this object do?
@export var action_source: ActionSource


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
