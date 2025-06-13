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
@export var gems: int = 0;
@export var quest_assigned_date: Dictionary
@export var quests: Array[Quest] = []
@export var time_in_rebirth: float = 0.0