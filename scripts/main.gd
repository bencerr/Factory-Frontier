extends Node

@export var tile_map: TileMap

func _ready() -> void:
	$ConveyorAnimationSync.play()

func _on_tile_map_ready() -> void:
	Player.tile_map_loaded.emit(tile_map)

func _on_save_timer_timeout() -> void:
	SaveHandler.save_data(Player.data)