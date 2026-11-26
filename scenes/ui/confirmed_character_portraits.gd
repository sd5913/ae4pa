extends RefCounted
## User-confirmed original PNGs; atlas regions remove transparent margins only.
const PORTRAITS := {
	"carol": {
		"pensive": preload("res://assets/final/confirmed_characters_20261126/carol/pensive.png"),
		"exasperated": preload("res://assets/final/confirmed_characters_20261126/carol/exasperated.png"),
		"coaxing": preload("res://assets/final/confirmed_characters_20261126/carol/coaxing.png"),
		"suspicious": preload("res://assets/final/confirmed_characters_20261126/carol/suspicious.png"),
		"surprised": preload("res://assets/final/confirmed_characters_20261126/carol/surprised.png"),
		"blushing": preload("res://assets/final/confirmed_characters_20261126/carol/blushing.png"),
		"hunting": preload("res://assets/final/confirmed_characters_20261126/carol/hunting.png"),
		"neutral": preload("res://assets/final/confirmed_characters_20261126/carol/neutral.png"),
		"ironic": preload("res://assets/final/confirmed_characters_20261126/carol/ironic.png"),
		"angry": preload("res://assets/final/confirmed_characters_20261126/carol/angry.png"),
		"languid": preload("res://assets/final/confirmed_characters_20261126/carol/languid.png"),
		"worried": preload("res://assets/final/confirmed_characters_20261126/carol/worried.png"),
		"dubious": preload("res://assets/final/confirmed_characters_20261126/carol/dubious.png"),
	},
	"terese": {
		"playful": preload("res://assets/final/confirmed_characters_20261126/terese/playful.png"),
		"teasing": preload("res://assets/final/confirmed_characters_20261126/terese/teasing.png"),
		"happy": preload("res://assets/final/confirmed_characters_20261126/terese/happy.png"),
		"neutral": preload("res://assets/final/confirmed_characters_20261126/terese/neutral.png"),
		"pouting": preload("res://assets/final/confirmed_characters_20261126/terese/pouting.png"),
		"afraid": preload("res://assets/final/confirmed_characters_20261126/terese/afraid.png"),
		"surprised": preload("res://assets/final/confirmed_characters_20261126/terese/surprised.png"),
	},
	"manager": {
		"neutral": preload("res://assets/final/confirmed_characters_20261126/manager/neutral.png"),
		"sinister_smile": preload("res://assets/final/confirmed_characters_20261126/manager/sinister_smile.png"),
		"ominous": preload("res://assets/final/confirmed_characters_20261126/manager/ominous.png"),
	},
}
const REGIONS := {
	"carol:pensive": Rect2(118, 38, 774, 1413),
	"carol:exasperated": Rect2(61, 33, 884, 1289),
	"carol:coaxing": Rect2(88, 8, 876, 1525),
	"carol:suspicious": Rect2(118, 31, 805, 1436),
	"carol:surprised": Rect2(122, 31, 830, 1439),
	"carol:blushing": Rect2(62, 29, 913, 1283),
	"carol:hunting": Rect2(93, 7, 863, 1525),
	"carol:neutral": Rect2(155, 37, 794, 1375),
	"carol:ironic": Rect2(220, 26, 757, 1295),
	"carol:angry": Rect2(62, 28, 920, 1284),
	"carol:languid": Rect2(243, 16, 684, 1302),
	"carol:worried": Rect2(169, 27, 773, 1388),
	"carol:dubious": Rect2(235, 12, 760, 1316),
	"terese:playful": Rect2(211, 3, 894, 1173),
	"terese:teasing": Rect2(225, 34, 909, 1406),
	"terese:happy": Rect2(295, 32, 826, 1408),
	"terese:neutral": Rect2(220, 35, 889, 1405),
	"terese:pouting": Rect2(192, 7, 874, 1323),
	"terese:afraid": Rect2(239, 28, 800, 1302),
	"terese:surprised": Rect2(215, 6, 951, 1306),
	"manager:neutral": Rect2(244, 35, 822, 1405),
	"manager:sinister_smile": Rect2(233, 26, 764, 1304),
	"manager:ominous": Rect2(230, 26, 767, 1304),
}
const ALIASES := {
	"沉思": "pensive",
	"扶额无奈": "exasperated",
	"蛊惑": "coaxing",
	"怀疑": "suspicious",
	"惊讶": "surprised",
	"脸红": "blushing",
	"猎杀时刻": "hunting",
	"平常": "neutral",
	"气笑了": "ironic",
	"生气": "angry",
	"慵懒": "languid",
	"担忧": "worried",
	"狐疑": "dubious",
	"俏皮": "playful",
	"调侃": "teasing",
	"开心": "happy",
	"气鼓鼓": "pouting",
	"害怕": "afraid",
	"笑里藏刀": "sinister_smile",
	"阴森": "ominous",
	"思考": "pensive", "坚定": "hunting", "determined": "hunting", "stern": "hunting",
	"calm": "neutral", "curious": "neutral", "concerned": "worried", "anxious": "worried", "smile": "neutral", "relieved": "neutral",
}
static var _cache: Dictionary = {}
static func role(speaker: String) -> String:
	if speaker in ["Carol", "Carol（心想）", "女主", "安", "CAROL", "an"]: return "carol"
	if speaker in ["闺蜜", "Terese", "Terese（低声）", "Persica", "friend", "TERESE"]: return "terese"
	if speaker in ["经理", "manager"]: return "manager"
	return ""
static func portrait(speaker: String, expression: String = "neutral") -> Texture2D:
	var id := role(speaker)
	if id.is_empty(): return null
	var key: String = ALIASES.get(expression, expression)
	if not PORTRAITS[id].has(key): key = "neutral"
	var token := id + ":" + key
	if not _cache.has(token):
		var atlas := AtlasTexture.new()
		atlas.atlas = PORTRAITS[id][key]
		atlas.region = REGIONS[token]
		_cache[token] = atlas
	return _cache[token]
