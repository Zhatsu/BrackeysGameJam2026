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

# level_main.gd
func _spawn_worker() -> void:
	var worker = worker_scene.instantiate()
	add_child(worker)
	var entrance := get_poi(POIData.POIType.ENTRANCE)
	worker.global_position = entrance.global_position

	var loop_pois: Array[PointOfInterest] = []
	for type in poi_by_type.keys():
		if type != POIData.POIType.ENTRANCE:
			loop_pois.append(poi_by_type[type])

	worker.start_route(loop_pois)
	
func _ready() -> void:
	_register_pois()
	_spawn_worker()
