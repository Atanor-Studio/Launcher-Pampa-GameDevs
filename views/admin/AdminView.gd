extends CanvasLayer

# Referencias a nodos de la UI
@onready var tab_container: TabContainer = $TabContainer
@onready var admin_auth: Panel = $TabContainer/Auth
@onready var admin_categories: Panel = $TabContainer/Categorias
@onready var close_button: Button = $Close

func _ready():
	# Conectar señales del AdminAuth
	admin_auth.authentication_successful.connect(_on_authentication_successful)
	admin_auth.authentication_failed.connect(_on_authentication_failed)
	admin_auth.session_expired.connect(_on_session_expired)
	
	# Conectar señales de la UI
	close_button.pressed.connect(_on_close_pressed)
	
	# Configurar estado inicial
	visible = false
	setup_initial_state()

func setup_initial_state():
	# Ocultar las pestañas inicialmente
	tab_container.tabs_visible = false
	# Mostrar el tab de autenticación por defecto
	tab_container.current_tab = 0

func _on_authentication_successful():
	print("AdminView: Autenticación exitosa")
	enable_admin_tabs()

func _on_authentication_failed(message: String):
	print("AdminView: Fallo de autenticación - ", message)
	# Aquí podrías agregar lógica adicional como logging, etc.

func _on_session_expired():
	print("AdminView: Sesión expirada")
	disable_admin_tabs()
	# Podrías mostrar una notificación adicional aquí

func enable_admin_tabs():
	# Habilitar todos los tabs de administración
	tab_container.tabs_visible = true
	# Cambiar al primer tab de administración (Juego)
	tab_container.current_tab = 1

func disable_admin_tabs():
	# Deshabilitar tabs de administración
	setup_initial_state()
	tab_container.current_tab = 0

func _on_close_pressed():
	# Reiniciar la vista de categorías antes de cerrar
	if admin_categories and admin_categories.has_method("reset_view"):
		admin_categories.reset_view()
	
	visible = false

func _input(event):
	# Cerrar con ESC
	if event.is_action_pressed("ui_cancel"):
		# Reiniciar la vista de categorías antes de cerrar
		if admin_categories and admin_categories.has_method("reset_view"):
			admin_categories.reset_view()
		
		visible = false
		return
	
	# Delegar el manejo de actividad al AdminAuth
	if visible and admin_auth.is_authenticated and (event is InputEventMouseButton or 
										event is InputEventKey or 
										event is InputEventMouseMotion):
		admin_auth.handle_user_activity()
