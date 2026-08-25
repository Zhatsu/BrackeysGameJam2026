# res://scripts/level_main.gd
extends Node2D

#@export var Worker: PackedScene
# Use load() instead of preload() if the path isn't known at compile-time.
@export var worker_scene = preload("res://Scenes/Worker.tscn")
# Add the node as a child of the node the script is attached to.
var poi_by_type: Dictionary = {}  # POIData.POIType -> PointOfInterest

# Adds the POI's into the scene tree
func _register_pois() -> void:
	for poi in get_tree().get_nodes_in_group("poi"):
		print(poi.name, " | resource id: ", poi.data.get_instance_id(), " | poi_type: ", poi.data.poi_type)
		poi_by_type[poi.get_type()] = poi
	print("Total POIs registered: ", poi_by_type.size())

func get_poi(type: POIData.POIType) -> PointOfInterest:
	return poi_by_type.get(type)

func _on_worker_hired(worker_name: String = "Worker", stats:WorkerStats = null) -> void:
	_spawn_worker(worker_name, stats)

func _spawn_worker(worker_name: String = "Worker", stats: WorkerStats = null) -> void:
	var worker = worker_scene.instantiate()
	worker.name = worker_name
	worker.stats = stats
	add_child(worker)
	var entrance := get_poi(POIData.POIType.ENTRANCE)
	worker.global_position = entrance.global_position

	var loop_pois: Array[PointOfInterest] = []
	for type in poi_by_type.keys():
		if type != POIData.POIType.ENTRANCE:
			loop_pois.append(poi_by_type[type])

	worker.start_route(loop_pois)
	
func _load_names() -> Array[String]:
	var names: Array[String] = []
	var file := FileAccess.open("res://Resources/names.json", FileAccess.READ)
	if file == null:
		push_warning("names.json not found. Using spare names instead")
		return ["klynn", "Denji-san", "JOHN DAMAGE"]
	var content := file.get_as_text()
	var parsed = JSON.parse_string(content)
	if parsed is Array:
		for n in parsed:
			names.append(str(n))
	else:
		for n in content.split(","):
			names.append(n.strip_edges())
	return names

func _ready() -> void:
	_register_pois()
	HireManager.worker_hired.connect(_on_worker_hired)
