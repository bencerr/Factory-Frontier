class_name QuestManager
extends Node

enum QUESTTYPE {
	REBIRTH = 1,
	REACH_MONEY = 2,
	REBIRTH_TIME = 3,
	PLAY_TIME = 4
}

# Quest templates
static var quest_templates = [
	{"type": QUESTTYPE.PLAY_TIME, "reward": 5.0, "goal": 600},
	{"type": QUESTTYPE.REBIRTH, "reward": 10.0, "goal": 1},
	{"type": QUESTTYPE.REACH_MONEY, "reward": 20.0, "goal": 1e9},
	{"type": QUESTTYPE.REBIRTH_TIME, "reward": 25.0, "goal": 600},
]

# Generate quests based on templates and current rebirth
static func generate_quests(rebirth_count: int, quest_count: int = 3) -> Array[Quest]:
	var result: Array[Quest] = []

	var options = quest_templates.duplicate()
	var picks = []

	while picks.size() < quest_count:
		var quest = options.pick_random()
		if quest in picks:
			continue
		picks.append(quest)
		options.erase(quest)

	for template in picks:
		var modifier = 1.0

		if template["type"] == QUESTTYPE.REBIRTH:
			modifier = 1 + rebirth_count * 0.1 # Increase difficulty with rebirths
		elif template["type"] == QUESTTYPE.REACH_MONEY:
			modifier = 1 + rebirth_count * 0.2 # Increase money goal with rebirths
		elif template["type"] == QUESTTYPE.REBIRTH_TIME:
			modifier = 1 + rebirth_count * 0.05 # Decrease time allowed with rebirths
		elif template["type"] == QUESTTYPE.PLAY_TIME:
			modifier = 1 + rebirth_count * 0.02 # Increase play time with rebirths

		var quest = Quest.new(template["type"], template["reward"], template['goal'] * modifier)
		result.append(quest)

	return result

# Update progress for a specific quest type
func update_quest_progress(quest_type: int, value: float):
	for quest in Player.quests:
		if quest.type == quest_type:
			quest.update_progress(value)
