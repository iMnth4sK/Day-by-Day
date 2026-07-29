extends Control

@onready var botao_avancar = $Panel/VBoxContainer/BotaoAvancar # Ajuste o caminho se necessário

func _ready():
	# Garante que o botão já vem selecionado para quem joga no teclado/controle
	botao_avancar.grab_focus()
	# Conecta o clique do botão
	botao_avancar.pressed.connect(_on_botao_avancar_pressed)

func _on_botao_avancar_pressed():
	print("Botão avançar clicado! Dormindo 8 horas e avançando no GameTime...")
	
	# Chama a função de sono do GameTime (adiciona 8h, calcula virada de dia/mês e salva)
	if GameTime.has_method("sleep"):
		GameTime.sleep(8)
	
	# Carrega dinamicamente o mapa onde o player dormiu
	var mapa_para_carregar = GameManager.database.get("cena_atual", "res://Scenes/Jogo principal/quarto_player.tscn")
	get_tree().change_scene_to_file(mapa_para_carregar)
