extends Label

func _ready() -> void:
	CashManager.cash_changed.connect(_on_cash_changed)
	_on_cash_changed(CashManager.cash)

func _on_cash_changed(new_total: int) -> void:
	text = " $%d" % new_total
