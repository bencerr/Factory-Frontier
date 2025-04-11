class_name PlayerData
extends Resource

@export var money: float = 0
@export var rebirths: int = 0
@export var inventory: Dictionary
@export var placed_items: Array[PlacedItemData]
@export var ore_limit_index: int = 0
@export var buffs: Array[Buff]
@export var base_level: int = 0
@export var new_player: bool = true
