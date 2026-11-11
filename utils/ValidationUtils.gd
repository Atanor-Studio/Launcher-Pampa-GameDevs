class_name ValidationUtils
extends RefCounted

static func generate_safe_id(input_text: String, fallback: String = "item_sin_nombre") -> String:
	if input_text.is_empty():
		return fallback
	
	var safe_id = input_text.to_lower().strip_edges()
	
	# Crear RegEx para mantener solo a-z, 0-9 y reemplazar todo lo demás con _
	var regex = RegEx.new()
	regex.compile("[^a-z0-9]")
	safe_id = regex.sub(safe_id, "_", true)
	
	# Limpiar múltiples _ consecutivos
	var cleanup_regex = RegEx.new()
	cleanup_regex.compile("_{2,}")
	safe_id = cleanup_regex.sub(safe_id, "_", true)
	
	# Remover _ del inicio y final
	safe_id = safe_id.trim_prefix("_").trim_suffix("_")
	
	return safe_id if not safe_id.is_empty() else fallback

static func validate_game_data(name: String, _description: String, studio_id: String) -> Dictionary:
	var errors = []
	
	if name.is_empty():
		errors.append("El nombre es obligatorio")
	if studio_id.is_empty():
		errors.append("Debe seleccionar un estudio")
	
	return {
		"is_valid": errors.is_empty(),
		"errors": errors
	}

static func validate_studio_data(name: String, _description: String) -> Dictionary:
	var errors = []
	
	if name.is_empty():
		errors.append("El nombre es obligatorio")
	
	return {
		"is_valid": errors.is_empty(),
		"errors": errors
	}

static func validate_category_data(name: String, id: String, existing_ids: Array) -> Dictionary:
	var errors = []
	
	if name.is_empty():
		errors.append("El nombre es obligatorio")
	if id.is_empty():
		errors.append("El ID es obligatorio")
	if id in existing_ids:
		errors.append("El ID ya existe")
	
	return {
		"is_valid": errors.is_empty(),
		"errors": errors
	}

static func get_executable_filters() -> Array:
	return [
		"*.exe ; Archivos ejecutables"
	]

static func get_image_filters() -> Array:
	return [
		"*.png ; Imágenes PNG",
		"*.jpg ; Imágenes JPG", 
		"*.jpeg ; Imágenes JPEG",
		"*.bmp ; Imágenes BMP",
		"*.tga ; Imágenes TGA",
		"*.webp ; Imágenes WebP"
	]

static func convert_to_relative_path(absolute_path: String) -> String:
	var launcher_dir = ProjectSettings.globalize_path(AppConfig.get_launcher_directory())
	
	# Normalizar ambas rutas
	var normalized_absolute = absolute_path.replace("\\", "/")
	var normalized_launcher = launcher_dir.replace("\\", "/")
	
	# Asegurar que el directorio launcher termine con /
	if not normalized_launcher.ends_with("/"):
		normalized_launcher += "/"
	
	# Si la ruta está dentro del directorio del launcher, hacerla relativa
	if normalized_absolute.begins_with(normalized_launcher):
		return normalized_absolute.substr(normalized_launcher.length())
	
	# Si no está dentro del directorio del launcher, devolver la ruta absoluta con warning
	DebugUtils.info("Archivo seleccionado fuera del directorio base del proyecto: " + absolute_path)
	return normalized_absolute
