class_name Category
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var color: String

func _init(p_id: String = "", p_name: String = "", p_description: String = "", p_color: String = "#FFFFFF"):
	id = p_id
	name = p_name
	description = p_description
	color = p_color

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"color": color
	}

static func from_dict(data: Dictionary) -> Category:
	var category = Category.new()
	category.id = data.get("id", "")
	category.name = data.get("name", "")
	category.description = data.get("description", "")
	category.color = data.get("color", "#FFFFFF")
	return category
