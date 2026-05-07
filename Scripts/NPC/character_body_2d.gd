extends CharacterBody2D

var can_interact = false

# Referências aos nós (Caminhos baseados na sua estrutura)
@onready var chat_label = $ChatAnchor/PanelContainer/MarginContainer/Label
@onready var dialogue_ui = get_parent().get_node_or_null("DialogueUI")
@onready var hud = get_parent().get_node_or_null("HUD")

# Quando o jogador entra na área
func _on_interaction_area_body_entered(body):
	if body.name == "Player":
		can_interact = true
		show_floating_message("Aperte E para falar")

# Quando o jogador sai da área
func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		can_interact = false
		chat_label.hide()
		# Esconde as UIs se o jogador se afastar
		if dialogue_ui: dialogue_ui.hide()
		if hud: hud.hide()

# Detecta a tecla de interação
func _input(event):
	if can_interact and event.is_action_pressed("interact"):
		interact_with_npc()

# Lógica principal da interação
func interact_with_npc():
	# 1. Mostra balão flutuante
	show_floating_message("Olá! Eu sou um NPC de testes.")
	
	# 2. Atualiza a Base de Dados Global
	GameManager.database["npc_conversa_concluida"] = true
	
	# 3. Salva o arquivo de save imediatamente
	GameManager.save_game()
	
	# 4. Exibe a UI de diálogo ou HUD de teste
	if dialogue_ui:
		dialogue_ui.show()
	elif hud:
		hud.show()

# Função para a mensagem flutuante com timer
func show_floating_message(text: String):
	chat_label.text = text
	chat_label.show()
	
	# Aguarda 3 segundos antes de esconder
	await get_tree().create_timer(3.0).timeout
	
	# Verifica se o texto ainda é o mesmo para não esconder a mensagem nova
	if chat_label.text == text:
		chat_label.hide()
