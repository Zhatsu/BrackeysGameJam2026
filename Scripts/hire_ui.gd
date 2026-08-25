extends CanvasLayer

@onready var hire_button: Button = $HireButton
@onready var panel: PanelContainer = $CandidatePanel
@onready var slots: Array[Control] = [
	$CandidatePanel/VBoxContainer/Slot1/Control,
	$CandidatePanel/VBoxContainer/Slot2/Control,
	$CandidatePanel/VBoxContainer/Slot3/Control
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel.visible = false
	hire_button.pressed.connect(func(): UIManager.toggle_panel(panel))
	HireManager.candidates_changed.connect(_refresh_slots)
	for i in slots.size():
		slots[i].get_node("HireButton").pressed.connect(func(): HireManager.hire(i))
	_refresh_slots(HireManager.candidates)

func _refresh_slots(candidates: Array) -> void:
	for i in candidates.size():
		var candidate = candidates[i]
		var slot = slots[i]
		var slot_hire_button: Button = slot.get_node("HireButton")
		
		if candidate == null:
			slot.get_node("NameLabel").text = "..."
			slot.get_node("EfficiencyLabel").text = ""
			slot.get_node("RiskLabel").text = ""
			slot_hire_button.disabled = true
		else:
			var stats: WorkerStats = candidate["stats"]
			slot.get_node("NameLabel").text = candidate["name"]
			slot.get_node("EfficiencyLabel").text = "Eff: %d/10" % round(stats.efficiency * 10)
			slot.get_node("RiskLabel").text = "Risk: %d/10" % round(stats.risk * 10)
			slot_hire_button.disabled = false
