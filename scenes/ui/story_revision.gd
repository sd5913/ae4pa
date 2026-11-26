extends RefCounted
## Presentation data only. Task/rescue/EXIT truth stays in GameManager.
const PATH := "res://scenes/ui/story_revision.json"

static func beats(section: String) -> Array:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return data.get(section, []).duplicate(true)

static func monster_beat(row: Array) -> Dictionary:
	if row.size() > 2:
		return row[2]
	# Unchanged reminders retain their existing artwork.
	return {"speaker": row[0], "text": row[1], "mode": "dialogue", "portrait": true, "expression": "neutral", "previous_renderer": "character"}
