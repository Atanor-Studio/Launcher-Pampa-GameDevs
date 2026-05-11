extends BaseController

# Señales específicas para estudios (las genéricas se heredan de BaseController)
signal studios_loaded
signal studio_added
signal studio_updated
signal studio_removed

# Alias para compatibilidad con código existente
var studios: Array:
	get:
		return items

const STUDIOS_FILE_NAME = "studios.json"

# Implementación de métodos abstractos
func get_file_name() -> String:
	return STUDIOS_FILE_NAME

func create_item_from_dict(data: Dictionary) -> Resource:
	return Studio.from_dict(data)

func get_item_type_name() -> String:
	return "Studio"

func _ready():
	# Conectar señales base a señales específicas para compatibilidad
	super._ready()
	items_loaded.connect(_on_items_loaded)
	item_added.connect(_on_item_added)
	item_updated.connect(_on_item_updated)
	item_removed.connect(_on_item_removed)

# Funciones de compatibilidad que redirigen las señales
func _on_items_loaded():
	studios_loaded.emit()

func _on_item_added():
	studio_added.emit()

func _on_item_updated():
	studio_updated.emit()

func _on_item_removed():
	studio_removed.emit()

# Funciones específicas de estudios
func get_studio_by_id(id: String) -> Studio:
	return get_item_by_id(id) as Studio

func add_studio(studio: Studio) -> bool:
	return add_item(studio)

func update_studio(updated_studio: Studio) -> bool:
	return update_item(updated_studio)

func remove_studio(studio_id: String) -> bool:
	return remove_item(studio_id)
