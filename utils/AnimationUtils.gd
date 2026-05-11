class_name AnimationUtils
extends RefCounted

# === ANIMACIÓN UTILS ===
# Utilidad para manejar animaciones y efectos visuales en el launcher
# 
# Ejemplos de uso:
# 
# 1. Agregar efecto hover a un botón:
#    AnimationUtils.add_hover_scale_effect(my_button, 1.1, 0.2)
# 
# 2. Animación de entrada para un panel:
#    AnimationUtils.entrance_animation(my_panel, "scale_bounce", 0.5)
# 
# 3. Animar una lista de elementos:
#    AnimationUtils.animate_list_items(my_container, 0.1)
# 
# 4. Efectos de hover entre diferentes nodos:
#    AnimationUtils.add_hover_scale_effect_target(hover_node, target_node, 1.05, 0.15)
# 
# 5. Efectos de glow en hover:
#    AnimationUtils.add_hover_glow_effect(hover_node, target_node, Color.CYAN, 10.0, 0.2)
#    AnimationUtils.add_hover_outer_glow_effect(hover_node, target_node, Color.CYAN, 5.0, 0.2)

# === ANIMACIONES DE HOVER/FOCUS ===
## Agrega efecto de escala al hacer hover sobre un nodo
static func add_hover_scale_effect(node: Control, scale_factor: float = 1.1, duration: float = 0.2) -> void:
	if not node:
		return
		
	var original_scale = node.scale
	var target_scale = original_scale * scale_factor
	
	# Conectar señales de mouse usando lambdas
	node.mouse_entered.connect(func(): animate_scale(node, target_scale, duration))
	node.mouse_exited.connect(func(): animate_scale(node, original_scale, duration))

## Agrega efecto de escala a un nodo cuando se hace hover sobre otro nodo
static func add_hover_scale_effect_target(hover_node: Control, target_node: Control, scale_factor: float = 1.1, duration: float = 0.2) -> void:
	if not hover_node or not target_node:
		return
		
	var original_scale = target_node.scale
	var hover_scale = original_scale * scale_factor
	
	# Conectar señales de mouse del hover_node para animar el target_node
	hover_node.mouse_entered.connect(func(): animate_scale(target_node, hover_scale, duration))
	hover_node.mouse_exited.connect(func(): animate_scale(target_node, original_scale, duration))

## Agrega efecto de glow al hacer hover sobre un nodo
static func add_hover_glow_effect(hover_node: Control, target_node: Control, glow_color: Color = Color.WHITE, glow_size: float = 10.0, duration: float = 0.2) -> void:
	if not hover_node or not target_node:
		return
	
	# Conectar señales para el efecto glow
	hover_node.mouse_entered.connect(func(): _apply_glow(target_node, glow_color, glow_size, duration))
	hover_node.mouse_exited.connect(func(): _remove_glow(target_node, duration))

## Agrega efecto de glow externo usando shadow en StyleBox al hacer hover sobre un nodo
static func add_hover_outer_glow_effect(hover_node: Control, target_node: Control, glow_color: Color = Color.CYAN, glow_size: float = 5.0, duration: float = 0.2) -> void:
	if not hover_node or not target_node:
		return
	
	# Conectar señales para el efecto glow externo
	hover_node.mouse_entered.connect(func(): _apply_outer_glow(target_node, glow_color, glow_size, duration))
	hover_node.mouse_exited.connect(func(): _remove_outer_glow(target_node, duration))

## Aplica efecto glow usando modulate con el color especificado
static func _apply_glow(node: Control, glow_color: Color, glow_size: float, duration: float) -> void:
	var target_modulate = Color(
		glow_color.r * (1.0 + glow_size * 0.1),
		glow_color.g * (1.0 + glow_size * 0.1), 
		glow_color.b * (1.0 + glow_size * 0.1),
		1.0
	)
	animate_modulate(node, target_modulate, duration)

## Remueve efecto glow restaurando el modulate a blanco (sin tintado)
static func _remove_glow(node: Control, duration: float) -> void:
	animate_modulate(node, Color.WHITE, duration)

