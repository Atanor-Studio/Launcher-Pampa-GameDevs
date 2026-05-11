extends Panel

# Referencias a nodos de la UI del Auth
@onready var password_input: LineEdit = $VBox/PasswordInput
@onready var login_button: Button = $VBox/Login/LoginButton
@onready var error_label: Label = $VBox/ErrorLabel
@onready var session_info: Label = $VBox/SessionInfo

# Timer para sesión automática
var session_timer: Timer
var session_update_timer: Timer

# Estado de autenticación
var is_authenticated: bool = false
var session_time_remaining: float = 0.0

# Señales para comunicarse con AdminView
signal authentication_successful
signal authentication_failed(message: String)
signal session_expired

func _ready():
	# Crear y configurar timers
	setup_timers()
	
	# Conectar señales
	login_button.pressed.connect(_on_login_pressed)
	password_input.text_submitted.connect(_on_password_submitted)
	
	# Configurar estado inicial
	setup_initial_state()

func setup_timers():
	# Timer principal de sesión
	session_timer = Timer.new()
	session_timer.wait_time = AppConfig.SESSION_DURATION
	session_timer.one_shot = true
	session_timer.timeout.connect(_on_session_timeout)
	add_child(session_timer)
	
	# Timer para actualizar el display cada segundo
	session_update_timer = Timer.new()
	session_update_timer.wait_time = 1.0
	session_update_timer.timeout.connect(_on_update_session_display)
	add_child(session_update_timer)

func setup_initial_state():
	error_label.visible = false
	session_info.visible = false
	password_input.visible = true
	password_input.editable = true
	login_button.text = "Iniciar Sesión"

func _on_login_pressed():
	if is_authenticated:
		logout()
	else:
		authenticate()

func _on_password_submitted(_text: String):
	if not is_authenticated:
		authenticate()

func authenticate():
	var input_password = password_input.text
	
	if input_password == AppConfig.ADMIN_PASSWORD:
		is_authenticated = true
		show_authenticated_state()
		start_session_timer()
		authentication_successful.emit()
		print("Administrador autenticado correctamente")
	else:
		show_error("Contraseña incorrecta")
		authentication_failed.emit("Contraseña incorrecta")
		print("Intento de autenticación fallido")

func show_authenticated_state():
	error_label.visible = false
	session_info.visible = true
	
	# Ocultar completamente el campo de contraseña y mostrar botón de logout
	password_input.visible = false
	login_button.text = "Cerrar Sesión"
	
	print("Sesión iniciada - Expira en", AppConfig.SESSION_DURATION / 60, "minutos")

func show_error(message: String):
	error_label.text = "Error: " + message
	error_label.visible = true
	session_info.visible = false

func logout():
	is_authenticated = false
	
	# Parar timers
	stop_session_timer()
	
	# Restaurar estado inicial
	password_input.text = ""
	password_input.visible = true
	password_input.editable = true
	error_label.visible = false
	session_info.visible = false
	login_button.text = "Iniciar Sesión"
	
	print("Sesión de administrador cerrada")

func start_session_timer():
	session_time_remaining = AppConfig.SESSION_DURATION
	session_timer.start()
	session_update_timer.start()
	update_session_display()

func stop_session_timer():
	session_timer.stop()
	session_update_timer.stop()
	session_time_remaining = 0.0

func reset_session_timer():
	if is_authenticated:
		session_time_remaining = AppConfig.SESSION_DURATION
		session_timer.start()
		update_session_display()

func _on_session_timeout():
	print("Sesión expirada por inactividad")
	show_error("Sesión expirada por inactividad")
	session_expired.emit()
	logout()

func _on_update_session_display():
	if is_authenticated:
		session_time_remaining = session_timer.time_left
		update_session_display()

func update_session_display():
	if is_authenticated and session_info.visible:
		var minutes = int(session_time_remaining / 60)
		var seconds = int(session_time_remaining) % 60
		session_info.text = "Sesión activa - Administrador\nTiempo restante: %02d:%02d" % [minutes, seconds]
		
		# Cambiar color y mostrar advertencias según el tiempo restante
		if session_time_remaining <= 30:  # Últimos 30 segundos
			session_info.modulate = Color.RED
			if int(session_time_remaining) % 10 == 0 and session_time_remaining > 0:
				print("⚠️ ADVERTENCIA: La sesión expirará en", int(session_time_remaining), "segundos")
		elif session_time_remaining <= 60:  # Último minuto
			session_info.modulate = Color.YELLOW
			if int(session_time_remaining) == 60:
				print("⚠️ ADVERTENCIA: La sesión expirará en 1 minuto")
		else:
			session_info.modulate = Color.GREEN

# Función para ser llamada desde AdminView cuando hay actividad
func handle_user_activity():
	reset_session_timer()
