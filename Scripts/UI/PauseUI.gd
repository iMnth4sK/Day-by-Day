extends CanvasLayer

@onready var main_menu = $PauseMenu/CenterContainer/MainMenu
@onready var transition = $Transition
@onready var exit_menu = $PauseMenu/CenterContainer/ExitMenu

func _ready():
	print(GameManager.database["player_name"])
	# Garante que o menu comece escondido e no estado certo
	transition.fade_in()
	visible = false
	_show_main_menu()

func _input(event):
	if event.is_action_pressed("ui_cancel"): # Geralmente a tecla ESC
		toggle_pause()

func toggle_pause():
	# Inverte o estado de pausa do jogo
	get_tree().paused = !get_tree().paused
	
	# O CanvasLayer (self) fica visível
	visible = get_tree().paused 
	
	# Garante que o nó que segura os menus também apareça
	$PauseMenu.visible = visible 
	
	if visible:
		_show_main_menu()

func _show_main_menu():
	main_menu.visible = true
	exit_menu.visible = false

func _show_exit_menu():
	main_menu.visible = false
	exit_menu.visible = true

# --- Sinais dos Botões ---

func _on_continuar_pressed():
	toggle_pause()

func _on_sair_pressed():
	_show_exit_menu()

func _on_voltar_pressed():
	_show_main_menu()

func _on_sair_do_jogo_pressed():
	await transition.fade_out()
	get_tree().quit()

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false # IMPORTANTE: Despausa antes de mudar de cena
	await transition.fade_out()
	get_tree().change_scene_to_file("res://scenes/Main Menu/MainMenu.tscn")
