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
		"required_card": "SECURITY", "staff_target_id": "STAFF_SECURITY_1F",
		"target_id": "PARCEL_CABINET_2F", "work_type": "PICKUP", "work_floor": 2,
		"steps": ["GET_SECURITY", "PICKUP_PARCEL", "RETURN_TO_202"],
		"work_flag": "parcel_collected", "completion_flags": ["parcel_delivered", "passage_202_unlocked"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
	"TASK_T03_ROOM_SERVICE": {
		"name": "二楼房务申请", "location": "2F · 203", "offer_floor": 2, "room_id": "203",
		"prerequisites": ["TASK_02_PARCEL"], "time_limit": 240.0,
		"required_card": "MANAGER", "required_cards": ["MANAGER"], "staff_target_id": "STAFF_MANAGER_1F",
		"target_id": "ROOM_SERVICE_203", "work_type": "AUTHORIZE", "work_floor": 2,
		"steps": ["GET_MANAGER", "APPROVE_ROOM_SERVICE", "RETURN_TO_203"],
		"work_flag": "room_service_203_approved", "completion_flags": ["passage_203_unlocked"], "settlement": "DELIVER",
		"work_steps": [{"target_id": "ROOM_SERVICE_203", "required_card": "MANAGER", "flag": "room_service_203_approved", "label": "当前经理身份在二楼房务登记台按E批准"}],
		"instructions": "回1F经理身后取证，I替换装备槽、Q切经理 → 二楼房务登记台批准 → 返回203交付。",
	},
	"TASK_T04_DUAL_WORK": {
		"name": "清理与巡房记录", "location": "2F · 204", "offer_floor": 2, "room_id": "204",
		"prerequisites": ["TASK_T03_ROOM_SERVICE"], "time_limit": 210.0,
		"required_card": "CLEANER", "required_cards": ["CLEANER", "SECURITY"], "staff_target_id": "",
		"target_id": "STAIN_204", "work_type": "CLEAN", "work_floor": 2,
		"steps": ["CLEAN_STAIN_204", "PICKUP_PATROL_204", "RETURN_TO_204"],
		"work_flag": "tutorial_patrol_collected", "completion_flags": ["passage_204_unlocked"], "settlement": "DELIVER",
		"work_steps": [
			{"target_id": "STAIN_204", "required_card": "CLEANER", "flag": "stain_204_cleaned", "label": "当前保洁身份长按E清理204独立污渍"},
			{"target_id": "PATROL_CABINET_204", "required_card": "SECURITY", "flag": "tutorial_patrol_collected", "label": "当前保安身份按E领取204巡房记录"}],
		"instructions": "装备保洁＋保安两槽 → 保洁清理204独立污渍 → Q切保安领取巡房记录 → 返回204交付。",
	},
	"TASK_T05_TRANSIT": {
		"name": "二楼通行备案", "location": "2F · 205", "offer_floor": 2, "room_id": "205",
		"prerequisites": ["TASK_T04_DUAL_WORK"], "time_limit": 210.0,
		"required_card": "SECURITY", "required_cards": ["SECURITY", "MANAGER"], "staff_target_id": "",
		"target_id": "TRANSIT_PICKUP_205", "work_type": "PICKUP", "work_floor": 2,
		"steps": ["PICKUP_TRANSIT_205", "APPROVE_TRANSIT_205", "RETURN_TO_205"],
		"work_flag": "transit_205_approved", "completion_flags": ["passage_205_unlocked"], "settlement": "DELIVER",
		"work_steps": [
			{"target_id": "TRANSIT_PICKUP_205", "required_card": "SECURITY", "flag": "transit_205_collected", "label": "当前保安身份按E领取待审通行单"},
			{"target_id": "TRANSIT_REGISTER_205", "required_card": "MANAGER", "flag": "transit_205_approved", "label": "在安全登记台切为当前经理身份后按E批准"}],
		"instructions": "装备保安＋经理两槽 → 保安领取通行单 → 在安全登记台Q切经理批准 → 返回205交付。不要在核验门前换证；本任务不解锁EXIT。",
	},
	"TASK_03_AUTHORIZE": {
		"name": "取得管理授权", "location": "3F · 302／309 登记台", "offer_floor": 3, "room_id": "302",
		"prerequisites": ["TASK_T05_TRANSIT"], "time_limit": 240.0,
		"required_card": "MANAGER", "staff_target_id": "STAFF_MANAGER_1F",
		"target_id": "REGISTER_309", "work_type": "AUTHORIZE", "work_floor": 3,
		"steps": ["GET_MANAGER", "EQUIP_MANAGER", "AUTHORIZE_309"],
		"work_flag": "registration_309_approved", "completion_flags": ["registration_309_approved"],
		"settlement": "AUTHORIZE", "confirmation_required": [],
	},
	"TASK_04_PATROL": {
		"name": "夜班巡房记录", "location": "4F · 403", "offer_floor": 4, "room_id": "403",
		"prerequisites": ["HAS_FRIEND"], "time_limit": 180.0,
		"required_card": "", "required_cards": [], "staff_target_id": "STAFF_PATROL_4F",
		"checkpoint_marker": "Task403AcceptSafe", "monster": "EAR",
		"instructions": "到本层巡房员工身后站定，长按E偷取巡房记录，再返回403按E交付。文件不是工作证，不要求特定身份；交付后才开放5F。",
		"target_id": "STAFF_PATROL_4F", "reward_id": "PATROL_RECORD", "work_type": "STEAL_FILE", "work_floor": 4,
		"steps": ["STEAL_PATROL_RECORD", "RETURN_TO_403"],
		"work_flag": "patrol_collected", "completion_flags": ["patrol_delivered", "passage_403_unlocked"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
	"TASK_05_EXIT": {
		"name": "最后的离店许可", "location": "5F · 501", "offer_floor": 5, "room_id": "501",
		"prerequisites": ["TASK_04_PATROL", "HAS_FRIEND"], "time_limit": 180.0,
		"required_card": "MANAGER", "required_cards": ["MANAGER"], "staff_target_id": "",
		"checkpoint_marker": "Task501AcceptSafe", "monster": "CHECKER",
		"instructions": "在安全登记台旁I装备／Q切当前经理，按E批准离店单，再返回501按E交付。批准不等于交付；交付后到右端消防出口按E，与Terese一起逃离。",
		"target_id": "EXIT_REGISTER_5F", "reward_id": "EXIT_FORM", "work_type": "AUTHORIZE", "work_floor": 5,
		"steps": ["AUTHORIZE_EXIT_FORM", "RETURN_TO_501"],
		"work_flag": "exit_form_approved", "completion_flags": ["exit_form_delivered"],
		"settlement": "DELIVER", "confirmation_required": [],
	},
}


static func get_definition(task_id: String) -> Dictionary:
	return TASKS.get(task_id, {}).duplicate(true)
