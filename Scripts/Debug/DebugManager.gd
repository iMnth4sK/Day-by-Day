extends CanvasLayer

@onready var auto_save_btn = $PanelContainer/VBoxContainer/ToggleAutoSave
@onready var panel = $PanelContainer

func _ready():
	# Começa escondido
	visible = false 
	# Sincroniza o estado inicial
	_atualizar_ui()

func _input(event):
	# Atalho para abrir o menu
	if event.is_action_pressed("debug_key"):
		visible = !visible
		if visible:
			_atualizar_ui() # Garante que o botão mostre o estado real do GameManager

func _atualizar_ui():
	if GameManager:
		auto_save_btn.button_pressed = GameManager.auto_save_enabled

# --- BOTÕES DE TEMPO ---

func _on_btn_next_day_pressed():
	# Avança um dia. O 'false' evita que o jogo salve automaticamente no processo.
	if Engine.has_singleton("GameTime") or get_node_or_null("/root/GameTime"):
		GameTime.next_day(false)
		print("Debug: Dia pulado.")

func _on_btn_add_year_pressed():
	if Engine.has_singleton("GameTime") or get_node_or_null("/root/GameTime"):
		for i in range(365):
			GameTime.next_day(false)
		print("Debug: +1 Ano adicionado.")

# --- CONTROLE DE CONFIGURAÇÃO ---

# Use este sinal (toggled) para botões de alternância (CheckButton/CheckBox)
func _on_toggle_auto_save_toggled(toggled_on):
	GameManager.auto_save_enabled = toggled_on
	print("Debug: Auto-save definido para: ", toggled_on)

# Esta função era inútil/duplicada, pode apagar o sinal 'pressed' no editor
# e manter apenas o 'toggled' acima.
