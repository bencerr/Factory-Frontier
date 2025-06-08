extends Control

var main_scene_path := "res://scenes/main.tscn"

var main_node: Node


func _ready() -> void:
	var main_scene: PackedScene = load(main_scene_path)
	main_node = main_scene.instantiate()

func _on_button_pressed() -> void:
	get_node("/root").add_child(main_node)
	self.get_parent().remove_child(self)
	main_node.get_node("CanvasLayer").add_child(self)

	queue_free()
