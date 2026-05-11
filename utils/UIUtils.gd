class_name UIUtils
extends RefCounted

# === CREACIÓN DE ELEMENTOS UI ===
## Crea un item de filtro de categoría reutilizable
static func create_category_filter_item(category: Category, selected_categories: Array, callback: Callable) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(150, 30)
	
	var checkbox = CheckBox.new()
	checkbox.custom_minimum_size = Vector2(20, 30)
	checkbox.button_pressed = category.id in selected_categories
	checkbox.toggled.connect(func(pressed): callback.call(category.id, pressed))
	
	var label = Label.new()
	label.text = category.name
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	hbox.add_child(checkbox)
	hbox.add_child(label)
	
	return hbox

## Crea un botón estandardizado para items (juegos, estudios, etc.)
static func create_item_button(title: String, subtitle: String = "", min_size: Vector2 = Vector2(200, 150), tooltip: String = "") -> Button:
	var button = Button.new()
	
	if subtitle.is_empty():
		button.text = title
	else:
		button.text = title + "\n" + subtitle
	
	button.custom_minimum_size = min_size
	button.tooltip_text = tooltip if not tooltip.is_empty() else title
	
	return button

# === GESTIÓN DE ESTADO DE UI ===
## Limpia todos los hijos de un contenedor de forma segura
static func clear_container_children(container: Node):
	for child in container.get_children():
		child.queue_free()

# === UTILIDADES DE COLOR ===
## Convierte un string de color a Color con fallback seguro
static func get_color_from_string(color_string: String, fallback: Color = Color.WHITE) -> Color:
	if color_string.is_empty():
		return fallback
		
	# Intentar parsear el color
	var color = Color.from_string(color_string, fallback)
	
	# Validar que el color sea diferente al fallback o que el string sea exactamente el fallback
	if color != fallback or color_string.to_lower() == "white":
		return color
	else:
		return fallback

## Aplica el color de una categoría a un botón
static func apply_category_color_to_button(button: Button, category: Category):
	var category_color = get_color_from_string(category.color, Color.WHITE)
	button.modulate = category_color

# === DIÁLOGOS Y MENSAJES ===
## Muestra un mensaje de éxito
static func show_success_message(parent: Node, title: String, message: String):
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	parent.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())
