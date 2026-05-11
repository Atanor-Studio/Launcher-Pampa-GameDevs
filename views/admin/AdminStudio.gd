extends Panel

# Referencias a nodos de la UI del panel de Estudios
@onready var name_input: LineEdit = $Items/Name/Input
@onready var desc_input: LineEdit = $Items/Description/Input
@onready var website_input: LineEdit = $Items/Website/Input
@onready var logo_input: LineEdit = $Items/Logo/Input
@onready var cover_input: LineEdit = $Items/Cover/Input
@onready var add_button: Button = $Items/AddButton/Button
@onready var file_dialog: FileDialog = $Items/FileDialog

var current_file_input_target: String

func _ready():
	# Conectar señales
	add_button.pressed.connect(_on_add_studio_pressed)
	
	# Conectar eventos de focus para abrir FileDialog automáticamente
	logo_input.focus_entered.connect(func(): open_file_dialog("logo"))
	cover_input.focus_entered.connect(func(): open_file_dialog("cover"))
	
	# Configurar FileDialog
	setup_file_dialog()
	
	DebugUtils.info("AdminStudio panel inicializado")

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
	var filters = ValidationUtils.get_image_filters()
	for filter in filters:
		file_dialog.add_filter(filter)
	file_dialog.popup_centered(Vector2i(800, 600))

func _on_file_selected(file_path: String):
	# Convertir a ruta relativa usando ValidationUtils
	var relative_path = ValidationUtils.convert_to_relative_path(file_path)
	
	# Asignar la ruta al campo correspondiente
	if current_file_input_target == "logo":
		logo_input.text = relative_path
		logo_input.release_focus()  # Quitar foco para evitar reabrir el dialog
		DebugUtils.info("Logo seleccionado: " + relative_path)
	elif current_file_input_target == "cover":
		cover_input.text = relative_path
		cover_input.release_focus()  # Quitar foco para evitar reabrir el dialog
		DebugUtils.info("Imagen de portada seleccionada: " + relative_path)
	
	current_file_input_target = ""

func _on_add_studio_pressed():
	DebugUtils.info("Intentando agregar estudio...")
	var validation = ValidationUtils.validate_studio_data(name_input.text, desc_input.text)
	if validation.is_valid:
		create_and_add_studio()

func create_and_add_studio():
	# Generar ID único para el estudio
	var studio_id = ValidationUtils.generate_safe_id(name_input.text)
	
	# Crear nuevo estudio
	var new_studio = Studio.new(
		studio_id,
		name_input.text,
		desc_input.text,
		website_input.text,
		logo_input.text,
		cover_input.text,
	)
	
	# Agregar usando el controlador
	if StudiosController.add_studio(new_studio):
		DebugUtils.info("✅ Estudio agregado exitosamente: " + new_studio.name)
		clear_form()
	else:
		DebugUtils.error("❌ Error al agregar el estudio")

func clear_form():
	name_input.text = ""
	desc_input.text = ""
	website_input.text = ""
	logo_input.text = ""
	cover_input.text = ""
	DebugUtils.info("Formulario limpiado")
