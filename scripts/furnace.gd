extends Area2D
class_name Furnace
@export var item_data: ItemData

func process_item(ore: Ore) -> void:
	var ore_value: float = ore.value
	$AudioStreamPlayer2D.play()
	$CPUParticles2D.emitting = true
	Player.add_money(ore_value)
	ore.queue_free()

func can_recieve_item():
	return true

func recieve_item(ore: Ore) -> void:
	$ItemHolder.recieve_item(ore)

func _on_item_holder_item_held(ore: Ore) -> void:
	process_item(ore)

func _on_cpu_particles_2d_finished() -> void:
	$CPUParticles2D.emitting = false