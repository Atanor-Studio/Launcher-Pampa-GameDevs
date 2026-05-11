class_name DebugUtils
extends RefCounted

static func info(message: String, context: String = ""):
	var prefix = "[" + context + "] " if not context.is_empty() else ""
	print(prefix + message)

static func error(message: String, context: String = ""):
	var prefix = "[ERROR " + context + "] " if not context.is_empty() else "[ERROR] "
	print(prefix + message)
