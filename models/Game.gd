class_name Game
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export var exe_path: String
@export var cover_path: String
@export var studio_id: String
@export var category_ids: Array = []
@export var version: String
@export var release_date: String

func _init(p_id: String = "", p_name: String = "", p_description: String = "", 
		   p_exe_path: String = "", p_cover_path: String = "", p_studio_id: String = "",
		   p_category_ids: Array = [], p_version: String = "", p_release_date: String = ""):
	id = p_id
	name = p_name
	description = p_description
	exe_path = p_exe_path
	cover_path = p_cover_path
	studio_id = p_studio_id
	category_ids = p_category_ids
	version = p_version
	release_date = p_release_date

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"description": description,
		"exe_path": exe_path,
		"cover_path": cover_path,
		"studio_id": studio_id,
		"category_ids": category_ids,
		"version": version,
		"release_date": release_date
	}

static func from_dict(data: Dictionary) -> Game:
	var game = Game.new()
	game.id = data.get("id", "")
	game.name = data.get("name", "")
	game.description = data.get("description", "")
	game.exe_path = data.get("exe_path", "")
	game.cover_path = data.get("cover_path", "")
	game.studio_id = data.get("studio_id", "")
	game.category_ids = data.get("category_ids", [])
	game.version = data.get("version", "")
	game.release_date = data.get("release_date", "")
	return game
