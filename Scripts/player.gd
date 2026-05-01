extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -375.0
@export var gravity: float = 1200.0

var z_axis: float = 0.0          # Altura visual
var z_velocity: float = 0.0      # Força do pulo
var is_jumping: bool = false

@onready var visual_node = get_child(0) # Pega o primeiro filho (seu quadrado/forma)

func _physics_process(delta):
	# 1. Movimentação no chão (Independente do pulo)
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * speed

	# 2. Lógica do Pulo (Afeta apenas a variável z_axis)
	if Input.is_action_just_pressed("ui_accept") and not is_jumping:
		z_velocity = jump_force
		is_jumping = true

	if is_jumping:
		z_velocity += gravity * delta
		z_axis += z_velocity * delta
		
		# Aplica a altura APENAS na posição visual do nó filho
		if visual_node:
			visual_node.position.y = z_axis
		
		# Quando toca o chão
		if z_axis >= 0:
			z_axis = 0
			z_velocity = 0
			is_jumping = false
			if visual_node:
				visual_node.position.y = 0

	move_and_slide()
