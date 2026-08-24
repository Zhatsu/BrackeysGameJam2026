# res://Resources/worker_stats.gd
class_name WorkerStats
extends Resource

@export_range(0.0, 1.0) var efficiency: float = 0.5
@export_range(0.0, 1.0) var risk: float = 0.5

var is_traitor: bool = false

func roll_traitor() -> void:
	is_traitor = randf() < risk
