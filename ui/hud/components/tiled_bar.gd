tool
extends Control

export (Texture) var texture : Texture setget set_texture
export (Vector2) var texture_region : Vector2 setget set_texture_region
export (int, 1, 16) var max_value : int = 1 setget set_max_value
export (Color) var color : Color setget set_color

var current_value : int = 0 setget set_current_value

func _draw() -> void:
	if !texture:
		return
	
	var offset = Vector2.ZERO
	for i in range(max_value):
		var i_texture_region = Rect2(Vector2.ZERO, texture_region)
		if i >= current_value:
			i_texture_region.position.x += texture_region.x
		var i_color = color if i < current_value else Color.white
		
		draw_texture_rect_region(texture, Rect2(offset, texture_region), i_texture_region, i_color)
		offset.x += texture_region.x

func set_texture(new_texture : Texture) -> void:
	texture = new_texture
	update()

func set_texture_region(value : Vector2) -> void:
	texture_region = value
	update()

func set_max_value(value : int) -> void:
	max_value = value
	rect_min_size.x = texture_region.x * max_value
	rect_size.x = texture_region.x * max_value
	update()

func set_current_value(value : int) -> void:
	current_value = value
	update()

func set_color(value : Color) -> void:
	color = value
	update()