# res://scripts/worker.gd
extends CharacterBody2D

enum State { IDLE, MOVING, WORKING }

@export var move_speed: float = 100.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var _route: Array[PointOfInterest] = []
var _current_target: PointOfInterest
var _state: State = State.IDLE

func _ready() -> void:
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	print("nav agent ready, computed: ", nav_agent.distance_to_target())

func start_route(points: Array[PointOfInterest]) -> void:
	print("Worker starting route")
	print("This is the list of POI's: ", POIData.POIType)
	_route = points.duplicate()
	await get_tree().physics_frame
	_advance_route()

func _advance_route() -> void:
	if _route.is_empty():
		_state = State.IDLE
		print("WORKER IS IDLE")
		return
	while _route:
		print("Currently in the while loop")
		#_route.pop_front()
		print("Worker advancing route to: ", POIData.POIType)
		_current_target = _route.pop_front()
		print("After advancing actually lol", _current_target, POIData.POIType)
		nav_agent.target_position = _current_target.global_position
		_state = State.MOVING
		print("This is the current state: ", _state, "towards", _current_target)


func _physics_process(_delta: float):
	print("state: ", _state, " finished: ", nav_agent.is_navigation_finished() if _state == State.MOVING else "n/a")

	if _state != State.MOVING:
		print("Not moving")
		# should possibly change return to pass?
		return
	if nav_agent.is_navigation_finished():
		print("Before reaching POI")
		await _arrive_at_poi()
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_pos)
	nav_agent.set_velocity(direction * move_speed)
	
func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _arrive_at_poi():
	_state = State.WORKING
	print("Here is the state: ", _state)
	print("Here is the location: ", _current_target.name)
	await get_tree().create_timer(_current_target.data.wait_time).timeout
	print("Reached POI")
	_advance_route()
