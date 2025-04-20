extends Control

var main_scene_path := "res://scenes/main.tscn"

var main_node: Node


func _ready() -> void:
	var main_scene: PackedScene = load(main_scene_path)
	main_node = main_scene.instantiate()
	print(hash("Mega Diamond Dropper"))

func _on_button_pressed() -> void:
	get_node("/root").add_child(main_node)
	self.get_parent().remove_child(self)
	main_node.get_node("CanvasLayer").add_child(self)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property($Panel, "modulate", Color.TRANSPARENT, 2)
	#tween.tween_property($Panel, "position", Vector2($Panel.size.x, 0), 2)
	tween.play()

	await tween.finished

	queue_free()
