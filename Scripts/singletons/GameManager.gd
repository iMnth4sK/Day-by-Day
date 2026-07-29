extends Node

var settings = {
	"autosave": true,
	"master_volume": 1.0,
	"music_volume": 1.0
}

# -- CONFIGURAÇÃO DE AUTOSAVE --
var autosave_timer : Timer
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
	autosave_timer.wait_time = 300
	autosave_timer.one_shot = false
	autosave_timer.autostart = false
	autosave_timer.connect("timeout", _on_autosave_timeout)
	add_child(autosave_timer)
	
func _on_autosave_timeout():
	if not game_ready or not auto_save_enabled: 
		return
	
	# --- NOVA TRAVA: Evita salvar em telas indesejadas ---
	var cena_atual = get_tree().current_scene
	if cena_atual != null:
		var telas_proibidas = ["MainMenu", "TelaResumo"]
		if cena_atual.name in telas_proibidas:
			print("Auto-save pulado: Jogador está na tela ", cena_atual.name)
			return
	# -----------------------------------------------------
	
	# Autosave com ícone sincronizado
	Interface.play_autosave()
	save_game(true) # Passamos true para indicar que é autosave
	print("Auto-save periódico realizado!")

func get_save_path():
	return "user://save_%d.dat" % current_slot

func get_default_data():
	return {
		"save_version": 1,
		"player_name": "Novo Jogador",
		"itens_coletados": 0,
		"npc_conversa_concluida": false,
		"posicao_player": Vector2.ZERO,
		"cena_atual": "res://Scenes/Jogo principal/principal.tscn",
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
# SAVE (Ajustado para funcionar Manual e Auto)
# =========================
func save_game(is_autosave: bool = false):
	if not game_ready:
		return
	
	# Se for autosave e a opção estiver desligada, cancela
	if is_autosave and not auto_save_enabled:
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
# LOAD
# =========================
func load_game():
	var path = get_save_path()
	if not FileAccess.file_exists(path):
		reset_data()
		save_game()
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		if data is Dictionary:
			database = merge_save_data(get_default_data(), data)
			GameTime.load_from_save()
			print("SAVE SLOT", current_slot, "CARREGADO!")

func delete_save(slot: int):
	var path = "user://save_%d.dat" % slot
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

# Chamada para botões de Menu
func force_save():
	Interface.play_autosave()
	save_game(false) # false indica que NÃO é autosave, ignora a trava

func stop_autosave():
	if autosave_timer:
		autosave_timer.stop()

func start_autosave():
	if autosave_timer:
		autosave_timer.start()

# --- SETTINGS ---
func save_settings():
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	if file:
		file.store_var(settings)
		file.close()

func load_settings():
	if not FileAccess.file_exists("user://settings.dat"):
		save_settings()
		return
		
	var file = FileAccess.open("user://settings.dat", FileAccess.READ)
	if file:
		settings = file.get_var()
		file.close()
	
	auto_save_enabled = settings.get("autosave", true)
	
	# Aplica volume da música carregado
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		var vol = settings.get("music_volume", 1.0)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(vol))
		AudioServer.set_bus_mute(bus_idx, vol < 0.01)
