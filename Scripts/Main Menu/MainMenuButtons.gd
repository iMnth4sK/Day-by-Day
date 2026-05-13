extends Control

# --- REFERÊNCIAS ---
@onready var transition = $Transition
@onready var menu_inicial = $VBoxContainer
@onready var menu_opcoes = $Opções # Seu painel estilo Omori

func _ready() -> void:
	menu_opcoes.visible = false
	menu_opcoes.modulate.a = 0
	transition.fade_in()
	
	# ISSO AQUI VAI SALVAR O SEU BOTÃO X:
	# Conecta o sinal que criamos no OptionsUI.gd à função de voltar daqui
	if menu_opcoes.has_signal("close_requested"):
		menu_opcoes.close_requested.connect(_on_voltar_pressed)
	# 1. Configuração inicial dos menus
	menu_opcoes.visible = false
	menu_opcoes.modulate.a = 0
	
	# 2. Efeito de entrada na cena
	transition.fade_in()

# --- BOTÕES PRINCIPAIS ---

func _on_iniciar_pressed() -> void:
	await transition.fade_out()
	# Vai para a tela de slots (SaveSelect)
	get_tree().change_scene_to_file("res://Scenes/Main Menu/SaveSelect.tscn")

func _on_opções_pressed() -> void:
	_transicao_suave(menu_inicial, menu_opcoes)

func _on_sair_pressed() -> void:
	await transition.fade_out()
	get_tree().quit()

# --- BOTÕES DO MENU DE OPÇÕES ---

func _on_voltar_pressed() -> void:
	# Este sinal deve vir do botão "VOLTAR" que você criar dentro do Panel
	_transicao_suave(menu_opcoes, menu_inicial)

# --- SISTEMA DE TRANSIÇÃO (ESTILO FADE) ---

func _transicao_suave(sai, entra) -> void:
	# Cria um efeito de fade out para quem sai
	var tween_sai = create_tween()
	tween_sai.tween_property(sai, "modulate:a", 0.0, 0.2)
	
	await tween_sai.finished
	sai.visible = false
	
	# Prepara quem entra (invisível primeiro)
	entra.modulate.a = 0
	entra.visible = true
	
	# Cria um efeito de fade in para quem entra
	var tween_entra = create_tween()
	tween_entra.tween_property(entra, "modulate:a", 1.0, 0.2)
