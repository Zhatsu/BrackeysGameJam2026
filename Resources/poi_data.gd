class_name POIData
extends Resource

enum POIType { ENTRANCE, WORKSTATION, BREAK_ROOM, LOITER_ZONE,  }

@export var poi_type: POIType
@export var poi_name: String = ""
@export var wait_time: float = 2.0
@export var capacity: int = 1
@export var cash_per_job: int = 10
