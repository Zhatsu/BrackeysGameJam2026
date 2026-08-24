class_name PointOfInterest
extends StaticBody2D

@export var data: POIData

@onready var polygon_2d = $Polygon2D
@onready var collision_polygon_2d = $CollisionPolygon2D

func _ready() -> void:
	add_to_group("poi")
	collision_polygon_2d.polygon = polygon_2d.polygon

func get_type() -> POIData.POIType:
	return data.poi_type
