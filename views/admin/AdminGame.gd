extends Panel

# Referencias a nodos de la UI del panel de Juegos
@onready var name_input: LineEdit = $Items/Name/Input
@onready var desc_input: LineEdit = $Items/Desc/Input
@onready var studio_button: Button = $Items/Studio/SeleccionarBtn
@onready var studio_name_label: Label = $Items/Studio/StudioName
@onready var categories_button: Button = $Items/Categories/SeleccionarBtn
@onready var exe_input: LineEdit = $Items/Exe/Input
@onready var cover_input: LineEdit = $Items/Cover/Input
@onready var add_button: Button = $Items/AddButton/Button
@onready var file_dialog: FileDialog = $Items/FileDialog

# Paneles de selección
@onready var studios_list_panel: Panel = $StudiosList
@onready var categories_list_panel: Panel = $CategoriesList

# Referencias específicas del selector de estudios
@onready var studios_cancel_button: Button = $StudiosList/VBox/Cancelar/Button
@onready var studios_search: LineEdit = $StudiosList/VBox/Search

# Referencias específicas del selector de categorías  
@onready var categories_close_button: Button = $CategoriesList/VBox/Cerrar/Button
@onready var categories_search: LineEdit = $CategoriesList/VBox/Search
@onready var categories_grid: GridContainer = $CategoriesList/VBox/Container/Grid

# Contenedores dinámicos para los botones de estudios
var studios_container: VBoxContainer

# Datos del juego en proceso
var selected_studio_id: String = ""
var selected_categories: Array = []

var current_file_input_target: String

func _ready():
	# Conectar señales principales
	studio_button.pressed.connect(_on_studio_select_pressed)
	categories_button.pressed.connect(_on_categories_select_pressed)
	add_button.pressed.connect(_on_add_game_pressed)
	
	# Conectar eventos de focus para abrir FileDialog automáticamente
	exe_input.focus_entered.connect(func(): open_file_dialog("exe"))
	cover_input.focus_entered.connect(func(): open_file_dialog("cover"))
	
	# Configurar FileDialog
	setup_file_dialog()
	
	# Conectar señales de los selectores
	studios_cancel_button.pressed.connect(_on_studios_cancel_pressed)
	studios_search.text_changed.connect(_on_studios_search_changed)
	categories_close_button.pressed.connect(_on_categories_close_pressed)
	categories_search.text_changed.connect(_on_categories_search_changed)
	
	# Configurar contenedor dinámico para estudios
	setup_studios_container()
	
	# Configurar estado inicial
	studios_list_panel.visible = false
	categories_list_panel.visible = false
	
	DebugUtils.info("AdminGame panel inicializado")

func setup_file_dialog():
	# Configurar directorio inicial
	var base_dir = AppConfig.get_launcher_directory()
	file_dialog.current_dir = base_dir
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	
	# Conectar señal de selección de archivo
	file_dialog.file_selected.connect(_on_file_selected)
	
	DebugUtils.info("FileDialog configurado con directorio base: " + base_dir)

func open_file_dialog(target: String):
	current_file_input_target = target
	file_dialog.clear_filters()
	var filters = (ValidationUtils.get_executable_filters() if target == "exe"
					else ValidationUtils.get_image_filters())
	for filter in filters:
		file_dialog.add_filter(filter)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_file_selected(file_path: String):
	# Convertir a ruta relativa usando ValidationUtils
	var relative_path = ValidationUtils.convert_to_relative_path(file_path)
	
	# Asignar la ruta al campo correspondiente
	if current_file_input_target == "exe":
		exe_input.text = relative_path
		exe_input.release_focus()  # Quitar foco para evitar reabrir el dialog
		DebugUtils.info("Archivo ejecutable seleccionado: " + relative_path)
	elif current_file_input_target == "cover":
		cover_input.text = relative_path
		cover_input.release_focus()  # Quitar foco para evitar reabrir el dialog
		DebugUtils.info("Imagen de portada seleccionada: " + relative_path)
	
	current_file_input_target = ""

func _on_studio_select_pressed():
	DebugUtils.info("Abrir selector de estudios")
	studios_list_panel.visible = true
	populate_studios_list()

func _on_categories_select_pressed():
	DebugUtils.info("Abrir selector de categorías")
	DebugUtils.info("Categorías disponibles: " + str(CategoriesController.categories.size()))
	categories_list_panel.visible = true
	populate_categories_list()

# === SELECTOR DE ESTUDIOS ===

func setup_studios_container():
	# Crear contenedor dinámico para los botones de estudios
	studios_container = VBoxContainer.new()
	studios_list_panel.get_node("VBox").add_child(studios_container)
	studios_list_panel.get_node("VBox").move_child(studios_container, 2)  # Después del Search

