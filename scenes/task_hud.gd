extends "res://scenes/ui/hud.gd"
## A supplies task routes; D retains card/floor display and signal binding.

const STATUS_NAMES: Dictionary = {
	"NONE": "暂无任务", "AVAILABLE": "待接受", "ACTIVE": "进行中",
	"READY_TO_SUBMIT": "待交付", "COMPLETED": "已完成", "FAILED": "任务失败",
}


func _refresh_task_display() -> void:
	var view: Dictionary = GameManager.get_task_view()
	var status: String = view["status"]
	var objective: String = "前往前台与经理交谈"
	if view["task_id"] == GameManager.TASK_03_ID:
		match status:
			"AVAILABLE": objective = "在302接受240秒授权任务"
			"ACTIVE":
				if not CardManager.has_card("MANAGER"): objective = "回1F经理身后长按E取证"
				elif not CardManager.get_equipped_cards().has("MANAGER"): objective = "I将经理证放入佩戴槽"
				else: objective = "3F登记台按E批准309" if CardManager.active_card == "MANAGER" else "Q切为经理，回3F登记台批准"
			"COMPLETED": objective = "309登记已批准；任务03完成"
			"FAILED": objective = "回302重新接受；201／202成果保留"
	elif view["task_id"] == GameManager.TASK_02_ID:
		match status:
			"AVAILABLE": objective = "在202接受180秒包裹任务"
			"ACTIVE":
				objective = "返回一楼，在保安身后长按E取证" if not CardManager.has_card("SECURITY") else "到保管柜按E领取包裹" if CardManager.active_card == "SECURITY" else "Q切保安身份，到保管柜按E领取"
			"READY_TO_SUBMIT": objective = "带包裹回202按E交付"
			"COMPLETED": objective = "202已交付；上3F到302接授权任务"
			"FAILED": objective = "回202重新接受；201成果保留"
	else:
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
				objective = "201已完成；向右到202接包裹任务"
			"FAILED":
				objective = "重新挑战后回 201 接受任务"
	if not str(view["name"]).is_empty():
		objective = "%s · %s\n%s" % [tr(view["name"]), tr(view["location"]), tr(objective)]
	var seconds: int = maxi(0, ceili(view["remaining_time"]))
	_apply_task_display(objective, tr("剩余时间：%d:%02d · %s") % [seconds / 60, seconds % 60, tr(STATUS_NAMES.get(status, status))])
