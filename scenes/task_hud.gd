extends "res://scenes/ui/hud.gd"
## A supplies task-01 route wording; D retains card/floor display and signal binding.

const STATUS_NAMES: Dictionary = {
	"NONE": "暂无任务", "AVAILABLE": "待接受", "ACTIVE": "进行中",
	"READY_TO_SUBMIT": "待交付", "COMPLETED": "已完成", "FAILED": "任务失败",
}


func _refresh_task_display() -> void:
	var view: Dictionary = GameManager.get_task_view()
	var status: String = view["status"]
	var objective: String = "前往前台与经理交谈"
	match status:
		"NONE":
			if GameManager.has_completed_manager_intro():
				objective = "前往 2F 的 201 房门接任务"
		"AVAILABLE":
			objective = "在 201 接受清洁任务"
		"ACTIVE":
			objective = "回 1F 取得保洁工作证" if not CardManager.has_card("CLEANER") else "使用保洁身份清理 2F 污渍"
		"READY_TO_SUBMIT":
			objective = "回 201 房门按 E 交付"
		"COMPLETED":
			objective = "201 已完成；任务 02 尚未开放"
		"FAILED":
			objective = "重新挑战后回 201 接受任务"
	if not str(view["name"]).is_empty():
		objective = "%s · %s\n%s" % [view["name"], view["location"], objective]
	var seconds: int = maxi(0, ceili(view["remaining_time"]))
	_apply_task_display(objective, "剩余时间：%d:%02d · %s" % [seconds / 60, seconds % 60, STATUS_NAMES.get(status, status)])
