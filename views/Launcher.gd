extends CanvasLayer

const ITEM_ENTRY_SCENE = preload("uid://5dn18av3mq22")

# Referencias a nodos de la UI
@onready var games_button: Button = $Container/Banner/Nav/Games/Button
@onready var studios_button: Button = $Container/Banner/Nav/Studios/Button
@onready var admin_button: Button = $Container/Banner/AdminBtn
@onready var search_field: LineEdit = $Container/Search/HBox/LineEdit
@onready var filter_button: Button = $Container/Search/HBox/FilterBtn
@onready var sort_option: OptionButton = $Container/Search/HBox/SortOption
@onready var filter_panel: PanelContainer = $Container/ItemList/CategoriesPanel
@onready var filter_grid: GridContainer = $Container/ItemList/CategoriesPanel/VBox/Grid
@onready var grid_container: GridContainer = $Container/ItemList/ItemsPanel/Items/Grid
@onready var data_view: CanvasLayer = $DataView
@onready var admin_view: CanvasLayer = $AdminView

# Enum para las vistas
enum ViewType {
	GAMES,
	STUDIOS
}

# Enum para ordenamiento de juegos
enum SortOrder {
	NEWEST_FIRST,
	OLDEST_FIRST,
	NAME_ASC,
	NAME_DESC
}

# Variables de estado
var current_view: ViewType = ViewType.GAMES
var selected_categories: Array = []
var current_sort_order: SortOrder = SortOrder.NEWEST_FIRST

func _ready():
	# Conectar señales de los controladores (Autoloads)
	GamesController.games_loaded.connect(_on_games_loaded)
	GamesController.game_added.connect(_on_games_button_pressed)
	GamesController.game_removed.connect(_on_games_button_pressed)
	GamesController.game_updated.connect(_on_games_button_pressed)
	StudiosController.studios_loaded.connect(_on_studios_loaded)
	StudiosController.studio_added.connect(_on_studios_button_pressed)
	StudiosController.studio_removed.connect(_on_studios_button_pressed)
	StudiosController.studio_updated.connect(_on_studios_button_pressed)
	CategoriesController.categories_loaded.connect(_on_categories_loaded)
	
	# Conectar señales del DataView
	data_view.game_launch_requested.connect(_on_game_launch_requested)
	data_view.studio_selected.connect(_on_studio_selected_from_dataview)
	
	# Conectar botones de navegación
	games_button.pressed.connect(_on_games_button_pressed)
	studios_button.pressed.connect(_on_studios_button_pressed)
	admin_button.pressed.connect(_on_admin_button_pressed)
	
	# Conectar búsqueda
	search_field.text_changed.connect(_on_search_text_changed)
	filter_button.pressed.connect(_on_filter_button_pressed)
	
	# Configurar y conectar el OptionButton de ordenamiento
	_setup_sort_option()
	sort_option.item_selected.connect(_on_sort_option_selected)
	
	# Configurar estado inicial del panel de filtros
	filter_panel.visible = false
	
	_on_games_button_pressed()
	_on_categories_loaded()

func _on_games_loaded():
	print("Juegos cargados:")
	for game in GamesController.games:
		print("- ", game.name, " por ", get_studio_name(game.studio_id))
	
	# Si estamos en vista de juegos, actualizar la vista
	if current_view == ViewType.GAMES:
		show_games()

func _on_studios_loaded():
	# Si estamos en vista de estudios, actualizar la vista
	if current_view == ViewType.STUDIOS:
		show_studios()

func _on_categories_loaded():
	print("Categorías cargadas:")
	for category in CategoriesController.categories:
		print("- ", category.name)
	
	# Poblar el grid de filtros con las categorías
	populate_filter_categories()

func _on_games_button_pressed():
	current_view = ViewType.GAMES
	filter_button.disabled = false  # Habilitar filtro para juegos
	sort_option.visible = true  # Mostrar ordenamiento para juegos
	update_navigation_buttons()
	show_games()

func _on_studios_button_pressed():
	current_view = ViewType.STUDIOS
	# Limpiar filtros de categorías al cambiar a estudios
	selected_categories.clear()
	update_category_checkboxes()
	filter_button.disabled = true  # Deshabilitar filtro para estudios
	sort_option.visible = false  # Ocultar ordenamiento para estudios
	# Cerrar el panel de filtros si está abierto
	if filter_panel.visible:
		filter_panel.visible = false
	update_navigation_buttons()
	show_studios()

