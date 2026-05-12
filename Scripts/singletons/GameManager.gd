extends Node

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
	
func setup_autosave_timer():
	autosave_timer = Timer.new()
	autosave_timer.wait_time = 300.0 # 300 segundos = 5 minutos
	autosave_timer.one_shot = false
	autosave_timer.autostart = true
	autosave_timer.connect("timeout", _on_autosave_timeout)
	add_child(autosave_timer)
	
func _on_autosave_timeout():
	if game_ready and auto_save_enabled:
		save_game()
		print("Auto-save periódico realizado!")

func get_save_path():
	return "user://save_%d.dat" % current_slot

func reset_data():
	database = {
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

# =========================
# SAVE
# =========================
func save_game():
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
			database = data
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
