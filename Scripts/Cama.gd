extends Area2D

# Carrega o arquivo da cena da interface na memória
const INTERFACE_CAMA_SCENE = preload("res://Scenes/UI/interface_cama.tscn") # Ajuste o caminho do seu arquivo!

var interface_instanciada: CanvasLayer = null
var janela_dormir: Panel = null
var player_perto := false

func _unhandled_input(event):
	if player_perto and event.is_action_pressed("interact"):
		# Se a interface ainda não existe na tela, nós criamos ela agora!
		if interface_instanciada == null:
			criar_e_abrir_interface()

func _on_body_entered(body):
	if body.name == "Player":
		player_perto = true

func _on_body_exited(body):
	if body.name == "Player":
		player_perto = false
		fechar_e_destruir_interface()

func criar_e_abrir_interface():
	# Instancia a cena da interface e adiciona ela na árvore do jogo
	interface_instanciada = INTERFACE_CAMA_SCENE.instantiate()
	get_tree().current_scene.add_child(interface_instanciada)
	
	# Pega as referências de dentro da cena que acabou de nascer
	janela_dormir = interface_instanciada.get_node("JanelaDormir")
	var botao_sim = interface_instanciada.get_node("JanelaDormir/BotaoSim")
	var botao_nao = interface_instanciada.get_node("JanelaDormir/BotaoNao")
	
	# Conecta os botões dinamicamente
	botao_sim.pressed.connect(_on_botao_sim_pressed)
	botao_nao.pressed.connect(_on_botao_nao_pressed)
	
	# Mostra a janela e foca no Sim
	janela_dormir.visible = true
	botao_sim.grab_focus()

func fechar_e_destruir_interface():
	if interface_instanciada != null:
		interface_instanciada.queue_free() # Deleta a interface da memória para não pesar
		interface_instanciada = null
		janela_dormir = null

func _on_botao_sim_pressed():
	print("Indo para a tela de resumo... ZzzZz")
	
	# Procura o Marker2D chamado "PontoDeitar" dentro da cama
	var marker = get_node_or_null("PontoDeitar") as Marker2D
	
	if marker:
		# Salva a posição exata do Marker2D!
		GameManager.database["posicao_player"] = marker.global_position
		print("Salvo no Marker2D:", marker.global_position)
	else:
		# Se você ainda não criou o Marker2D, salva onde o Player está
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			GameManager.database["posicao_player"] = player.global_position
		
	# 2. NOVIDADE: Salva o caminho do mapa onde essa cama está!
	GameManager.database["cena_atual"] = get_tree().current_scene.scene_file_path
	
	# 3. Fecha a interface e vai para o resumo
	fechar_e_destruir_interface()
	get_tree().change_scene_to_file("res://Scenes/UI/tela_resumo.tscn")

func _on_botao_nao_pressed():
	fechar_e_destruir_interface()
