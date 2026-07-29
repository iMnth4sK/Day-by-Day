extends Area2D

# Arraste o nó do seu PointLight2D para esta variável no Inspector!
@export var luz_associada: PointLight2D

var player_perto := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if player_perto and event.is_action_pressed("interact"):
		if luz_associada:
			luz_associada.enabled = !luz_associada.enabled
			print("Luz alternada!")

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_perto = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		player_perto = false
