extends RefCounted
## V4 task data only. A enables gameplay by milestone, independently of this catalog.

const TASKS: Dictionary = {
	"TASK_01_CLEAN": {
		"name": "打扫走廊", "location": "2F · 201", "offer_floor": 2, "room_id": "201",
		"prerequisites": ["MANAGER_INTRO"], "time_limit": 210.0,
		"required_card": "CLEANER", "staff_target_id": "STAFF_CLEANER_1F",
		"target_id": "STAIN_201", "work_type": "CLEAN", "work_floor": 2,
		"steps": ["GET_CLEANER", "CLEAN_STAIN", "RETURN_TO_201"],
		"work_flag": "stain_201_cleaned", "completion_flags": ["passage_201_unlocked"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
	"TASK_02_PARCEL": {
		"name": "遗失的包裹", "location": "2F · 202", "offer_floor": 2, "room_id": "202",
		"prerequisites": ["TASK_01_CLEAN"], "time_limit": 180.0,
		"required_card": "SECURITY", "staff_target_id": "STAFF_SECURITY_2F",
		"target_id": "PARCEL_CABINET_2F", "work_type": "PICKUP", "work_floor": 2,
		"steps": ["GET_SECURITY", "PICKUP_PARCEL", "RETURN_TO_202"],
		"work_flag": "parcel_collected", "completion_flags": ["parcel_delivered", "passage_202_unlocked"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
	"TASK_03_AUTHORIZE": {
		"name": "取得管理授权", "location": "3F · 303／309 登记台", "offer_floor": 3, "room_id": "303",
		"prerequisites": ["TASK_02_PARCEL"], "time_limit": 240.0,
		"required_card": "MANAGER", "staff_target_id": "STAFF_MANAGER_1F",
		"target_id": "REGISTER_309", "work_type": "AUTHORIZE", "work_floor": 3,
		"steps": ["GET_MANAGER", "EQUIP_MANAGER", "AUTHORIZE_309"],
		"work_flag": "registration_309_approved", "completion_flags": ["registration_309_approved"],
		"settlement": "AUTHORIZE_PROPOSED", "confirmation_required": ["D-05"],
	},
	"TASK_04_PATROL": {
		"name": "夜班巡房记录", "location": "4F · 402", "offer_floor": 4, "room_id": "402",
		"prerequisites": ["HAS_FRIEND"], "time_limit": 180.0,
		"required_card": "", "staff_target_id": "STAFF_PATROL_4F",
		"target_id": "STAFF_PATROL_4F", "reward_id": "PATROL_RECORD", "work_type": "STEAL_FILE", "work_floor": 4,
		"steps": ["STEAL_PATROL_RECORD", "RETURN_TO_402"],
		"work_flag": "patrol_collected", "completion_flags": ["patrol_delivered", "passage_402_unlocked"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
	"TASK_05_EXIT": {
		"name": "最后的离店许可", "location": "5F · 503", "offer_floor": 5, "room_id": "503",
		"prerequisites": ["TASK_04_PATROL", "HAS_FRIEND"], "time_limit": 180.0,
		"required_card": "MANAGER", "staff_target_id": "",
		"target_id": "EXIT_REGISTER_5F", "reward_id": "EXIT_FORM", "work_type": "AUTHORIZE", "work_floor": 5,
		"steps": ["AUTHORIZE_EXIT_FORM", "RETURN_TO_503"],
		"work_flag": "exit_form_approved", "completion_flags": ["exit_form_delivered"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
}


static func get_definition(task_id: String) -> Dictionary:
	return TASKS.get(task_id, {}).duplicate(true)
