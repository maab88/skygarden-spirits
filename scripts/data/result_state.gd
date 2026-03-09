class_name ResultState
extends RefCounted

static var is_win: bool = false
static var title: String = "Results"
static var reason: String = ""

static func set_result(new_is_win: bool, new_title: String, new_reason: String) -> void:
	is_win = new_is_win
	title = new_title
	reason = new_reason
