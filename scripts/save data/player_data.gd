extends Resource
class_name PlayerData

@export var money: float
@export var inventory: Dictionary # Dict<item_id: (int), PlayerItemInfo>
@export var placed_items: Array[PlacedItemData] # Dictionary<Vec2i, PlacedItemData>