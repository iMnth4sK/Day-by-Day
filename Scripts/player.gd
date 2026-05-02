extends CharacterBody2D

@export var speed: float = 150.0
@export var jump_force: float = -350.0
@export var gravity: float = 1200.0
@export var jump_anim_speed: float = 2.0 

var z_axis: float = 0.0
var z_velocity: float = 0.0
var is_jumping: bool = false
var last_direction: String = "down"

@onready var anim = $AnimatedSprite2D
var sprite_base_y: float

func _ready():
	sprite_base_y = anim.position.y

func _physics_process(delta):
	# 1. Movimentação Física
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed
	move_and_slide()

	# 2. Atualizar Direção (Zona morta de 0.6 para estabilidade)
	if input_dir.length() > 0.6:
		last_direction = _get_direction_string(input_dir)
		_update_flip()

	# 3. Processar Animação
	_play_smart_animation(input_dir)

	# 4. Sistema de Pulo
	_handle_jump(delta)

# Função para converter o vetor em texto
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
	# Só espelhamos se a direção for para a direita (D)
	if "right" in last_direction: anim.flip_h = true
	else: anim.flip_h = false

func _play_smart_animation(input_dir: Vector2):
	var state = ""
	
	if is_jumping:
		# --- LÓGICA DE PULO (DINÂMICA) ---
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
		# --- LÓGICA DE CHÃO (WALK/IDLE) ---
		anim.speed_scale = 1.0
		state = "walk" if input_dir.length() > 0.1 else "idle"
		
		match last_direction:
			"up_left":    anim.play(state + "_a+w")
			"up_right":   anim.play(state + "_d+w")
			"down_left":  anim.play(state + "_a+s")
			"down_right": anim.play(state + "_d+s")
			"up":         anim.play(state + "_back" if state == "idle" else "walk_w")
			"down":       anim.play(state if state == "idle" else "walk_s")
			"left", "right": anim.play(state + "_left" if state == "idle" else "walk_a")

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
