extends Node

signal candidates_changed(candidates: Array)
signal worker_hired(worker_name: String, stats: WorkerStats)

const CANDIDATE_COUNT := 3
const COOLDOWN_TIME := 8.0

var candidates: Array = []
var _names: Array[String] = []

func _ready() -> void:
	_names = _load_names()
	for i in CANDIDATE_COUNT:
		candidates.append(_generate_candidate())
	candidates_changed.emit(candidates)

func _load_names() -> Array[String]:
	var names: Array[String] = []
	var file := FileAccess.open("res://Resources/names.json", FileAccess.READ)
	if file == null:
		push_warning("names.json not found, using fallback names")
		return ["Alex", "Sam", "Jordan"]
	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		for n in parsed:
			names.append(str(n))
	else:
		for n in content.split(","):
			names.append(n.strip_edges())
	return names

func _generate_candidate() -> Dictionary:
	var stats := WorkerStats.new()
	stats.efficiency = randf()
	stats.risk = randf()
	return {
		"name": _names[randi() % _names.size()],
		"stats": stats,
	}

func hire(index: int) -> void:
	var candidate = candidates[index]
	if candidate == null:
		return
	worker_hired.emit(candidate["name"], candidate["stats"])
	candidates[index] = null
	candidates_changed.emit(candidates)
	_start_cooldown(index)

func _start_cooldown(index: int) -> void:
	await get_tree().create_timer(COOLDOWN_TIME).timeout
	candidates[index] = _generate_candidate()
	candidates_changed.emit(candidates)
