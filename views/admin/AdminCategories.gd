extends Panel

# Enum para los modos
enum Mode {
	NEW,
	EDIT
}

# Referencias a nodos de la UI
@onready var new_button: Button = $Selected/Option/New
@onready var selected_button: Button = $Selected/Option/Selected
@onready var name_input: LineEdit = $Selected/Names/NameLine
@onready var id_input: LineEdit = $Selected/Names/IDLine
@onready var color_picker: ColorPickerButton = $Selected/Buttons/ColorButton
@onready var add_save_button: Button = $Selected/Buttons/AddSave
@onready var categories_grid: GridContainer = $Scroll/Grid

# Variables de estado
var current_mode: Mode = Mode.NEW
var selected_category: Category = null

func _ready():
	# Conectar señales
	new_button.pressed.connect(_on_new_button_pressed)
	selected_button.pressed.connect(_on_selected_button_pressed)
	add_save_button.pressed.connect(_on_add_save_button_pressed)
	name_input.text_changed.connect(_on_name_input_changed)
	
	# Conectar señales del controlador
	CategoriesController.categories_loaded.connect(_on_categories_loaded)
	CategoriesController.category_added.connect(_on_categories_loaded)
	CategoriesController.category_updated.connect(_on_categories_loaded)
	CategoriesController.category_removed.connect(_on_categories_loaded)
	
	# Configurar estado inicial
	set_mode(Mode.NEW)
	populate_categories_grid()
	
	DebugUtils.info("AdminCategories panel initialized", "AdminCategories")

# Función para reiniciar la vista cuando se sale del AdminView
func reset_view():
	set_mode(Mode.NEW)
	populate_categories_grid()
	DebugUtils.info("Categories view reset", "AdminCategories")

func _on_categories_loaded():
	populate_categories_grid()

func set_mode(mode: Mode):
	current_mode = mode
	if mode == Mode.NEW:
		new_button.disabled = true
		selected_button.disabled = false
		add_save_button.text = "CREAR"
		id_input.editable = true  # Permitir edición en modo NEW
		clear_form()
		selected_category = null
	else:  # Mode.EDIT
		new_button.disabled = false
		selected_button.disabled = true
		add_save_button.text = "GUARDAR"
		id_input.editable = false  # No permitir edición en modo EDIT

func _on_new_button_pressed():
	set_mode(Mode.NEW)

func _on_selected_button_pressed():
	# Solo se puede usar si hay una categoría seleccionada
	if selected_category:
		set_mode(Mode.NEW)
		selected_category = null

func _on_name_input_changed(new_text: String):
	# Auto-generar ID basado en el nombre si estamos en modo NEW
	if current_mode == Mode.NEW and not new_text.is_empty():
		var auto_id = ValidationUtils.generate_safe_id(new_text, "categoria_sin_nombre")
		id_input.text = auto_id

func _on_add_save_button_pressed():
	if current_mode == Mode.NEW:
		create_category()
	else:
		update_category()

func create_category():
	var existing_ids = []
	for category in CategoriesController.categories:
		existing_ids.append(category.id)
	
	var validation = ValidationUtils.validate_category_data(name_input.text, id_input.text, existing_ids)
	
	if not validation.is_valid:
		DebugUtils.error("Validation failed: " + str(validation.errors), "AdminCategories")
		return
	
	var new_category = Category.new(
		id_input.text,
		name_input.text,
		"",  # description vacía por ahora
		color_picker.color.to_html()
	)
	
	if CategoriesController.add_category(new_category):
		DebugUtils.info("Category created successfully: " + new_category.name, "AdminCategories")
		UIUtils.show_success_message(self, "Éxito", "Categoría creada exitosamente")
		clear_form()
	else:
		DebugUtils.error("Failed to create category: " + new_category.name, "AdminCategories")
	
func update_category():
	if not selected_category:
		DebugUtils.error("No category selected for update", "AdminCategories")
		return
	
	# Para edición, excluir la categoría actual de la validación de ID único
	var existing_ids = []
	for category in CategoriesController.categories:
		if category != selected_category:
			existing_ids.append(category.id)
	
	var validation = ValidationUtils.validate_category_data(name_input.text, id_input.text, existing_ids)
	
	if not validation.is_valid:
		DebugUtils.error("Validation failed: " + str(validation.errors), "AdminCategories")
		return
	
	selected_category.name = name_input.text
	selected_category.id = id_input.text
	selected_category.color = color_picker.color.to_html()
	
	if CategoriesController.update_category(selected_category):
		DebugUtils.info("Category updated successfully: " + selected_category.name, "AdminCategories")
		UIUtils.show_success_message(self, "Éxito", "Categoría actualizada exitosamente")
		set_mode(Mode.NEW)
	else:
		DebugUtils.error("Failed to update category: " + selected_category.name, "AdminCategories")

func clear_form():
	name_input.text = ""
	id_input.text = ""
	color_picker.color = Color.WHITE

func populate_categories_grid():
	DebugUtils.info("Populating categories grid...", "AdminCategories")
	clear_categories_grid()
	
	for category in CategoriesController.categories:
		create_category_button(category)
	
	DebugUtils.info("Grid populated with %d categories" % CategoriesController.categories.size(), "AdminCategories")

func clear_categories_grid():
	UIUtils.clear_container_children(categories_grid)

func create_category_button(category: Category):
	var category_button = UIUtils.create_item_button(category.name, "", Vector2(150, 40), category.name)
	
	# Aplicar color de la categoría
	UIUtils.apply_category_color_to_button(category_button, category)
	
	# Conectar señal para seleccionar categoría
	category_button.pressed.connect(func(): _on_category_selected(category))
	
	categories_grid.add_child(category_button)

func _on_category_selected(category: Category):
	DebugUtils.info("Category selected: " + category.name, "AdminCategories")
	selected_category = category
	
	# Llenar el formulario con los datos de la categoría
	name_input.text = category.name
	id_input.text = category.id
	color_picker.color = Color.from_string(category.color, Color.WHITE)
	
	# Cambiar a modo EDIT
	set_mode(Mode.EDIT)
