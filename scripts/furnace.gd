class_name Furnace
extends Area2D

@export var item_data: ItemData
@export var label_scene: PackedScene
@export var mult: float = 1

func money_vfx(value: float) -> void:
	var control: Control = label_scene.instantiate()
	get_node("/root/Main").add_child(control)
	control.get_node("Label").text = "+" + str(value)
	var pos: Vector2 = Vector2(randf_range(-9, 9), randf_range(-8, -12))
	control.position = get_node("Sprite2D").global_position
	control.position += pos
	var tween: Tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(control, "position", control.position + Vector2(0, -20.0), 1.25)
	tween.tween_property(control, "modulate", Color.TRANSPARENT, 1.5)
	tween.finished.connect(control.queue_free)

func process_item(ore: Ore) -> void:
	var ore_value: float = ore.value
	$AudioStreamPlayer2D.play()
	$CPUParticles2D.emitting = true
	var sell_value: float = ore_value * mult
	Player.add_money(sell_value)
	money_vfx(sell_value)
	GameData.ore_count -= 1
	ore.queue_free()

func can_recieve_item() -> bool:
	return true

func recieve_item(ore: Ore) -> void:
	$ItemHolder.recieve_item(ore)

func _on_item_holder_item_held(ore: Ore) -> void:
	process_item(ore)

func _on_cpu_particles_2d_finished() -> void:
	$CPUParticles2D.emitting = false