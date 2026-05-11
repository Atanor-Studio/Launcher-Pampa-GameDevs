extends BaseController

# Señales específicas para juegos (las genéricas se heredan de BaseController)
signal games_loaded
signal game_added
signal game_updated
signal game_removed

# Alias para compatibilidad con código existente
var games: Array:
	get:
		return items

const GAMES_FILE_NAME = "games.json"

# Implementación de métodos abstractos
func get_file_name() -> String:
	return GAMES_FILE_NAME

func create_item_from_dict(data: Dictionary) -> Resource:
	return Game.from_dict(data)

func get_item_type_name() -> String:
	return "Game"

func _ready():
	# Conectar señales base a señales específicas para compatibilidad
	super._ready()
	items_loaded.connect(_on_items_loaded)
	item_added.connect(_on_item_added)
	item_updated.connect(_on_item_updated)
	item_removed.connect(_on_item_removed)

# Funciones de compatibilidad que redirigen las señales
func _on_items_loaded():
	games_loaded.emit()

func _on_item_added():
	game_added.emit()

func _on_item_updated():
	game_updated.emit()

func _on_item_removed():
	game_removed.emit()

# Funciones específicas de juegos que no están en BaseController
# Funciones específicas de juegos que no están en BaseController
func get_game_by_id(id: String) -> Game:
	return get_item_by_id(id) as Game

func get_games_by_studio(studio_id: String) -> Array:
	var result: Array = []
	for game in games:
		if game.studio_id == studio_id:
			result.append(game)
	return result

func get_games_by_category(category_id: String) -> Array:
	var result: Array = []
	for game in games:
		if category_id in game.category_ids:
			result.append(game)
	return result

# Nueva función para obtener juegos ordenados por fecha
func get_games_sorted_by_date(ascending: bool = false) -> Array:
	var sorted_games = games.duplicate()
	sorted_games.sort_custom(_compare_games_by_date)
	if not ascending:
		sorted_games.reverse()  # Para mostrar más nuevos primero
	return sorted_games

# Función comparadora para ordenar por fecha
func _compare_games_by_date(game_a: Game, game_b: Game) -> bool:
	var date_a = _parse_release_date(game_a.release_date)
	var date_b = _parse_release_date(game_b.release_date)
	
	# Convertir fechas a timestamp numérico para comparar
	var timestamp_a = date_a.year * 10000 + date_a.month * 100 + date_a.day
	var timestamp_b = date_b.year * 10000 + date_b.month * 100 + date_b.day
	
	return timestamp_a < timestamp_b

# Función para parsear fechas en diferentes formatos
func _parse_release_date(date_string: String) -> Dictionary:
	if date_string.is_empty():
		return {"year": 1900, "month": 1, "day": 1}
	
	# Manejar formato ISO 8601 con tiempo (ej: "2025-08-24T14:04:11")
	if "T" in date_string:
		date_string = date_string.split("T")[0]
	
	# Manejar formato YYYY-MM-DD
	var parts = date_string.split("-")
	if parts.size() >= 3:
		return {
			"year": parts[0].to_int(),
			"month": parts[1].to_int(),
			"day": parts[2].to_int()
		}
	
	# Formato por defecto si no se puede parsear
	return {"year": 1900, "month": 1, "day": 1}

# Función para obtener juegos filtrados por rango de fechas
func get_games_by_date_range(start_date: String, end_date: String) -> Array:
	var result: Array = []
	var start_parsed = _parse_release_date(start_date)
	var end_parsed = _parse_release_date(end_date)
	
	for game in games:
		var game_date = _parse_release_date(game.release_date)
		if _is_date_in_range(game_date, start_parsed, end_parsed):
			result.append(game)
	
	return result

# Función auxiliar para verificar si una fecha está en un rango
func _is_date_in_range(date: Dictionary, start_date: Dictionary, end_date: Dictionary) -> bool:
	# Convertir fechas a timestamp simple para comparar
	var date_stamp = date.year * 10000 + date.month * 100 + date.day
	var start_stamp = start_date.year * 10000 + start_date.month * 100 + start_date.day
	var end_stamp = end_date.year * 10000 + end_date.month * 100 + end_date.day
	
	return date_stamp >= start_stamp and date_stamp <= end_stamp

func add_game(game: Game) -> bool:
	return add_item(game)

func update_game(updated_game: Game) -> bool:
	return update_item(updated_game)

func remove_game(game_id: String) -> bool:
	return remove_item(game_id)

func launch_game(game: Game):
	if game.exe_path != "" and FileAccess.file_exists(game.exe_path):
		var executablePath: String = AppConfig.get_launcher_directory() + "/" + game.exe_path
		DebugUtils.info("Lanzando juego: " + game.name + " desde: " + executablePath)
		var processId: int = OS.create_process(executablePath, [])
	
		if processId == -1:
			push_error("Error al lanzar el juego: " + executablePath)
			return
	else:
		DebugUtils.error("Ejecutable del juego no encontrado: " + game.exe_path)
