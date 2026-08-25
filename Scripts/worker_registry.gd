# This is an Autoloaded resource file.
# Its main purpose is to provide the functions to add and remove workers from
# the "Employees" menu. 

extends Node

signal employees_changed(workers: Array)

var workers: Array = []

func register(worker: Node) -> void:
	workers.append(worker)
	employees_changed.emit(workers)

func unregister(worker: Node) -> void:
	workers.erase(worker)
	employees_changed.emit(workers)
