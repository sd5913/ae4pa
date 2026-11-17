extends RefCounted

const CARD_NAMES := {
	"NONE": "未装备",
	"SECURITY": "保安工作证",
	"CLEANER": "保洁工作证",
	"MANAGER": "经理工作证",
}


const CARD_ART := {
	"SECURITY": preload("res://assets/final/ui/security_card.png"),
	"CLEANER": preload("res://assets/final/ui/cleaner_card.png"),
	"MANAGER": preload("res://assets/final/ui/manager_card.png"),
}


static func art_for(card_id: String) -> Texture2D:
	return CARD_ART.get(card_id)


static func name_for(card_id: String) -> String:
	return CARD_NAMES.get(card_id, "未知工作证")
