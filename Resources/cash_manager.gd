extends Node

signal cash_changed(new_total: int)

var cash: int = 0

func add_cash(amount: int) -> void:
	cash += amount
	cash_changed.emit(cash)
