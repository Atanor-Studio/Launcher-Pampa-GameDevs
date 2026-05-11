class_name FileUtils
extends RefCounted

static func get_data_path(filename: String) -> String:
	return AppConfig.get_data_directory() + filename

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

static func load_texture_safe(cover_path: String) -> Texture2D:
	if not FileAccess.file_exists(cover_path):
		return null
	
	var image: Image = Image.new()
	var error: Error = image.load(cover_path)
	
	if error != OK:
		push_error("Error al cargar imagen: " + cover_path)
		return null
	
	var image_texture: ImageTexture = ImageTexture.new()
	image_texture.set_image(image)
	return image_texture
