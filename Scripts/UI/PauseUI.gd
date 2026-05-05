extends CanvasLayer

@onready var pause_menu = $PauseMenu

func _ready():
	# Começa o jogo com o menu escondido
	pause_menu.hide()

func _input(event):
	# Verifica se apertou ESC
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	# Inverte o estado de pausa do jogo
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	
	# Mostra ou esconde o menu
	if new_pause_state:
		pause_menu.show()
	else:
		pause_menu.hide()

# --- CONEXÃO DOS BOTÕES ---

func _on_continuar_pressed():
	toggle_pause() # Despausa e fecha o menu

func _on_sair_pressed():
	get_tree().quit() # Fecha o jogo
