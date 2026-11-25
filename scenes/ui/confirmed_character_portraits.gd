extends RefCounted
## Approved dialogue portraits share a fixed canvas; do not alpha-trim each expression.
const PORTRAITS := {
	"carol": {
		"smile": preload("res://assets/final/confirmed_characters_20261125/carol/smile.png"),
		"thinking": preload("res://assets/final/confirmed_characters_20261125/carol/thinking.png"),
		"suspicious": preload("res://assets/final/confirmed_characters_20261125/carol/suspicious.png"),
		"surprised": preload("res://assets/final/confirmed_characters_20261125/carol/surprised.png"),
		"determined": preload("res://assets/final/confirmed_characters_20261125/carol/determined.png"),
	},
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
	if speaker in ["女主", "安", "Carol", "CAROL", "Carol（心想）"]: return "carol"
	if speaker in ["闺蜜", "Terese", "Persica", "friend"]: return "terese"
	if speaker in ["经理", "manager"]: return "manager"
	return ""
static func portrait(speaker: String, expression: String) -> Texture2D:
	var id := role(speaker)
	if id.is_empty(): return null
	if id == "manager": return PORTRAITS[id]["neutral"]
	var key := expression
	if id == "carol":
		key = {
			"neutral": "smile", "happy": "smile", "relieved": "smile",
			"concerned": "smile", "curious": "smile", "teasing": "smile",
			"calm": "thinking", "pensive": "thinking", "worried": "thinking",
			"anxious": "thinking", "afraid": "thinking", "stern": "determined",
		}.get(expression, expression)
	return PORTRAITS[id].get(key, PORTRAITS[id].get("neutral", PORTRAITS[id].get("smile")))