## Aplica glow externo usando shadow en StyleBox
static func _apply_outer_glow(node: Control, glow_color: Color, glow_size: float, _duration: float) -> void:
	if node is Panel:
		var current_style = node.get_theme_stylebox("panel")
		var new_style: StyleBoxFlat
		
		if current_style is StyleBoxFlat:
			new_style = current_style.duplicate()
		else:
			new_style = StyleBoxFlat.new()
			new_style.bg_color = Color.TRANSPARENT
		
		# Configurar el shadow como glow externo
		new_style.shadow_color = glow_color
		new_style.shadow_size = int(glow_size)
		new_style.shadow_offset = Vector2.ZERO  # Sin offset para que sea uniforme
		
		# Guardar el z_index original para restaurarlo después
		if not node.has_meta("original_z_index"):
			node.set_meta("original_z_index", node.z_index)
		
		# Elevar el z_index para que se renderice por encima de elementos hermanos
		node.z_index = 100
		
		# Animar la transición del glow si es necesario
		node.add_theme_stylebox_override("panel", new_style)

## Remueve glow externo restaurando el StyleBox original
static func _remove_outer_glow(node: Control, _duration: float) -> void:
	if node is Panel:
		node.remove_theme_stylebox_override("panel")
		
		# Restaurar el z_index original
		if node.has_meta("original_z_index"):
			node.z_index = node.get_meta("original_z_index")
			node.remove_meta("original_z_index")

# === ANIMACIONES DE ESCALA ===
## Anima la escala de un nodo a un valor objetivo con opciones de easing y transición
static func animate_scale(node: Control, target_scale: Vector2, duration: float = 0.3, ease_type: Tween.EaseType = Tween.EASE_OUT, trans_type: Tween.TransitionType = Tween.TRANS_BACK) -> Tween:
	if not node:
		return null
		
	var tween = node.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(node, "scale", target_scale, duration)
	return tween

## Anima el modulate (color/brillo) de un nodo
static func animate_modulate(node: Control, target_modulate: Color, duration: float = 0.3, ease_type: Tween.EaseType = Tween.EASE_OUT, trans_type: Tween.TransitionType = Tween.TRANS_SINE) -> Tween:
	if not node:
		return null
		
	var tween = node.create_tween()
	tween.set_ease(ease_type)
	tween.set_trans(trans_type)
	tween.tween_property(node, "modulate", target_modulate, duration)
	return tween

## Efecto de entrada con rebote más sutil
static func scale_bounce_in(node: Control, duration: float = 0.5) -> Tween:
	if not node:
		return null
		
	node.scale = Vector2(0.8, 0.8)  # Empezar desde 80% en lugar de 0%
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)  # Transición más suave
	tween.tween_property(node, "scale", Vector2.ONE, duration)
	return tween

## Efecto de 'pop' rápido
static func scale_pop(node: Control, scale_factor: float = 1.2, duration: float = 0.15) -> Tween:
	if not node:
		return null
		
	var original_scale = node.scale
	var tween = node.create_tween()
	
	# Primera fase: escalar hacia arriba
	tween.tween_property(node, "scale", original_scale * scale_factor, duration * 0.5)
	# Segunda fase: volver al tamaño original
	tween.tween_property(node, "scale", original_scale, duration * 0.5)
	
	return tween

# === ANIMACIONES DE OPACIDAD ===
static func fade_in(node: Control, duration: float = 0.3, delay: float = 0.0) -> Tween:
	if not node:
		return null
		
	node.modulate.a = 0.0
	var tween = node.create_tween()
	
	if delay > 0:
		tween.tween_delay(delay)
	
	tween.tween_property(node, "modulate:a", 1.0, duration)
	return tween

static func fade_out(node: Control, duration: float = 0.3) -> Tween:
	if not node:
		return null
		
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, duration)
	return tween

