class_name Quest
extends Resource

# Quest properties
# @export var id: int
@export var type: int
@export var reward: float
@export var progress: float = 0.0
@export var goal: float = 0.0

# Check if the quest is completed
func is_completed() -> bool:
	return progress >= 1.0

# Update quest progress
func update_progress(value: float):
	progress = clamp(value, 0.0, 1.0)

func get_quest_name(time_elapsed: float = 0) -> String:
	var minutes = time_elapsed / 60
	var seconds = fmod(time_elapsed, 60)
	match type:
		1: return "Rebirth %s times" % (self.goal)
		2: return "Reach $%s" % (GameData.float_to_prefix(self.goal))
		3: return "Rebirth in %.0f minutes (%s)" % [
			self.goal / 60,
			"%02d:%02d" % [minutes, seconds]
		]
		4: return "Play for %s minutes (%s)" % [
			GameData.float_to_prefix(self.goal / 60.0),
			"%02d:%02d" % [minutes, seconds]
		]

	return "Unknown Quest"