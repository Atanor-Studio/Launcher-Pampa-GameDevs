extends CanvasLayer

const ITEM_ENTRY_SCENE = preload("uid://5dn18av3mq22")

# Referencias a nodos de la UI
@onready var cont: HBoxContainer = $Cont
@onready var name_label: Label = $Cont/Panel/VBox/Name
@onready var description_label: Label = $Cont/Panel/VBox/Description
@onready var studio_container: Control = $Cont/Panel/VBox/Studio
@onready var studio_logo: TextureRect = $Cont/Panel/VBox/Studio/HBox/Logo
@onready var studio_button: Button = $Cont/Panel/VBox/Studio/HBox/NameButton
@onready var categories: Control = $Cont/Categories
@onready var categories_panel_container: PanelContainer = $Cont/Categories/Container
@onready var categories_container: VBoxContainer = $Cont/Categories/Container/VBox/List
@onready var games_container: HBoxContainer = $Cont/Panel/VBox/Games/HBox
@onready var cover_image: TextureRect = $Cont/Panel/Cover
@onready var close_button: Button = $Cont/Panel/Close
@onready var play_button: Button = $Cont/Panel/Play

# Datos actuales
var current_game: Game
var current_studio: Studio

# Señales
signal game_launch_requested(game: Game)
signal studio_selected(studio: Studio)

enum DataType {
	GAME,
	STUDIO
}

func _ready():
	# Conectar señales de la UI
	close_button.pressed.connect(_on_close_pressed)
	play_button.pressed.connect(_on_play_pressed)
	studio_button.pressed.connect(_on_studio_button_pressed)
	
	# Ocultar por defecto
	visible = false

func show_game_details(game: Game):
	if not game:
		return
	
	current_game = game
	current_studio = null
	
	# Configurar información básica
	name_label.text = game.name
	description_label.text = game.description
	
	# Mostrar información del estudio
	var studio = StudiosController.get_studio_by_id(game.studio_id)
	if studio:
		studio_container.visible = true
		studio_button.text = studio.name
		if studio.logo_path != "":
			var logo_texture = FileUtils.load_texture_safe(studio.logo_path)
			if logo_texture:
				studio_logo.texture = logo_texture
		else:
			studio_logo.texture = null
	else:
		studio_container.visible = false
	
	# Mostrar categorías
	show_categories_for_game(game)
	
	# Ocultar la sección de juegos (solo para estudios)
	games_container.get_parent().visible = false
	
	# Configurar imagen de portada
	if game.cover_path != "":
		var cover_texture = FileUtils.load_texture_safe(game.cover_path)
		if cover_texture:
			cover_image.texture = cover_texture
	else:
		cover_image.texture = null
	
	# Mostrar botón de jugar
	play_button.visible = true
	
	# Forzar actualización del layout completo
	await get_tree().process_frame
	
	# Mostrar la vista con animación de entrada
	visible = true
	AnimationUtils.entrance_animation(cont, "slide_right", 0.4)

func show_studio_details(studio: Studio):
	if not studio:
		return
	
	current_studio = studio
	current_game = null
	
	# Configurar información básica
	categories.visible = false
	name_label.text = studio.name
	description_label.text = studio.description
	if studio.website != "":
		description_label.text += "\nWebsite: " + studio.website
	
	# Ocultar información del estudio en estudio
	studio_container.visible = false
	
	# Mostrar juegos del estudio
	show_games_for_studio(studio)
	
	# Mostrar categorías vacías (los estudios no tienen categorías directas)
	clear_categories()
	
	# Configurar imagen de portada
	if studio.cover_path != "":
		var cover_texture = FileUtils.load_texture_safe(studio.cover_path)
		if cover_texture:
			cover_image.texture = cover_texture
	else:
		cover_image.texture = null
	
	# Ocultar botón de jugar (no se puede "jugar" un estudio)
	play_button.visible = false
	
	# Mostrar la vista con animación de entrada
	visible = true
	AnimationUtils.entrance_animation(cont, "slide_right", 0.4)

func show_categories_for_game(game: Game):
	categories.visible = true
	clear_categories()
	
	for category_id in game.category_ids:
		var category = CategoriesController.get_category_by_id(category_id)
		if category:
			var category_button = Button.new()
			category_button.text = category.name
			category_button.tooltip_text = category.description
			category_button.flat = true
			
			# Aplicar color de la categoría si está disponible
			if category.color != "":
				var color = Color(category.color)
				category_button.modulate = color
			
			categories_container.add_child(category_button)
	
	# Forzar actualización del layout del PanelContainer de categorías
	await get_tree().process_frame
	categories_panel_container.queue_redraw()
	categories_panel_container.set_size(categories_panel_container.size)

func show_games_for_studio(studio: Studio):
	clear_games()
	games_container.get_parent().visible = true
	
	var studio_games = GamesController.get_games_by_studio(studio.id)
	
	for game in studio_games:
		var item = ITEM_ENTRY_SCENE.instantiate()
		games_container.add_child(item)
		item.setup_item(game)
		item.button.pressed.connect(func(): show_game_details(game))
	
	# Animar los juegos del estudio con delay escalonado
	AnimationUtils.animate_list_items(games_container, 0.07)

func clear_categories():
	for child in categories_container.get_children():
		child.queue_free()

func clear_games():
	for child in games_container.get_children():
		child.queue_free()

func _on_close_pressed():
	visible = false

func _on_play_pressed():
	if current_game:
		game_launch_requested.emit(current_game)

func _on_studio_button_pressed():
	if current_game:
		var studio = StudiosController.get_studio_by_id(current_game.studio_id)
		if studio:
			studio_selected.emit(studio)