static func pulse_opacity(node: Control, min_alpha: float = 0.5, duration: float = 1.0, loops: int = -1) -> Tween:
	if not node:
		return null
		
	var tween = node.create_tween()
	tween.set_loops(loops)
	tween.tween_property(node, "modulate:a", min_alpha, duration * 0.5)
	tween.tween_property(node, "modulate:a", 1.0, duration * 0.5)
	return tween

# === ANIMACIONES DE POSICIÓN ===
## Desliza un nodo desde una dirección específica
static func slide_from_direction(node: Control, direction: Vector2, distance: float = 100.0, duration: float = 0.5) -> Tween:
	if not node:
		return null
		
	var original_position = node.position
	var start_position = original_position + (direction.normalized() * distance)
	
	node.position = start_position
	
	var tween = node.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", original_position, duration)
	return tween

## Efecto de temblor/shake
static func shake(node: Control, intensity: float = 10.0, duration: float = 0.5, frequency: float = 30.0) -> Tween:
	if not node:
		return null
		
	var original_position = node.position
	var tween = node.create_tween()
	
	var shake_count = int(duration * frequency)
	for i in range(shake_count):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(node, "position", original_position + offset, duration / shake_count)
	
	# Volver a la posición original
	tween.tween_property(node, "position", original_position, duration / shake_count)
	return tween

# === ANIMACIONES COMBINADAS ===
## Animación de entrada configurable
static func entrance_animation(node: Control, animation_type: String = "scale_bounce", duration: float = 0.5, delay: float = 0.0) -> Tween:
	if not node:
		return null
		
	if delay > 0.01:  # Solo aplicar delay si es significativo
		var delay_tween = node.create_tween()
		delay_tween.tween_interval(delay)
		await delay_tween.finished
	
	match animation_type:
		"scale_bounce":
			return scale_bounce_in(node, duration)
		"fade_in":
			return fade_in(node, duration)
		"slide_up":
			return slide_from_direction(node, Vector2.DOWN, 50.0, duration)
		"slide_down":
			return slide_from_direction(node, Vector2.UP, 50.0, duration)
		"slide_left":
			return slide_from_direction(node, Vector2.RIGHT, 50.0, duration)
		"slide_right":
			return slide_from_direction(node, Vector2.LEFT, 50.0, duration)
		_:
			return null

# === UTILIDADES GENERALES ===
## Detiene todos los tweens de un nodo
static func stop_all_tweens(node: Node) -> void:
	if not node:
		return
	
	var tween = node.create_tween()
	tween.kill()

## Anima todos los elementos de una lista con delay escalonado
static func animate_list_items(container: Container, animation_delay_step: float = 0.1) -> void:
	if not container:
		return
		
	for i in range(container.get_child_count()):
		var child = container.get_child(i)
		if child is Control:
			# Delay más rápido y sutil
			var delay = (i * animation_delay_step) + 0.02
			_animate_with_delay(child, "scale_bounce", 0.25, delay)

## Versión síncrona de entrance_animation para listas, usando un timer para manejar el delay entre animaciones
static func _animate_with_delay(node: Control, animation_type: String, duration: float, delay: float) -> void:
	if not node:
		return
	
	# Crear el timer de delay
	if delay > 0.01:
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		node.add_child(timer)
		timer.start()
		timer.timeout.connect(func(): 
			timer.queue_free()
			_execute_entrance_animation(node, animation_type, duration)
		)
	else:
		_execute_entrance_animation(node, animation_type, duration)

## Ejecuta la animación sin delay
static func _execute_entrance_animation(node: Control, animation_type: String, duration: float) -> void:
	match animation_type:
		"scale_bounce":
			scale_bounce_in(node, duration)
		"fade_in":
			fade_in(node, duration)
		"slide_up":
			slide_from_direction(node, Vector2.DOWN, 50.0, duration)
		"slide_down":
			slide_from_direction(node, Vector2.UP, 50.0, duration)
		"slide_left":
			slide_from_direction(node, Vector2.RIGHT, 50.0, duration)
		"slide_right":
			slide_from_direction(node, Vector2.LEFT, 50.0, duration)
		_:
			# Caso por defecto: usar scale_bounce
			scale_bounce_in(node, duration)
