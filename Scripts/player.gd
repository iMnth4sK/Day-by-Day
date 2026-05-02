extends CharacterBody2D

# --- VARIÁVEIS DE CONFIGURAÇÃO ---
@export var speed: float = 150.0
@export var run_speed: float = 230.0 
@export var jump_force: float = -350.0
@export var gravity: float = 1200.0
@export var jump_anim_speed: float = 2.0 

# --- SISTEMA DE ESTAMINA (FÔLEGO) ---
@export var max_stamina: float = 100.0
@export var stamina_consumption: float = 30.0 # Gasta em ~3.3 segundos
@export var stamina_recovery: float = 20.0    # Recupera em 5 segundos
var current_stamina: float = 100.0
var can_run: bool = true

# --- VARIÁVEIS DE CONTROLE ---
var z_axis: float = 0.0
var z_velocity: float = 0.0
var is_jumping: bool = false
var last_direction: String = "down"

@onready var anim = $AnimatedSprite2D
@onready var stamina_bar = $StaminaBar # Certifique-se de que o nome no nó seja igual a este
var sprite_base_y: float

func _ready():
	sprite_base_y = anim.position.y
	# Configuração inicial da barra
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	stamina_bar.hide()

func _physics_process(delta):
	# 1. PROCESSAR INPUT E ESTAMINA
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Verifica se quer correr, se tem fôlego e se está se movendo
	var is_running = Input.is_key_pressed(KEY_SHIFT) and input_dir != Vector2.ZERO and can_run
	
	if is_running:
		current_stamina -= stamina_consumption * delta
		if current_stamina <= 0:
			current_stamina = 0
			can_run = false # Exausto
	else:
		current_stamina += stamina_recovery * delta
		# Só permite correr novamente quando recuperar pelo menos 20%
		if current_stamina >= 20:
			can_run = true
			
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	# Atualiza a interface da barra
	_update_stamina_ui()

	# 2. MOVIMENTAÇÃO FÍSICA
	var current_speed = run_speed if is_running else speed
	velocity = input_dir * current_speed
	move_and_slide()

	# 3. ATUALIZAR DIREÇÃO
	if input_dir.length() > 0.9:
		last_direction = _get_direction_string(input_dir)
		_update_flip()

	# 4. PROCESSAR ANIMAÇÃO
	_play_smart_animation(input_dir, is_running)

	# 5. SISTEMA DE PULO
	_handle_jump(delta)

# --- FUNÇÕES DE INTERFACE ---

func _update_stamina_ui():
	stamina_bar.value = current_stamina
	
	# Mostra a barra apenas se a estamina não estiver cheia
	if current_stamina < max_stamina:
		stamina_bar.show()
	else:
		stamina_bar.hide()
	
	# Feedback visual: barra vermelha quando o jogador está exausto e não pode correr
	if not can_run:
		stamina_bar.modulate = Color.RED
	else:
		stamina_bar.modulate = Color.WHITE

# --- FUNÇÕES AUXILIARES ---

func _get_direction_string(dir: Vector2) -> String:
	if dir.x < -0.3 and dir.y < -0.3: return "up_left"
	if dir.x > 0.3 and dir.y < -0.3:  return "up_right"
	if dir.x < -0.3 and dir.y > 0.3:  return "down_left"
	if dir.x > 0.3 and dir.y > 0.3:   return "down_right"
	if dir.x < -0.3: return "left"
	if dir.x > 0.3:  return "right"
	if dir.y < -0.3: return "up"
	if dir.y > 0.3:  return "down"
	return last_direction

func _update_flip():
	anim.flip_h = "right" in last_direction

func _play_smart_animation(input_dir: Vector2, is_running: bool):
	if is_jumping:
		anim.speed_scale = 1.0
		match last_direction:
			"up_left":    anim.play("jump_a+w", jump_anim_speed)
			"up_right":   anim.play("jump_d+w", jump_anim_speed)
			"down_left":  anim.play("jump_a+s", jump_anim_speed)
			"down_right": anim.play("jump_d+s", jump_anim_speed)
			"up":         anim.play("jump_back", jump_anim_speed)
			"left":       anim.play("jump_a", jump_anim_speed)
			"right":      anim.play("jump_d", jump_anim_speed)
			"down":       anim.play("jump_idle", jump_anim_speed)
	else:
		var state = "idle"
		if input_dir.length() > 0.1:
			if is_running:
				state = "run"
				anim.speed_scale = 1.7
			else:
				state = "walk"
				anim.speed_scale = 1.0
		else:
			state = "idle"
			anim.speed_scale = 1.0

		match last_direction:
			"up_left":    anim.play(state + "_a+w")
			"up_right":   anim.play(state + "_d+w")
			"down_left":  anim.play(state + "_a+s")
			"down_right": anim.play(state + "_d+s")
			"up":
				if state == "idle": anim.play("idle_back")
				elif state == "run": anim.play("run_w")
				else: anim.play("walk_w")
			"down":
				if state == "idle": anim.play("idle")
				elif state == "run": anim.play("run_s")
				else: anim.play("walk_s")
			"left", "right":
				if state == "idle": 
					anim.play("idle_left" if "left" in last_direction else "idle_right")
				elif state == "run": 
					anim.play("run_a" if "left" in last_direction else "run_d")
				else: 
					anim.play("walk_a")

func _handle_jump(delta):
	if Input.is_action_just_pressed("ui_accept") and not is_jumping:
		is_jumping = true
		z_velocity = jump_force

	if is_jumping:
		z_velocity += gravity * delta
		z_axis += z_velocity * delta
		anim.position.y = sprite_base_y + z_axis
		
		if z_axis >= 0:
			z_axis = 0
			z_velocity = 0
			is_jumping = false
			anim.position.y = sprite_base_y
