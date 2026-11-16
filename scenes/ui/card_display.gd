extends RefCounted

const CARD_NAMES := {
	"NONE": "未装备",
	"SECURITY": "保安工作证",
	"CLEANER": "保洁工作证",
	"MANAGER": "经理工作证",
}


static func name_for(card_id: String) -> String:
	return CARD_NAMES.get(card_id, "未知工作证")