func _on_admin_button_pressed():
	print("Abriendo panel de administración")
	admin_view.visible = true

func _on_filter_button_pressed():
	filter_panel.visible = !filter_panel.visible

func _on_search_text_changed(filter_text: String):
	filter_items(filter_text)

func update_navigation_buttons():
	# Actualizar el estilo de los botones para mostrar cuál está activo
	games_button.disabled = (current_view == ViewType.GAMES)
	studios_button.disabled = (current_view == ViewType.STUDIOS)
	
	# Borrar texto del filtrado al cambiar de vista
	search_field.text = ''

func show_games():
	clear_grid()
	
	# Obtener juegos ordenados según la preferencia actual
	var sorted_games: Array
	match current_sort_order:
		SortOrder.NEWEST_FIRST:
			sorted_games = GamesController.get_games_sorted_by_date(false)
		SortOrder.OLDEST_FIRST:
			sorted_games = GamesController.get_games_sorted_by_date(true)
		SortOrder.NAME_ASC:
			sorted_games = GamesController.games.duplicate()
			sorted_games.sort_custom(func(a, b): return a.name < b.name)
		SortOrder.NAME_DESC:
			sorted_games = GamesController.games.duplicate()
			sorted_games.sort_custom(func(a, b): return a.name > b.name)
		_:
			sorted_games = GamesController.get_games_sorted_by_date(false)
	
	for game in sorted_games:
		create_item(game)
	
	# Esperar un frame antes de animar para asegurar que todo esté renderizado
	await get_tree().process_frame
	# Animar los elementos de la lista con delay escalonado
	AnimationUtils.animate_list_items(grid_container, 0.05)

func show_studios():
	clear_grid()
	
	for studio in StudiosController.studios:
		create_item(studio)
	
	# Esperar un frame antes de animar para asegurar que todo esté renderizado
	await get_tree().process_frame
	# Animar los elementos de la lista con delay escalonado
	AnimationUtils.animate_list_items(grid_container, 0.05)

func create_item(data: Resource):
	var item = ITEM_ENTRY_SCENE.instantiate()
	grid_container.add_child(item)
	item.setup_item(data)
	item.button.pressed.connect(func(): _on_item_clicked(data))

func _on_item_clicked(item_data: Resource):
	if item_data is Game:
		_on_game_item_pressed(item_data)
	elif item_data is Studio:
		_on_studio_item_pressed(item_data)

func _on_game_item_pressed(game: Game):
	print("Juego seleccionado: ", game.name)
	# Mostrar detalles del juego en DataView
	data_view.show_game_details(game)

func _on_studio_item_pressed(studio: Studio):
	print("Estudio seleccionado: ", studio.name)
	# Mostrar detalles del estudio en DataView
	data_view.show_studio_details(studio)

func filter_items(_search_text: String):
	# Usar la nueva función unificada de filtrado
	apply_current_filter()

func clear_grid():
	for child in grid_container.get_children():
		child.queue_free()

func get_studio_name(studio_id: String) -> String:
	var studio = StudiosController.get_studio_by_id(studio_id)
	return studio.name if studio else "Estudio desconocido"

# Callbacks del DataView
func _on_game_launch_requested(game: Game):
	GamesController.launch_game(game)

func _on_studio_selected_from_dataview(studio: Studio):
	data_view.show_studio_details(studio)

# === FUNCIONES DE FILTRADO POR CATEGORÍAS ===

func populate_filter_categories():
	# Limpiar el grid de categorías
	clear_filter_grid()
	
	for category in CategoriesController.categories:
		create_category_filter_item(category)

func create_category_filter_item(category: Category):
	var checkbox = CheckBox.new()
	checkbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	checkbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	checkbox.text = category.name
	checkbox.button_pressed = category.id in selected_categories
	checkbox.toggled.connect(func(pressed): _on_category_filter_toggled(category.id, pressed))
	
	filter_grid.add_child(checkbox)

func clear_filter_grid():
	for child in filter_grid.get_children():
		child.queue_free()

func _on_category_filter_toggled(category_id: String, pressed: bool):
	if pressed:
		if category_id not in selected_categories:
			selected_categories.append(category_id)
	else:
		selected_categories.erase(category_id)
	
	print("Categorías seleccionadas para filtro: ", selected_categories)
	# Aplicar filtro inmediatamente
	apply_current_filter()

