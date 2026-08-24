# res://scripts/worker.gd
extends CharacterBody2D

enum State { IDLE, MOVING, WORKING }

@export var move_speed: float = 100.0
@export var stats: WorkerStats

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var _available_pois: Array[PointOfInterest] = []
var _current_target: PointOfInterest
var _state: State = State.IDLE

func _ready() -> void:
	nav_agent.max_speed = move_speed
	nav_agent.velocity_computed.connect(_on_velocity_computed)

func start_route(pois: Array[PointOfInterest]) -> void:
	_available_pois = pois
	await get_tree().physics_frame
	_advance_route()

## Decision function — this is the one place that will grow
## to account for job, traitor status, and efficiency later.
## For now: simple round-robin, never immediately re-picking
## wherever we just were.
func _choose_next_poi() -> PointOfInterest:
	var candidates := _available_pois.filter(func(p): return p != _current_target)
	if candidates.is_empty():
		candidates = _available_pois
	return candidates[randi() % candidates.size()]

func _advance_route() -> void:
	_current_target = _choose_next_poi()
	nav_agent.target_position = _current_target.global_position
	_state = State.MOVING

## Also isolated, so efficiency can scale it without touching
## anything else.
func _get_wait_time() -> float:
	var base_time := _current_target.data.wait_time
	if stats:
		return base_time * (1.5 - stats.efficiency)  # tune this curve later
	return base_time

func _physics_process(_delta: float) -> void:
	if _state != State.MOVING:
		return
	if nav_agent.is_navigation_finished():
		_arrive_at_poi()
		return
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_pos)
	nav_agent.set_velocity(direction * move_speed)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _arrive_at_poi() -> void:
	_state = State.WORKING
	await get_tree().create_timer(_get_wait_time()).timeout
	_advance_route()
