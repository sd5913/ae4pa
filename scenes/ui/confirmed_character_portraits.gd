extends RefCounted
## Approved dialogue portraits share a fixed canvas; do not alpha-trim each expression.
const PORTRAITS := {
	"terese": {
		"neutral": preload("res://assets/final/confirmed_characters_20261125/terese/neutral.png"),
		"happy": preload("res://assets/final/confirmed_characters_20261125/terese/happy.png"),
		"teasing": preload("res://assets/final/confirmed_characters_20261125/terese/teasing.png"),
		"playful": preload("res://assets/final/confirmed_characters_20261125/terese/playful.png"),
	},
	"manager": {
		"neutral": preload("res://assets/final/confirmed_characters_20261125/manager/neutral.png"),
	},
}
static func role(speaker: String) -> String:
	if speaker in ["闺蜜", "Terese", "Persica", "friend"]: return "terese"
	if speaker in ["经理", "manager"]: return "manager"
	return ""
static func portrait(speaker: String, expression: String) -> Texture2D:
	var id := role(speaker)
	if id.is_empty(): return null
	if id == "manager": return PORTRAITS[id]["neutral"]
	return PORTRAITS[id].get(expression, PORTRAITS[id]["neutral"])
