class_name Studio
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var website: String
@export var logo_path: String
@export var cover_path: String

func _init(p_id: String = "", p_name: String = "", p_description: String = "",
		p_website: String = "", p_logo_path: String = "", p_cover_path: String = ""):
	id = p_id
	name = p_name
	description = p_description
	website = p_website
	logo_path = p_logo_path
	cover_path = p_cover_path

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"website": website,
		"logo_path": logo_path,
		"cover_path": cover_path
	}

static func from_dict(data: Dictionary) -> Studio:
	var studio = Studio.new()
	studio.id = data.get("id", "")
	studio.name = data.get("name", "")
	studio.description = data.get("description", "")
	studio.website = data.get("website", "")
	studio.logo_path = data.get("logo_path", "")
	studio.cover_path = data.get("cover_path", "")
	return studio
