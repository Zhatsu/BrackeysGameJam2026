# res://scripts/game_camera.gd
extends Camera2D

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.5   # zoomed out (see more map)
@export var max_zoom: float = 2.0   # zoomed in
@export var zoom_smoothness: float = 8.0

@export var pan_speed: float = 800.0
@export var edge_pan_margin: float = 20.0  # px from screen edge to trigger pan; 0 disables edge-pan
@export var use_edge_pan: bool = false

@export var use_drag_pan: bool = true
@export var drag_button: MouseButton = MOUSE_BUTTON_MIDDLE

@export var follow_smoothness: float = 6.0
var _follow_target: Node2D = null

#@export var limit_enabled: bool = false
@export var map_limit_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(2000, 2000))

var _target_zoom: Vector2 = Vector2.ONE
var _dragging: bool = false

func _ready() -> void:
	_target_zoom = zoom
	if limit_enabled:
		limit_left = int(map_limit_rect.position.x)
		limit_top = int(map_limit_rect.position.y)
		limit_right = int(map_limit_rect.position.x + map_limit_rect.size.x)
		limit_bottom = int(map_limit_rect.position.y + map_limit_rect.size.y)
	add_to_group("game_camera")

func _process(delta: float) -> void:
	zoom = zoom.lerp(_target_zoom, delta * zoom_smoothness)
	_handle_keyboard_pan(delta)
	if use_edge_pan:
		_handle_edge_pan(delta)
	
	# Ensures the target can be followed, then disables the zoom if panned away
	if _follow_target and is_instance_valid(_follow_target):
		global_position = global_position.lerp(_follow_target.global_position, delta * follow_smoothness)
	else:
		_handle_keyboard_pan(delta)
		if use_edge_pan:
			_handle_edge_pan(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(get_global_mouse_position(), 1.0 + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(get_global_mouse_position(), 1.0 - zoom_speed)
		elif event.button_index == drag_button:
			_dragging = event.pressed
		elif event.button_index == drag_button:
			_dragging = event.pressed
			if event.pressed:
				_follow_target = null

	elif event is InputEventMouseMotion and _dragging and use_drag_pan:
		global_position -= event.relative / zoom

func _zoom_at(_mouse_world_pos: Vector2, factor: float) -> void:
	var new_zoom: Vector2 = (_target_zoom * factor).clamp(Vector2(min_zoom, min_zoom), Vector2(max_zoom, max_zoom))
	_target_zoom = new_zoom

func _handle_keyboard_pan(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if dir != Vector2.ZERO:
		_follow_target = null
		global_position += dir.normalized() * pan_speed * delta / zoom.x

func _handle_edge_pan(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var mouse_pos := get_viewport().get_mouse_position()
	var dir := Vector2.ZERO

	if mouse_pos.x < edge_pan_margin:
		dir.x -= 1
	elif mouse_pos.x > viewport_size.x - edge_pan_margin:
		dir.x += 1
	if mouse_pos.y < edge_pan_margin:
		dir.y -= 1
	elif mouse_pos.y > viewport_size.y - edge_pan_margin:
		dir.y += 1

	if dir != Vector2.ZERO:
		global_position += dir.normalized() * pan_speed * delta / zoom.x

# Function to allow the camera to follow the target being selected
func follow_worker(target: Node2D) -> void:
	_follow_target = target
