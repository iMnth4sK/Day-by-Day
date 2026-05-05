extends CharacterBody2D

var player_perto: bool = false

func _process(_delta):
	# Se o jogador estiver na área e apertar "E"
	# Certifique-se de que configurou "interact" no Input Map para a tecla E
	if player_perto and Input.is_action_just_pressed("interact"):
		falar_oi()

func falar_oi():
	print("NPC diz: Oi!")
	# Dica: se quiser que o nome do NPC apareça, use: 
	# print(name + " diz: Oi!")

# --- SINAIS (CONECTE-OS NA ABA 'NODE') ---

func _on_interaction_area_body_entered(body):
	# Verifique se o nó do seu player se chama exatamente "Player"
	if body.name == "Player": 
		player_perto = true
		print("Player entrou na InteractionArea")

func _on_interaction_area_body_exited(body):
	if body.name == "Player":
		player_perto = false
		print("Player saiu da InteractionArea")
