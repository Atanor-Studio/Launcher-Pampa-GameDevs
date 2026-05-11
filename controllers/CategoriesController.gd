extends BaseController

# Señales específicas para categorías (las genéricas se heredan de BaseController)
signal categories_loaded
signal category_added
signal category_updated
signal category_removed

# Alias para compatibilidad con código existente
var categories: Array:
	get:
		return items

const CATEGORIES_FILE_NAME = "categories.json"

# Implementación de métodos abstractos
func get_file_name() -> String:
	return CATEGORIES_FILE_NAME

func create_item_from_dict(data: Dictionary) -> Resource:
	return Category.from_dict(data)

func get_item_type_name() -> String:
	return "Category"

func _ready():
	# Conectar señales base a señales específicas para compatibilidad
	super._ready()
	items_loaded.connect(_on_items_loaded)
	item_added.connect(_on_item_added)
	item_updated.connect(_on_item_updated)
	item_removed.connect(_on_item_removed)

# Funciones de compatibilidad que redirigen las señales
func _on_items_loaded():
	categories_loaded.emit()

func _on_item_added():
	category_added.emit()

func _on_item_updated():
	category_updated.emit()

func _on_item_removed():
	category_removed.emit()

# Funciones específicas de categorías
func get_category_by_id(id: String) -> Category:
	return get_item_by_id(id) as Category

func add_category(category: Category) -> bool:
	return add_item(category)

func update_category(updated_category: Category) -> bool:
	return update_item(updated_category)

func remove_category(category_id: String) -> bool:
	return remove_item(category_id)
