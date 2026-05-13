extends Node

var settings = {
	"autosave": true,
	"music_volume": 1.0
}

# -- CONFIGURAÇÃO DE AUTOSAVE --
var autosave_timer : Timer

# --- CONFIGURAÇÕES DE OPÇÕES ---
var auto_save_enabled := true 

# --- CONTROLE DE SLOT ---
var current_slot := 1
var game_ready := false

# --- DATABASE ---
var database = {}

func _ready():
	reset_data()
	setup_autosave_timer()
	load_settings()
	
func setup_autosave_timer():
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 300.0
	autosave_timer.one_shot = false
	autosave_timer.autostart = false
	autosave_timer.connect("timeout", _on_autosave_timeout)
	add_child(autosave_timer)
	
func _on_autosave_timeout():
	if game_ready and auto_save_enabled:
		Interface.play_autosave()
		save_game()
		print("Auto-save periódico realizado!")
	else:
		print("Auto-save ignorado: O jogador não está em uma partida ativa.")

func get_save_path():
	return "user://save_%d.dat" % current_slot

func get_default_data():

	return {
		"save_version": 1,

		"player_name": "Novo Jogador",

		"itens_coletados": 0,

		"npc_conversa_concluida": false,

		"posicao_player": Vector2.ZERO,

		"time": {
			"day": 1,
			"year": 1,
			"age": 6,
			"life_stage": "child"
		}
	}

func reset_data():
	database = get_default_data()
	
func merge_save_data(defaults: Dictionary, loaded: Dictionary):

	for key in defaults.keys():

		if not loaded.has(key):
			loaded[key] = defaults[key]

		elif defaults[key] is Dictionary:
			merge_save_data(defaults[key], loaded[key])

	return loaded

# =========================
# SAVE
# =========================
func save_game():
	if not game_ready:
		return
	if not auto_save_enabled:
		print("DEBUG: Save automático ignorado (opção desativada).")
		return

	# 1️⃣ Pega dados do player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.save_player_data()

	# 2️⃣ Pega dados do tempo
	database["time"] = GameTime.get_save_data()

	# 3️⃣ Escreve no disco
	var file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	if file:
		file.store_var(database)
		file.close()
		print("SAVE OK - SLOT:", current_slot)

# =========================
# LOAD (A que estava faltando!)
# =========================
func load_game():
	var path = get_save_path()
	
	if not FileAccess.file_exists(path):
		print("Save não existe → criando novo")
		reset_data()
		save_game()
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		
		if data is Dictionary:
			database = merge_save_data(get_default_data(), data)
			print("SAVE SLOT", current_slot, "CARREGADO!")
		else:
			print("ERRO: Dados corrompidos")

# =========================
# DELETE
# =========================
func delete_save(slot: int):
	var path = "user://save_%d.dat" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save", slot, "apagado do disco")
		
# =========================
# SAVE MANUAL / FORÇADO
# =========================

# Esta função salva o jogo ignorando a trava de 'auto_save_enabled'
# Usada para os botões "Salvar Jogo" e "Salvar e Sair"
func force_save():
	# 1️⃣ Coleta dados do player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.save_player_data()

	# 2️⃣ Coleta dados do tempo
	if Engine.has_singleton("GameTime") or get_node_or_null("/root/GameTime"):
		database["time"] = GameTime.get_save_data()

	# 3️⃣ Escreve no disco
	var file = FileAccess.open(get_save_path(), FileAccess.WRITE)
	if file:
		file.store_var(database)
		file.close()
		print("SAVE MANUAL (FORÇADO) OK - SLOT:", current_slot)

func start_autosave():
	if autosave_timer.is_stopped():
		autosave_timer.start()

func stop_autosave():
	if not autosave_timer.is_stopped():
		autosave_timer.stop()

func save_settings():

	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)

	if file:
		file.store_var(settings)
		file.close()

		print("Configurações salvas!")
		
func load_settings():
	if not FileAccess.file_exists("user://settings.dat"):
		save_settings()
		return
		
	var file = FileAccess.open("user://settings.dat", FileAccess.READ)
	if file:
		settings = file.get_var()
		file.close()
		
		print("Configurações carregadas!")
		
	auto_save_enabled = settings["autosave"]
	
	var bus_idx = AudioServer.get_bus_index("Musica")

	if bus_idx != -1:
		AudioServer.set_bus_volume_db(
			bus_idx,
			linear_to_db(settings["music_volume"])
		)
		AudioServer.set_bus_mute(
			bus_idx,
			settings["music_volume"] < 0.01
		)
