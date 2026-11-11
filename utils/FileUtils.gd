class_name FileUtils
extends RefCounted

static func get_data_path(filename: String) -> String:
	return AppConfig.get_data_directory() + filename

# Carpetas que el launcher necesita junto al ejecutable (o en res:// dentro del editor)
const REQUIRED_DIRECTORIES = ["data/", "Games/", "Studios/"]
# Archivos de datos base; si no existen se crean como lista vacía
const DATA_FILES = ["categories.json", "games.json", "studios.json"]

# Crea las carpetas y los JSON base si no existen. Se puede llamar varias veces sin problema.
static func ensure_data_structure() -> void:
	var base_dir = AppConfig.get_launcher_directory()
	for dir_name in REQUIRED_DIRECTORIES:
		var dir_path = base_dir + dir_name
		if not DirAccess.dir_exists_absolute(dir_path):
			var err = DirAccess.make_dir_recursive_absolute(dir_path)
			if err == OK:
				DebugUtils.info("Carpeta creada: " + dir_path)
			else:
				DebugUtils.error("No se pudo crear la carpeta " + dir_path + " (error " + str(err) + ")")
	
	for file_name in DATA_FILES:
		var file_path = get_data_path(file_name)
		if not FileAccess.file_exists(file_path):
			var result = save_json_file(file_path, [])
			if result.success:
				DebugUtils.info("Archivo de datos creado: " + file_path)
			else:
				DebugUtils.error(result.error)

static func load_json_file(file_path: String) -> Dictionary:
	var result = {
		"success": false,
		"data": null,
		"error": ""
	}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.error = "No se pudo abrir el archivo: " + file_path
		return result
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		result.error = "Error parsing JSON: " + json.get_error_message()
		return result
	
	result.success = true
	result.data = json.data
	return result

static func save_json_file(file_path: String, data: Variant) -> Dictionary:
	var result = {
		"success": false,
		"error": ""
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		result.error = "No se pudo crear/escribir el archivo: " + file_path
		return result
	
	var json_string = JSON.stringify(data, "\t")
	
	file.store_string(json_string)
	file.close()
	
	result.success = true
	return result

# Convierte una ruta guardada en los JSON (relativa a la carpeta del launcher o absoluta)
# en una ruta absoluta del sistema. Si ya es absoluta, la devuelve tal cual.
static func resolve_path(path: String) -> String:
	if path.is_empty():
		return path
	var normalized = path.replace("\\", "/")
	if normalized.begins_with("res://") or normalized.begins_with("user://"):
		return ProjectSettings.globalize_path(normalized)
	if normalized.is_absolute_path():
		return normalized
	var base_dir = ProjectSettings.globalize_path(AppConfig.get_launcher_directory())
	if not base_dir.ends_with("/"):
		base_dir += "/"
	return base_dir + normalized

static func load_texture_safe(cover_path: String) -> Texture2D:
	cover_path = resolve_path(cover_path)
	if cover_path.is_empty() or not FileAccess.file_exists(cover_path):
		return null
	
	var image: Image = Image.new()
	var error: Error = image.load(cover_path)
	
	if error != OK:
		push_error("Error al cargar imagen: " + cover_path)
		return null
	
	var image_texture: ImageTexture = ImageTexture.new()
	image_texture.set_image(image)
	return image_texture
