extends CharacterBody2D

var can_interact = false

# Referências
@onready var chat_label = $ChatAnchor/PanelContainer/MarginContainer/Label # Ajuste o caminho se necessário
@onready var dialogue_ui = get_parent().get_node_or_null("DialogueUI")

func _on_interaction_area_body_entered(body):
	if body.name == "Player": 
		can_interact = true
		show_floating_message("Aperte E para falar")

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		can_interact = false
		chat_label.hide()

func _input(event):
	if can_interact and event.is_action_pressed("interact"):
		interact_with_npc()

func interact_with_npc():
	# Agora ele fala em cima da cabeça em vez de só dar print
	show_floating_message("Olá! Eu sou um NPC de testes.")
	
	if dialogue_ui:
		dialogue_ui.show()

# Função mágica para a mensagem flutuante
func show_floating_message(text: String):
	chat_label.text = text
	chat_label.show()
	
	# Cria um timer via código para esconder a mensagem após 3 segundos
	await get_tree().create_timer(3.0).timeout
	
	# Só esconde se o texto ainda for o mesmo (evita bugar se você falar rápido)
	if chat_label.text == text:
		chat_label.hide()
