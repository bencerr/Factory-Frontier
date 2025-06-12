class_name Quest
extends Resource

# Quest properties
# @export var id: int
@export var type: int
@export var reward: float
@export var progress: float = 0.0
@export var goal: int

# Initialize the quest with given parameters
func _init(t: int, r: float, g: int = 0):
	self.type = t
	self.reward = r
	self.progress = 0.0
	self.goal = g
	# self.id = randi() % 1000000  # Random ID for the quest

# Check if the quest is completed
func is_completed() -> bool:
	return progress >= 1.0

# Update quest progress
func update_progress(value: float):
	progress = clamp(progress + value, 0.0, 1.0)

func get_quest_name() -> String:
	match type:
		1: return "Rebirth %s times" % (self.goal)
		2: return "Reach $%s" % (GameData.float_to_prefix(self.goal))
		3: return "Rebirth in %s minutes" % (self.goal)
		4: return "Play for %s minutes" % ( GameData.float_to_prefix(self.goal / 60.0) )

	return "Unknown Quest"