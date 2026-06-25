extends Control

@onready var botao_avancar = $Panel/VBoxContainer/BotaoAvancar # Ajuste o caminho se tiver colocado dentro de algum container

func _ready():
	# Garante que o botão já vem selecionado para quem joga no teclado
	botao_avancar.grab_focus()
	# Conecta o clique do botão
	botao_avancar.pressed.connect(_on_botao_avancar_pressed)

func _on_botao_avancar_pressed():
	print("Botão avançar clicado! Mudando o dia no GameTime...")
	
	if GameTime.has_method("next_day"):
		GameTime.next_day(true)
		if GameTime.has_method("update_life_stage"):
			GameTime.update_life_stage()
	
	# O SEGREDO ESTÁ AQUI: Carrega dinamicamente o mapa onde o player dormiu!
	var mapa_para_carregar = GameManager.database.get("cena_atual", "res://Scenes/Jogo principal/quarto_player.tscn")
	get_tree().change_scene_to_file(mapa_para_carregar)
