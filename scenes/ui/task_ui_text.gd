extends RefCounted
## Presentation-only labels derived from A's task view. Never stores task state.
const TASK_04_ID := "TASK_04_PATROL"
const TASK_05_ID := "TASK_05_EXIT"

static func step_for_view(task_view: Dictionary) -> String:
	var task_id := str(task_view.get("task_id", ""))
	var status := str(task_view.get("status", ""))
	var room := "403" if task_id == TASK_04_ID else "501" if task_id == TASK_05_ID else ""
	var key := ""
	var format_room := false
	if task_id == TASK_04_ID:
		match status:
			"AVAILABLE":
				key = "在%s接受任务，接受后限时180秒。"
				format_room = true
			"FAILED":
				key = "重新挑战后回%s接受，救援和前序成果保留。"
				format_room = true
			"ACTIVE": key = "在巡房员工身后站定，长按E偷取巡房记录。"
			"READY_TO_SUBMIT":
				key = "返回%s按E交付"
				format_room = true
			"COMPLETED": key = "403已交付；从右端楼梯上5F，在501接离店任务。"
	elif task_id == TASK_05_ID:
		match status:
			"AVAILABLE":
				key = "在%s接受任务，接受后限时180秒。"
				format_room = true
			"FAILED":
				key = "重新挑战后回%s接受，救援和前序成果保留。"
				format_room = true
			"ACTIVE": key = "切为当前经理身份，在五楼离店登记台按E批准。"
			"READY_TO_SUBMIT":
				key = "返回%s按E交付"
				format_room = true
			"COMPLETED": key = "离店单已交付；前往五楼消防出口按E逃离。"
	if key.is_empty():
		return ""
	var localized := TranslationServer.translate(key)
	return localized % room if format_room else localized


static func notice_for_display(message: String) -> String:
	var return_match := RegEx.create_from_string("^返回(\\d{3})按E交付$").search(message)
	if return_match:
		return TranslationServer.translate("返回%s按E交付") % return_match.get_string(1)
	return TranslationServer.translate(message)
