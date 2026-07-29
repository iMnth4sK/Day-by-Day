extends Control

@onready var main_menu = $CenterContainer/MainMenu
@onready var confirm_save_menu = $CenterContainer/ConfirmSaveMenu
# @onready var transition = $Transition
@onready var menu_opcoes = $"CenterContainer/Opções"
var destino_saida = "" 
var busy := false

func _ready():
	GameState.current_state = GameState.State.PLAYING
	menu_opcoes.visible = false
	menu_opcoes.modulate.a = 0
	visible = false
	_show_main_menu()
	menu_opcoes.close_requested.connect(_on_voltar_das_opcoes)
	
func _unhandled_input(event):

	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	if get_tree().paused:
		GameState.current_state = GameState.State.PAUSED
		main_menu.visible = true
		main_menu.modulate.a = 1.0
		menu_opcoes.visible = false
		menu_opcoes.modulate.a = 0
		_show_main_menu()

	else:

		GameState.current_state = GameState.State.PLAYING

func _show_main_menu():
	main_menu.visible = true
	confirm_save_menu.visible = false

func _show_confirm_save():
	main_menu.visible = false
	confirm_save_menu.visible = true

# --- BOTÕES DO MENU PRINCIPAL ---
func _on_opções_pressed():
	_transicao_interna(main_menu, menu_opcoes)

func _on_continuar_pressed():
	toggle_pause()

func _on_salvar_jogo_pressed():
	_executar_salvamento_visual()

func _on_menu_principal_pressed():
	destino_saida = "menu"
	_show_confirm_save()

func _on_sair_pressed():
	destino_saida = "desktop"
	_show_confirm_save()

# --- BOTÕES DA JANELA DE CONFIRMAÇÃO (ConfirmSaveMenu) ---

func _on_salvar_e_sair_pressed():
	Interface.play_autosave() 
	# await transition.fade_in()
	GameManager.force_save() # Salva o jogo
	
	await get_tree().create_timer(0.5).timeout
	
	_finalizar_saida()

func _on_sair_sem_salvar_pressed():
	# await transition.fade_out()
	_finalizar_saida()

func _on_cancelar_pressed():
	_show_main_menu()

# --- FUNÇÕES DE LOGICA ---

func _executar_salvamento_visual():
	if busy: return
	busy = true
	
	# Passamos 'true' para o novo parâmetro ignore_pause
	Interface.play_autosave(0, true) 
	
	GameManager.save_game()
	await get_tree().create_timer(1.5, true, false, true).timeout 
	busy = false

func _finalizar_saida():
	GameManager.game_ready = false
	GameManager.stop_autosave()
	get_tree().paused = false
	# await transition.fade_out()
	if destino_saida == "menu":
		get_tree().change_scene_to_file("res://Scenes/Main Menu/MainMenu.tscn")
	else:
		get_tree().quit()
		
		# --- FUNÇÃO DE TRANSIÇÃO INTERNA ---
func _transicao_interna(sai, entra):
	sai.set_process_input(false)
	var tween = create_tween()
	tween.tween_property(sai, "modulate:a", 0.0, 0.2)
	await tween.finished
	sai.visible = false
	
	entra.visible = true
	entra.modulate.a = 0
	var tween_in = create_tween()
	tween_in.tween_property(entra, "modulate:a", 1.0, 0.2)
	
	entra.set_process_input(true)
	
func _on_voltar_das_opcoes():
	_transicao_interna(menu_opcoes, main_menu)
