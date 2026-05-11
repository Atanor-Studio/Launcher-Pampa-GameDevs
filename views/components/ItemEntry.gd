extends Panel

@onready var title_label: Label = $Item/Title
@onready var cover_texture: TextureRect = $Item/Cover/Image
@onready var button: Button = $Button

var item_data: Resource

func _ready():
	# Configurar efectos hover
	_setup_hover_effects()
	
	# Conectar señal de click para feedback visual
	if button:
		button.pressed.connect(_on_button_pressed)

func setup_item(data: Resource):
	item_data = data
	title_label.text = data.name
	var texture = FileUtils.load_texture_safe(data.cover_path)
	if texture:
		cover_texture.texture = texture

func _on_button_pressed():
	# Feedback visual al hacer click
	_click_feedback()

# === MÉTODOS PRIVADOS DE ANIMACIÓN ===
func _setup_hover_effects():
	# Configura múltiples efectos hover usando AnimationUtils genérico
	if button:
		# Efecto de escala
		AnimationUtils.add_hover_scale_effect_target(button, self, 1.05, 0.15)
		
		# Efecto de brillo
		AnimationUtils.add_hover_glow_effect(button, self, Color.WHITE, 5.0, 0.2)
		
		# Efecto de glow externo
		AnimationUtils.add_hover_outer_glow_effect(button, self, Color(1,1,1,0.35), 8.0, 0.25)

func _click_feedback():
	# Feedback visual al hacer click usando AnimationUtils genérico
	AnimationUtils.scale_pop(self, 1.1, 0.1)
