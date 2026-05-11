class_name BaseController
extends Node

# Señales genéricas que heredarán los controladores
signal items_loaded
signal item_added
signal item_updated
signal item_removed

var items: Array = []

# Métodos abstractos que deben ser implementados por las clases hijas
func get_file_name() -> String:
	# Debe ser sobrescrito por cada controlador hijo
	assert(false, "get_file_name() debe ser implementado en la clase hija")
	return ""

func create_item_from_dict(_data: Dictionary) -> Resource:
	# Debe ser sobrescrito por cada controlador hijo
	assert(false, "create_item_from_dict() debe ser implementado en la clase hija")
	return null

func get_item_type_name() -> String:
	# Debe ser sobrescrito por cada controlador hijo (para logs)
	assert(false, "get_item_type_name() debe ser implementado en la clase hija")
	return ""

# Implementación común
func _ready():
	load_items()

func load_items():
	items.clear()
	var file_path = FileUtils.get_data_path(get_file_name())
	var item_type = get_item_type_name()
	
	DebugUtils.info("Intentando cargar " + item_type + "s desde: " + file_path)
	var load_result = FileUtils.load_json_file(file_path)
	
	if load_result.success and load_result.data != null:
		for item_data in load_result.data:
			var item = create_item_from_dict(item_data)
			if item:
				items.append(item)
		DebugUtils.info(item_type + "s cargados: " + str(items.size()))
	else:
		DebugUtils.error("Error cargando archivo de " + item_type + "s: " + load_result.error)
	
	items_loaded.emit()

func save_items():
	var items_data = []
	for item in items:
		if item.has_method("to_dict"):
			items_data.append(item.to_dict())
	
	var file_path = FileUtils.get_data_path(get_file_name())
	var item_type = get_item_type_name()
	var save_result = FileUtils.save_json_file(file_path, items_data)
	
	if save_result.success:
		DebugUtils.info(item_type + "s guardados exitosamente")
	else:
		DebugUtils.error("Error guardando archivo de " + item_type + "s: " + save_result.error)

func get_item_by_id(id: String) -> Resource:
	for item in items:
		if item.id == id:
			return item
	return null

func add_item(item: Resource) -> bool:
	var item_type = get_item_type_name()
	
	# Verificar que no exista un item con el mismo ID
	if get_item_by_id(item.id) != null:
		DebugUtils.error(item_type + " con ID " + item.id + " ya existe")
		return false
	
	items.append(item)
	save_items()
	
	# Recargar los items para asegurarse de que estén sincronizados
	load_items()
	
	item_added.emit()
	return true

func update_item(updated_item: Resource) -> bool:
	var item_type = get_item_type_name()
	
	for i in range(items.size()):
		if items[i].id == updated_item.id:
			items[i] = updated_item
			save_items()
			
			# Recargar los items para asegurarse de que estén sincronizados
			load_items()
			
			item_updated.emit()
			return true
	
	DebugUtils.error(item_type + " con ID " + updated_item.id + " no encontrado")
	return false

func remove_item(item_id: String) -> bool:
	var item_type = get_item_type_name()
	
	for i in range(items.size()):
		if items[i].id == item_id:
			items.remove_at(i)
			save_items()
			
			# Recargar los items para asegurarse de que estén sincronizados
			load_items()
			
			item_removed.emit()
			return true
	
	DebugUtils.error(item_type + " con ID " + item_id + " no encontrado")
	return false
