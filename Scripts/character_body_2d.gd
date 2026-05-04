extends CharacterBody2D

# Variável para rastrear se o jogador está na área de interação
var can_interact = false

# Referência para o nó de UI do diálogo (vamos assumir que é um nó irmão)
@onready var dialogue_ui = get_parent().get_node_or_null("DialogueUI")

# Função que roda quando algo entra na área de interação
func _on_interaction_area_body_entered(body):
	# Verifique se o objeto que entrou é o jogador (body.name == "Player")
	# Para testes, você pode usar: if body.is_in_group("player"): (precisa adicionar o player no grupo)
	if body.name == "Player": 
		print("O jogador está perto e pode interagir!")
		can_interact = true
		# [OPCIONAL] Mostrar um ícone visual para o jogador (ex: um balão com 'E')

# Função que roda quando algo sai da área de interação
func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		print("O jogador saiu da área.")
		can_interact = false
		# [OPCIONAL] Esconder o ícone visual
		if dialogue_ui and dialogue_ui.visible:
			dialogue_ui.hide() # Esconde o diálogo se o jogador se afastar

# Função para lidar com a entrada do usuário
func _input(event):
	# Verifique se o jogador pode interagir E se apertou a tecla 'E'
	if can_interact and event.is_action_pressed("interact"):
		print("Interação iniciada!")
		interact_with_npc()

# Função principal de interação
func interact_with_npc():
	if dialogue_ui:
		if dialogue_ui.visible:
			# Se já estiver visível, pode avançar o diálogo ou fechar
			# dialogue_ui.advance_dialogue()
			print("Avançando diálogo...")
		else:
			# Se não, exibe a UI e começa o diálogo
			dialogue_ui.show()
			# dialogue_ui.start_dialogue_with("Este é o meu diálogo padrão!")
			print("Iniciando diálogo...")
	else:
		# Se não encontrar a UI, dá uma mensagem de erro ou usa print para testar
		print("Olá! Eu sou um NPC para testes.")
