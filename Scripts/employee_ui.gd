# res://scripts/employee_ui.gd
extends CanvasLayer

@onready var toggle_button: Button = $EmployeesButton
@onready var panel: PanelContainer = $EmployeePanel
@onready var list_container: VBoxContainer = $EmployeePanel/VBoxContainer

var _highlighted_worker: Node2D = null

func _ready() -> void:
	panel.visible = false
	toggle_button.pressed.connect(func(): UIManager.toggle_panel(panel))
	WorkerRegistry.employees_changed.connect(_refresh_list)
	_refresh_list(WorkerRegistry.workers)

func _refresh_list(workers: Array) -> void:
	for child in list_container.get_children():
		child.queue_free()

	for worker in workers:
		var row := Button.new()
		var eff := 0
		var risk := 0
		if worker.stats:
			eff = round(worker.stats.efficiency * 10)
			risk = round(worker.stats.risk * 10)
		row.text = "%s   Eff: %d/10   Risk: %d/10" % [worker.name, eff, risk]
		row.pressed.connect(_on_employee_selected.bind(worker))
		list_container.add_child(row)

func _on_employee_selected(worker: Node2D) -> void:
	if _highlighted_worker and is_instance_valid(_highlighted_worker):
		_highlighted_worker.set_highlighted(false)

	worker.set_highlighted(true)
	_highlighted_worker = worker

	var cam := get_tree().get_first_node_in_group("game_camera")
	if cam:
		cam.follow_worker(worker)
