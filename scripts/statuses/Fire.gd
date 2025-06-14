class_name FireStatus
extends OreStatus

func do_vfx() -> void:
	var scene: PackedScene = load("res://scenes/particles/fire_particles.tscn");
	var particles: CPUParticles2D = scene.instantiate()
	self.ore.add_child(particles)
	self.vfx.append(particles)

func do_effect() -> void:
	self.ore.queue_free()
	GameData.ore_count -= 1

func _on_timer_timeout() -> void:
	do_effect()