func populate_studios_list(filter_text: String = ""):
	UIUtils.clear_container_children(studios_container)
	
	var filtered_studios = get_filtered_studios(filter_text)
	var count = 0
	var max_studios = 3
	
	for studio in filtered_studios:
		if count >= max_studios:
			break
			
		var new_studio_button = UIUtils.create_item_button(studio.name, "", Vector2(0, 40))
		new_studio_button.pressed.connect(func(): _on_studio_selected(studio))
		
		studios_container.add_child(new_studio_button)
		count += 1

func get_filtered_studios(filter_text: String) -> Array:
	var filtered = []
	filter_text = filter_text.to_lower()
	
	for studio in StudiosController.studios:
		if filter_text.is_empty() or studio.name.to_lower().contains(filter_text):
			filtered.append(studio)
	
	return filtered

func clear_studios_list():
	UIUtils.clear_container_children(studios_container)

func _on_studio_selected(studio: Studio):
	selected_studio_id = studio.id
	studio_name_label.text = studio.name
	studios_list_panel.visible = false
	DebugUtils.info("Estudio seleccionado: " + studio.name)

func _on_studios_cancel_pressed():
	studios_list_panel.visible = false

func _on_studios_search_changed(new_text: String):
	populate_studios_list(new_text)

# === SELECTOR DE CATEGORÍAS ===

func populate_categories_list(filter_text: String = ""):
	DebugUtils.info("Poblando lista de categorías con filtro: '" + filter_text + "'")
	clear_categories_list()
	
	var filtered_categories = get_filtered_categories(filter_text)
	DebugUtils.info("Categorías filtradas: " + str(filtered_categories.size()))
	
	for category in filtered_categories:
		DebugUtils.info("Creando item para categoría: " + category.name)
		create_category_item(category)

func get_filtered_categories(filter_text: String) -> Array:
	var filtered = []
	filter_text = filter_text.to_lower()
	
	for category in CategoriesController.categories:
		if filter_text.is_empty() or category.name.to_lower().contains(filter_text):
			filtered.append(category)
	
	return filtered

func create_category_item(category: Category):
	DebugUtils.info("Creando item para: " + category.name + " (ID: " + category.id + ")")
	
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(150, 30)
	
	var checkbox = CheckBox.new()
	checkbox.custom_minimum_size = Vector2(20, 30)
	checkbox.text = category.name
	# Marcar si ya está seleccionada
	checkbox.button_pressed = category.id in selected_categories
	checkbox.toggled.connect(func(pressed): _on_category_toggled(category.id, pressed))
	
	hbox.add_child(checkbox)
	
	if categories_grid:
		categories_grid.add_child(hbox)
		DebugUtils.info("Item agregado al grid correctamente")
	else:
		DebugUtils.error("categories_grid es null!")

func clear_categories_list():
	UIUtils.clear_container_children(categories_grid)

func _on_category_toggled(category_id: String, pressed: bool):
	if pressed:
		if category_id not in selected_categories:
			selected_categories.append(category_id)
	else:
		selected_categories.erase(category_id)
	
	DebugUtils.info("Categorías seleccionadas: " + str(selected_categories))

func _on_categories_close_pressed():
	categories_list_panel.visible = false

func _on_categories_search_changed(new_text: String):
	populate_categories_list(new_text)

func _on_add_game_pressed():
	DebugUtils.info("Intentando agregar juego...")
	var validation = ValidationUtils.validate_game_data(name_input.text, desc_input.text, selected_studio_id)
	if validation.is_valid:
		create_and_add_game()

func create_and_add_game():
	# Generar ID único para el juego
	var game_id = ValidationUtils.generate_safe_id(name_input.text)
	
	# Mostrar información sobre el juego que se va a crear
	DebugUtils.info("=== CREANDO JUEGO ===")
	DebugUtils.info("ID: " + game_id)
	DebugUtils.info("Nombre: " + name_input.text)
	DebugUtils.info("Estudio: " + selected_studio_id)
	DebugUtils.info("Categorías: " + str(selected_categories))
	
	# Crear nuevo juego
	var new_game = Game.new(
		game_id,
		name_input.text,
		desc_input.text,
		exe_input.text,
		cover_input.text,
		selected_studio_id,
		selected_categories,
		"1.0.0",
		Time.get_datetime_string_from_system()
	)
	
	# Agregar usando el controlador
	if GamesController.add_game(new_game):
		DebugUtils.info("✅ Juego agregado exitosamente: " + new_game.name)
		clear_form()
	else:
		DebugUtils.error("❌ Error al agregar el juego")

func clear_form():
	name_input.text = ""
	desc_input.text = ""
	exe_input.text = ""
	cover_input.text = ""
	studio_name_label.text = ""
	selected_studio_id = ""
	selected_categories.clear()
	
	# Limpiar búsquedas
	studios_search.text = ""
	categories_search.text = ""
	
	DebugUtils.info("Formulario limpiado")
