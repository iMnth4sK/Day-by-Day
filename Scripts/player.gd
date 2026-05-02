extends CharacterBody2D

# Configurações básicas
@export var speed: float = 150.0
@export var jump_force: float = -350.0
@export var gravity: float = 1200.0

# Variáveis do pulo
var z_axis: float = 0.0
var z_velocity: float = 0.0
var is_jumping: bool = false

# Referência ao Sprite
@onready var anim = $AnimatedSprite2D
var sprite_base_y: float

func _ready():
	# Guarda a posição Y para o pulo não bugar
	sprite_base_y = anim.position.y

func _physics_process(delta):
	# Pega o movimento das teclas
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed

	# =========================
	# LÓGICA DE DIREÇÃO (FLIP)
	# =========================
	if input_dir.x < 0:
		# Se mover para a ESQUERDA, liga o Flip (espelha)
		anim.flip_h = true
	elif input_dir.x > 0:
		# Se mover para a DIREITA, desliga o Flip (volta ao normal)
		anim.flip_h = false

	# =========================
	# ANIMAÇÕES
	# =========================
	if input_dir != Vector2.ZERO:
		if input_dir.y < 0:
			anim.play("walk_w") # Cima
		elif input_dir.y > 0:
			anim.play("walk_s") # Baixo
		else:
			anim.play("walk_a") # Lados (usa o flip_h para o lado 'a')
	else:
		anim.play("idle")

	# =========================
	# SISTEMA DE PULO
	# =========================
	if Input.is_action_just_pressed("ui_accept") and not is_jumping:
		is_jumping = true
		z_velocity = jump_force

	if is_jumping:
		z_axis += z_velocity * delta
		z_velocity += gravity * delta
		anim.position.y = sprite_base_y + z_axis

		if z_axis >= 0:
			z_axis = 0
			z_velocity = 0
			is_jumping = false
			anim.position.y = sprite_base_y

	move_and_slide()
