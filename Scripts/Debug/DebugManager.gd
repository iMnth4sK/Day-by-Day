extends CanvasLayer

@onready var auto_save_btn = $PanelContainer/VBoxContainer/ToggleAutoSave
@onready var panel = $PanelContainer

func _ready():
	#esc Começa ondido, só aparece quando você chamar
	visible = false 
	# Sincroniza o botão com o estado atual do GameManager
	if GameManager:
		auto_save_btn.button_pressed = GameManager.auto_save_enabled

func _input(event):
	# Use a tecla "Aspas" ou "F1" (configure no Input Map como 'debug_key')
	if event.is_action_pressed("debug_key"):
		visible = !visible

func _on_btn_next_day_pressed():
	# Passamos 'false' para o dia passar sem travar o jogo salvando toda hora
	GameTime.next_day(false)
	print("Debug: Dia pulado.")

func _on_btn_add_year_pressed():
	# Loop para simular o passar de um ano rapidamente
	for i in range(365):
		GameTime.next_day(false)
	print("Debug: +1 Ano adicionado.")

func _on_toggle_auto_save_toggled(toggled_on):
	GameManager.auto_save_enabled = toggled_on
	print("Auto-save definido para: ", toggled_on)

func _on_toggle_auto_save_pressed() -> void:
	pass # Replace with function body.
