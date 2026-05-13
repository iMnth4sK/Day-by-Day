extends CanvasLayer

@onready var main_menu = $PauseMenu/CenterContainer/MainMenu
@onready var confirm_save_menu = $PauseMenu/CenterContainer/ConfirmSaveMenu
@onready var save_feedback = $PauseMenu/SaveFeedback
@onready var transition = $Transition
@onready var menu_opcoes = $PauseMenu/CenterContainer/Opções
var destino_saida = "" 
var busy := false

func _ready():
	GameState.current_state = GameState.State.PLAYING
	menu_opcoes.visible = false
	menu_opcoes.modulate.a = 0
	visible = false
	save_feedback.visible = false
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
	GameManager.force_save() # Salva o jogo
	await _mostrar_feedback_salvo() # Mostra o "Sucesso!"
	_finalizar_saida()

func _on_sair_sem_salvar_pressed():
	_finalizar_saida()

func _on_cancelar_pressed():
	_show_main_menu()

# --- FUNÇÕES DE LOGICA ---

func _executar_salvamento_visual():
	if busy:
		return
	busy = true
	GameManager.save_game()
	await _mostrar_feedback_salvo()
	busy = false

func _mostrar_feedback_salvo():
	save_feedback.modulate.a = 0
	save_feedback.visible = true
	var tween = create_tween()
	tween.tween_property(save_feedback, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.0)
	tween.tween_property(save_feedback, "modulate:a", 0.0, 0.3)
	await tween.finished
	save_feedback.visible = false

func _finalizar_saida():
	GameManager.game_ready = false
	GameManager.stop_autosave()
	get_tree().paused = false
	await transition.fade_out()
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
