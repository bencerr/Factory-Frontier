extends Control

var current_step = 0
var total_steps = 3

func update_graphic() -> void:
	var child = self.get_child(current_step)
	if child != null:
		for c in self.get_children():
			c.visible = false
		child.visible = true
	else:
		return

func advance_tutorial() -> void:
	current_step = min(current_step+1, total_steps)
	update_graphic()

func retreat_tutorial() -> void:
	current_step = max(current_step-1, 0)
	update_graphic()

func _ready() -> void:
	if Player.data.new_player:
		self.show()
	else:
		self.hide()

func _on_button_pressed() -> void:
	self.hide()
	Player.data.new_player = false

func _on_button_2_pressed() -> void:
	advance_tutorial()

func _on_button_3_pressed() -> void:
	retreat_tutorial()
