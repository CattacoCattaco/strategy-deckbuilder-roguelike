@tool
class_name TileObjectData
extends Resource
## A resource which stores the properties of an object

## How the sprites of the texture are interpreted
enum TextureType {
	## The x axis = time, doesn't use y axis
	ANIMATED,
	## The x axis = time, y axis = varients
	VARIANTS,
	## The x axis = time, y axis = health
	HEALTH_STATES,
}

## What type of object is this?
enum ObjectType {
	## Doesn't do things
	STATIC,
	## Player
	PLAYER,
	## Enemy
	ENEMY,
	## Needs to be protected
	DEFENDABLE,
}

## The fps of all animations
static var fps: float = 1.25

## The texture of this object [br][br]
## [b]NOTE[/b]: Each sprite should be 32px by 32px
@export var texture: Texture2D
## Determines how the sprites of the texture are interpreted
@export var texture_type: TextureType
## Determines what kind of object this is
@export var object_type: ObjectType
## The maximum health that this object can be at [br][br]
## If [param max_health] is -1, this object will not use health and can't be targeted
@export var max_health: int = -1
## What does this object do?
@export var action_source: ActionSource


func _init(p_texture: Texture2D = null, p_texture_type: TextureType = TextureType.ANIMATED, 
		p_object_type: ObjectType = ObjectType.STATIC, p_max_health: int = -1,
		p_action_source: ActionSource = NullActionSource.new()) -> void:
	texture = p_texture
	texture_type = p_texture_type
	object_type = p_object_type
	max_health = p_max_health
	action_source = p_action_source


func get_sprite_frames() -> SpriteFrames:
	match texture_type:
		TextureType.ANIMATED:
			return get_animated_sprite_frames()
		TextureType.VARIANTS:
			return get_varient_sprite_frames()
		TextureType.HEALTH_STATES:
			return get_health_state_sprite_frames()
	
	return get_animated_sprite_frames()


func get_animated_sprite_frames() -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	
	add_animation_to_sprite_frames(0, "default", sprite_frames)
	
	return sprite_frames


func get_varient_sprite_frames() -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	
	var varient_count: int = texture.get_height() >> 5
	
	for i in range(varient_count):
		add_animation_to_sprite_frames(i, str(i), sprite_frames)
	
	return sprite_frames


func get_health_state_sprite_frames() -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	
	var state_count: int = texture.get_height() >> 5
	
	for i in range(state_count):
		add_animation_to_sprite_frames(i, str(i), sprite_frames)
	
	return sprite_frames


func add_animation_to_sprite_frames(y: int, anim_name: String, sprite_frames: SpriteFrames) -> void:
	# Each frame is 32 pixels wide so frame count = width / 32 = width >> 5
	var frame_count: int = texture.get_width() >> 5
	
	if not sprite_frames.has_animation(anim_name):
		sprite_frames.add_animation(anim_name)
	
	for i in range(frame_count):
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region.size = Vector2(32, 32)
		atlas_texture.region.position = Vector2(i << 5, y << 5)
		
		sprite_frames.add_frame(anim_name, atlas_texture)
	
	sprite_frames.set_animation_speed(anim_name, fps)
