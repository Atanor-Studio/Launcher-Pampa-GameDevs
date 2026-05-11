class_name AppConfig
extends RefCounted

# Configuración básica del launcher
const ADMIN_PASSWORD = "adminpass123"
const SESSION_DURATION = 300.0  # 5 minutos

# Función para obtener la ruta base del launcher cuando esté compilado
static func get_launcher_directory() -> String:
	if OS.has_feature("editor"):
		return "res://"
	else:
		# En versión compilada, usar la carpeta donde está el ejecutable
		return OS.get_executable_path().get_base_dir() + "/"

static func get_data_directory() -> String:
	return get_launcher_directory() + "data/"
