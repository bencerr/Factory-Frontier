class_name Furnace
extends Area2D

@export var item_data: ItemData
@export var label_scene: PackedScene
@export var mult: float = 1

func money_vfx(value: float) -> void:
	var lbl: Label = label_scene.instantiate()
	lbl.text = "+" + GameData.float_to_prefix(value)
	var pos: Vector2 = Vector2(randf_range(-10, 10), randf_range(-8, -12))
	get_node("/root/Main/").add_child(lbl)
	lbl.position = global_position - lbl.pivot_offset + pos

	var tween: Tween = get_tree().create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(lbl, "position", lbl.position + Vector2(0, -10.0), .6)
	tween.tween_property(lbl, "modulate", Color.TRANSPARENT, .6)
	tween.finished.connect(lbl.queue_free)

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