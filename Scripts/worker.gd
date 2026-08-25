# res://scripts/worker.gd
extends CharacterBody2D

enum State { IDLE, MOVING, WORKING }

#@export var move_speed: float = 100.0
@export var move_speed: float = 100.0
@export var stats: WorkerStats

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var work_bar: ProgressBar = $WorkProgressBar

@onready var highlight_ring: Node2D = $HighlightRing

var _available_pois: Array[PointOfInterest] = []
var _current_target: PointOfInterest
var _state: State = State.IDLE

func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.max_speed = _effective_speed()
	work_bar.visible = false
	# This handles registering a Worker when it spawns and removal if it dies.
	WorkerRegistry.register(self)
	tree_exiting.connect(func(): WorkerRegistry.unregister(self))
	# Enables the highlight ring, set by func "set_highlighted"
	highlight_ring.visible = false

func _effective_speed() -> float:
	if stats:
		# efficiency 0 -> 0.7x speed, efficiency 1 -> 1.3x speed
		return move_speed * lerp(0.7, 1.3, stats.efficiency)
	return move_speed
	
func set_highlighted(state: bool) -> void:
	highlight_ring.visible = state

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
	nav_agent.set_velocity(direction * _effective_speed())

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()

func _arrive_at_poi() -> void:
	_state = State.WORKING
	var duration := _get_work_duration()
	if _current_target.get_type() == POIData.POIType.WORKSTATION:
		await _perform_work(duration)
	else:
		await get_tree().create_timer(duration).timeout
	_advance_route()
	
func _perform_work(duration: float) -> void:
	work_bar.value = 0
	work_bar.visible = true

	var tween := create_tween()
	tween.tween_property(work_bar, "value", work_bar.max_value, duration)
	await tween.finished

	work_bar.visible = false
	CashManager.add_cash(_current_target.data.cash_per_job)
	
func _get_work_duration() -> float:
	var base_time := _current_target.data.wait_time
	if stats:
		return base_time * lerp(1.0, 0.3, stats.efficiency)  # efficiency 1.0 -> 30% of base time, not 0. Have to prevent the ability for a worker to do instant work.
	return base_time
