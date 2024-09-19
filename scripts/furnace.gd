extends Area2D
class_name Furnace
@export var item_data: ItemData

func process_item(item: Node2D) -> void:
    var ore_value: float = item.get_meta("value")
    $AudioStreamPlayer2D.play()
    Player.add_money(ore_value)
    item.queue_free()

func can_recieve_item():
    return true

func recieve_item(item: Node2D) -> void:
    $ItemHolder.recieve_item(item)

func _on_item_holder_item_held() -> void:
    process_item($ItemHolder.offload_item())
