extends Panel

signal close_requested

@onready var geral_page = $VBoxContainer/Content/GeralPage
@onready var sons_page = $VBoxContainer/Content/SonsPage
@onready var controles_page = $VBoxContainer/Content/ControlesPage
@onready var sistema_page = $VBoxContainer/Content/SistemaPage
@onready var musica_slider = $VBoxContainer/Content/SonsPage/MusicSlider
@onready var autosave_toggle = $VBoxContainer/Content/SistemaPage/AutoSaveToggle

func _ready() -> void:
	autosave_toggle.button_pressed = GameManager.auto_save_enabled
# Adicione esta verificação (if not ... is_connected):
	if not autosave_toggle.toggled.is_connected(_on_auto_save_toggled):
		autosave_toggle.toggled.connect(_on_auto_save_toggled)	
	_mostrar_pagina(geral_page)
	# Carrega volume salvo
	
	musica_slider.value = GameManager.settings["music_volume"]
	# Aplica volume no AudioServer
	
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(
			bus_idx,
			linear_to_db(musica_slider.value)
		)
	if not musica_slider.value_changed.is_connected(_on_musica_slider_value_changed):
		musica_slider.value_changed.connect(_on_musica_slider_value_changed)

# --- LÓGICA DE NAVEGAÇÃO ---

func _mostrar_pagina(pagina_alvo: Control):
	geral_page.visible = false
	sons_page.visible = false
	controles_page.visible = false
	sistema_page.visible = false
	pagina_alvo.visible = true
	pagina_alvo.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(pagina_alvo, "modulate:a", 1.0, 0.2)

# --- SINAIS DOS BOTÕES ---

func _on_geral_pressed():
	_mostrar_pagina(geral_page)

func _on_sons_pressed():
	_mostrar_pagina(sons_page)

func _on_controles_pressed():
	_mostrar_pagina(controles_page)

func _on_sistema_pressed():
	_mostrar_pagina(sistema_page)

# --- ÁUDIO E FECHAR ---

func _on_musica_slider_value_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(
			bus_idx,
			linear_to_db(value)
		)
		AudioServer.set_bus_mute(bus_idx, value < 0.01)
	# SALVA CONFIG
	GameManager.settings["music_volume"] = value
	GameManager.save_settings()

func _on_fechar_pressed() -> void:
	close_requested.emit()

func _on_auto_save_toggled(enabled: bool):
	GameManager.settings["autosave"] = enabled
	GameManager.auto_save_enabled = enabled
	GameManager.save_settings()
	if enabled:
		GameManager.start_autosave()
		print("Autosave ativado")
	else:
		GameManager.stop_autosave()
		print("Autosave desativado")
