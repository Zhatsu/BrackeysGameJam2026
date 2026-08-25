# Handles the opening and closing of the menus.
# Called in hire_ui.gd and employee_ui.gd in the _ready function.
extends Node

var _open_panel: Control = null

func open_panel(panel: Control) -> void:
	if _open_panel and is_instance_valid(_open_panel) and _open_panel != panel:
		_open_panel.visible = false
	_open_panel = panel
	panel.visible = true

func close_panel(panel: Control) -> void:
	panel.visible = false
	if _open_panel == panel:
		_open_panel = null

func toggle_panel(panel: Control) -> void:
	if panel.visible:
		close_panel(panel)
	else:
		open_panel(panel)
