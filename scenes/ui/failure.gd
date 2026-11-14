extends Control

signal retry_requested()
signal return_to_menu_requested()

const REASON_TEXT := {
	"STAFF_CAUGHT": "偷窃被发现",
	"WRONG_CARD": "当前工作证不符合要求",
	"MOVED_NEAR_EAR": "大耳客开门时仍在移动",
	"SWITCHED_NEAR_CHECKER": "核验客面前更换了工作证",
}


func show_failure(reason: String) -> void:
	%Reason.text = REASON_TEXT.get(reason, "未能通过检查")
	%RetryButton.text = "重试功能待 A 接入"
	%RetryButton.disabled = true
	%RetryButton.tooltip_text = "检查点恢复接口尚未提供"
	show()
	%MenuButton.grab_focus()


func _on_retry_pressed() -> void:
	if %RetryButton.disabled:
		return
	retry_requested.emit()


func _on_return_to_menu_pressed() -> void:
	return_to_menu_requested.emit()
