extends Area2D
class_name Furnace
@export var item_data: ItemData
@export var label_scene: PackedScene

func money_vfx(value: float) -> void:
	var control: Control = label_scene.instantiate()
	add_child(control)
	control.get_node("Label").text = "+" + str(value)
	var pos: Vector2 = Vector2(randf_range(-9, 9), randf_range(-2, -6))
	control.position += pos
	var tween: Tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(control, "position", control.position + Vector2(0, -10.0), 1.25)
	tween.tween_property(control, "modulate", Color.TRANSPARENT, 1.25)
	tween.finished.connect(control.queue_free)

func process_item(ore: Ore) -> void:
	var ore_value: float = ore.value
	$AudioStreamPlayer2D.play()
	$CPUParticles2D.emitting = true
	Player.add_money(ore_value)
	money_vfx(ore_value)
	ore.queue_free()

func can_recieve_item():
	return true

func recieve_item(ore: Ore) -> void:
	$ItemHolder.recieve_item(ore)

func _on_item_holder_item_held(ore: Ore) -> void:
	process_item(ore)

func _on_cpu_particles_2d_finished() -> void:
	$CPUParticles2D.emitting = false