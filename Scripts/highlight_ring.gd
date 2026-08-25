# Handles creating the highlight ring around the Worker when selected.
# Simply allows you to change the color and adjust the size.

extends Node2D

@export var radius: float = 20.0
@export var ring_color: Color = Color.YELLOW

func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, ring_color, 2.0)
