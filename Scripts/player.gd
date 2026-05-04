extends CharacterBody2D

# --- VARIÁVEIS DE CONFIGURAÇÃO ---
@export var speed: float = 150.0
@export var run_speed: float = 230.0
@export var jump_force: float = -350.0
@export var gravity: float = 1200.0
@export var jump_anim_speed: float = 2.0

# --- SISTEMA DE ESTAMINA (FÔLEGO) ---
@export var max_stamina: float = 100.0
@export var stamina_consumption: float = 30.0 
@export var stamina_recovery: float = 20.0    
var current_stamina: float = 100.0
var can_run: bool = true

# --- VARIÁVEIS DE CONTROLE ---
var z_axis: float = 0.0
var z_velocity: float = 0.0
var is_jumping: bool = false
var last_direction: String = "down"

@onready var anim = $AnimatedSprite2D
@onready var stamina_bar = $StaminaBar 
var sprite_base_y: float

func _ready():
	sprite_base_y = anim.position.y
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina
	stamina_bar.hide()

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_key_pressed(KEY_SHIFT) and input_dir != Vector2.ZERO and can_run
	
	if is_running:
		current_stamina -= stamina_consumption * delta
		if current_stamina <= 0:
			current_stamina = 0
			can_run = false 
	else:
		current_stamina += stamina_recovery * delta
		if current_stamina >= 20:
			can_run = true
			
	current_stamina = clamp(current_stamina, 0, max_stamina)
	_update_stamina_ui()

	var current_speed = run_speed if is_running else speed
	velocity = input_dir * current_speed
	move_and_slide()

	if input_dir.length() > 0.1:
		last_direction = _get_direction_string(input_dir)
		_update_flip()

	_play_smart_animation(input_dir, is_running)
	_handle_jump(delta)

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
	# Flip H ativa apenas quando a direção aponta para a ESQUERDA
	anim.flip_h = "left" in last_direction

func _play_smart_animation(input_dir: Vector2, is_running: bool):
	var state = "idle"
	if input_dir.length() > 0.1:
		state = "run" if is_running else "walk"
		anim.speed_scale = 1.7 if is_running else 1.0
	else:
		anim.speed_scale = 1.0

	if is_jumping:
		anim.speed_scale = 1.0
		match last_direction:
			"up_left":    anim.play("jump_a+w", jump_anim_speed)
			"up_right":   anim.play("jump_d+w", jump_anim_speed)
			"down_left":  anim.play("jump_a+s", jump_anim_speed)
			"down_right": anim.play("jump_d+s", jump_anim_speed)
			"up":         anim.play("jump_back", jump_anim_speed)
			"down":       anim.play("jump_idle", jump_anim_speed)
			"left":       anim.play("jump_a", jump_anim_speed)
			"right":      anim.play("jump_d", jump_anim_speed)
	else:
		match last_direction:
			"up_left":    anim.play(state + "_a+w")
			"up_right":   anim.play(state + "_d+w")
			"down_left":  anim.play(state + "_a+s")
			"down_right": anim.play(state + "_d+s")
			"up":
				if state == "idle": anim.play("idle_back")
				else: anim.play(state + "_w")
			"down":
				if state == "idle": anim.play("idle")
				else: anim.play(state + "_s")
			"left":
				if state == "idle": anim.play("idle_left")
				else: anim.play(state + "_a")
			"right":
				if state == "idle": anim.play("idle_right")
				else: anim.play(state + "_d")

# --- RESTANTE DAS FUNÇÕES (STAMINA E PULO) ---

func _update_stamina_ui():
	stamina_bar.value = current_stamina
	if current_stamina < max_stamina: stamina_bar.show()
	else: stamina_bar.hide()
	stamina_bar.modulate = Color.RED if not can_run else Color.WHITE

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
