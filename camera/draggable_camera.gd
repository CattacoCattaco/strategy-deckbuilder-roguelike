class_name DraggableCamera
extends Camera2D

@export var tile_grid: TileGrid


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var scale_factor: Vector2 = tile_grid.scale
			
			position -= event.relative / scale_factor
			
			if tile_grid:
				fit_pos_to_bounds(tile_grid.get_camera_bounds())


func fit_pos_to_bounds(bounds: Rect2) -> void:
	var half_view_size: Vector2 = get_viewport_rect().size / 2
	var view_top_left: Vector2 = position - half_view_size
	var view_bottom_right: Vector2 = position + half_view_size
	
	var bounds_top_left: Vector2 = bounds.position
	var bounds_bottom_right: Vector2 = bounds.position + bounds.size
	
	if view_top_left.x < bounds_top_left.x and view_bottom_right.x > bounds_bottom_right.x:
		position.x = 0
	elif view_top_left.x < bounds_top_left.x:
		position.x += (bounds_top_left - view_top_left).x
	elif view_bottom_right.x > bounds_bottom_right.x:
		position.x += (bounds_bottom_right - view_bottom_right).x
	
	if view_top_left.y < bounds_top_left.y and view_bottom_right.y > bounds_bottom_right.y:
		position.y = 0
	elif view_top_left.y < bounds_top_left.y:
		position.y += (bounds_top_left - view_top_left).y
	elif view_bottom_right.y > bounds_bottom_right.y:
		position.y += (bounds_bottom_right - view_bottom_right).y
