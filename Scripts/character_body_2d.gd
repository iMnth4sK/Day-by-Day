extends CharacterBody2D

# Variável para rastrear se o jogador está na área de interação
var can_interact = false

# Referência para o nó de UI do diálogo
@onready var dialogue_ui = get_parent().get_node_or_null("DialogueUI")
# Referência para a HUD (ajuste o caminho conforme sua árvore de nós)
@onready var hud = get_node_or_null("../HUD")

# Função que roda quando algo entra na área de interação
func _on_interaction_area_body_entered(body):
	if body.name == "Player": 
		print("O jogador está perto e pode interagir!")
		can_interact = true

# Função que roda quando algo sai da área de interação
func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		print("O jogador saiu da área.")
		can_interact = false
		if dialogue_ui and dialogue_ui.visible:
			dialogue_ui.hide()

# Função para lidar com a entrada do usuário
func _input(event):
	if can_interact and event.is_action_pressed("interact"):
		print("Interação iniciada!")
		interact_with_npc()

# Função principal de interação
func interact_with_npc():
	if dialogue_ui:
		dialogue_ui.show()
		print("Iniciando diálogo via DialogueUI...")
	elif hud:
		hud.show()
		print("Iniciando diálogo via HUD...")
	else:
		print("Olá! Eu sou um NPC para testes (nenhuma UI encontrada).")
