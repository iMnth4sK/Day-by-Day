extends Panel

signal close_requested

@onready var geral_page = $VBoxContainer/Content/GeralPage
@onready var sons_page = $VBoxContainer/Content/SonsPage
@onready var controles_page = $VBoxContainer/Content/ControlesPage
@onready var sistema_page = $VBoxContainer/Content/SistemaPage
@onready var music_slider = $VBoxContainer/Content/SonsPage/VBoxContainer/MusicSlider
@onready var geral_slider = $VBoxContainer/Content/SonsPage/VBoxContainer/GeralSlider
@onready var autosave_toggle = $VBoxContainer/Content/SistemaPage/AutoSaveToggle

func _ready() -> void:
	autosave_toggle.button_pressed = GameManager.auto_save_enabled
# Adicione esta verificação (if not ... is_connected):
	if not autosave_toggle.toggled.is_connected(_on_auto_save_toggled):
		autosave_toggle.toggled.connect(_on_auto_save_toggled)	
	_mostrar_pagina(geral_page)
	# Carrega volume salvo
	geral_slider.value = GameManager.settings.get("master_volume", 0.05)
	music_slider.value = GameManager.settings["music_volume"]
	_atualizar_bus_volume("Master", geral_slider.value)
	
	if not geral_slider.value_changed.is_connected(_on_geral_slider_value_changed):
		geral_slider.value_changed.connect(_on_geral_slider_value_changed)
	
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(
			bus_idx,
			linear_to_db(music_slider.value)
		)
	if not music_slider.value_changed.is_connected(_on_music_slider_value_changed):
		music_slider.value_changed.connect(_on_music_slider_value_changed)

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

func _on_geral_slider_value_changed(value: float):
	_atualizar_bus_volume("Musica", music_slider.value)
	
	var master_idx = AudioServer.get_bus_index("Master")
	if master_idx != -1:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(1.0)) 

	# 3. Salva no settings.dat
	GameManager.settings["master_volume"] = value
	GameManager.save_settings()
	
	# SALVA NO SETTINGS.DAT via GameManager
	GameManager.settings["master_volume"] = value
	GameManager.save_settings()

func _on_music_slider_value_changed(value: float):
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		# A MÁGICA: Pega o menor valor entre o slider da música e o slider geral
		var volume_final = min(value, geral_slider.value)
		
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_final))
		AudioServer.set_bus_mute(bus_idx, volume_final < 0.01)

	# SALVA CONFIG (Salva o valor real do slider, não o teto)
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
		
func _atualizar_bus_volume(bus_name: String, value: float):
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		var volume_final = min(value, geral_slider.value)
		
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_final))
		AudioServer.set_bus_mute(bus_idx, volume_final < 0.01)