func update_category_checkboxes():
	# Actualizar el estado de los checkboxes de categorías
	for child in filter_grid.get_children():
		if child is CheckBox:
			# Buscar la categoría por nombre y actualizar el checkbox
			for category in CategoriesController.categories:
				if category.name == child.text:
					child.button_pressed = category.id in selected_categories
					break

func apply_current_filter():
	var search_text = search_field.text
	
	if search_text.is_empty() and selected_categories.is_empty():
		# Sin filtros, mostrar todo ordenado
		if current_view == ViewType.GAMES:
			show_games()
		else:
			show_studios()
		return
	
	clear_grid()
	search_text = search_text.to_lower()
	
	if current_view == ViewType.GAMES:
		# Obtener juegos ordenados primero
		var sorted_games: Array
		match current_sort_order:
			SortOrder.NEWEST_FIRST:
				sorted_games = GamesController.get_games_sorted_by_date(false)
			SortOrder.OLDEST_FIRST:
				sorted_games = GamesController.get_games_sorted_by_date(true)
			SortOrder.NAME_ASC:
				sorted_games = GamesController.games.duplicate()
				sorted_games.sort_custom(func(a, b): return a.name < b.name)
			SortOrder.NAME_DESC:
				sorted_games = GamesController.games.duplicate()
				sorted_games.sort_custom(func(a, b): return a.name > b.name)
			_:
				sorted_games = GamesController.get_games_sorted_by_date(false)
		
		# Aplicar filtros a los juegos ordenados
		for game in sorted_games:
			var matches_search = search_text.is_empty() or (
				game.name.to_lower().contains(search_text) or 
				game.description.to_lower().contains(search_text) or
				get_studio_name(game.studio_id).to_lower().contains(search_text)
			)
			
			var matches_categories = selected_categories.is_empty()
			if not matches_categories:
				# Verificar si el juego tiene TODAS las categorías seleccionadas
				matches_categories = true
				for selected_cat in selected_categories:
					if selected_cat not in game.category_ids:
						matches_categories = false
						break
			
			if matches_search and matches_categories:
				create_item(game)
	else:
		# Para estudios, solo aplicar filtro de búsqueda (las categorías son solo para juegos)
		for studio in StudiosController.studios:
			if search_text.is_empty() or (
				studio.name.to_lower().contains(search_text) or
				studio.description.to_lower().contains(search_text)
			):
				create_item(studio)
	
	# Esperar un frame antes de animar elementos filtrados
	await get_tree().process_frame
	# Animar los elementos filtrados con delay escalonado
	AnimationUtils.animate_list_items(grid_container, 0.05)

# === FUNCIONES DE ORDENAMIENTO ===

func _setup_sort_option():
	# Configurar opciones del OptionButton
	sort_option.clear()
	sort_option.add_item("Nuevos", SortOrder.NEWEST_FIRST)
	sort_option.add_item("Antiguos", SortOrder.OLDEST_FIRST)
	sort_option.add_item("Nombre A-Z", SortOrder.NAME_ASC)
	sort_option.add_item("Nombre Z-A", SortOrder.NAME_DESC)
	sort_option.selected = SortOrder.NEWEST_FIRST

func _on_sort_option_selected(index: int):
	var sort_order = sort_option.get_item_id(index)
	set_sort_order(sort_order)

func set_sort_order(sort_order: SortOrder):
	current_sort_order = sort_order
	print("Cambiando orden de clasificación a: ", _get_sort_order_name(sort_order))
	
	# Recargar la vista actual con el nuevo ordenamiento
	if current_view == ViewType.GAMES:
		apply_current_filter()  # Usar apply_current_filter para mantener los filtros activos

func _get_sort_order_name(sort_order: SortOrder) -> String:
	match sort_order:
		SortOrder.NEWEST_FIRST:
			return "Más nuevos primero"
		SortOrder.OLDEST_FIRST:
			return "Más antiguos primero"
		SortOrder.NAME_ASC:
			return "Nombre A-Z"
		SortOrder.NAME_DESC:
			return "Nombre Z-A"
		_:
			return "Desconocido"

# Funciones públicas para cambiar el ordenamiento (para usar desde la UI)
func sort_by_newest_first():
	set_sort_order(SortOrder.NEWEST_FIRST)

func sort_by_oldest_first():
	set_sort_order(SortOrder.OLDEST_FIRST)

func sort_by_name_asc():
	set_sort_order(SortOrder.NAME_ASC)

func sort_by_name_desc():
	set_sort_order(SortOrder.NAME_DESC)
