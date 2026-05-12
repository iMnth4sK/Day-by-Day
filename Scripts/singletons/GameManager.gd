extends Node

# SLOT ATUAL
var current_slot := 1

func get_save_path():
	return "user://save_%d.dat" % current_slot


# =========================
# DATABASE
# =========================
var database = {}

func reset_data():
	database = {
		"player_name": "",
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

	# 1️⃣ pega player primeiro
	var player = get_tree().get_first_node_in_group("player")

	if player:
		player.save_player_data()

	# 2️⃣ garante que o valor foi atualizado
	print("Posição sendo salva:", database["posicao_player"])

	# 3️⃣ salva tempo
	database["time"] = GameTime.get_save_data()

	# 4️⃣ escreve no disco
	var file = FileAccess.open(get_save_path(), FileAccess.WRITE)

	if file:
		file.store_var(database)
		file.close()
		print("SAVE OK SLOT", current_slot)


# =========================
# LOAD
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
		database = file.get_var()
		file.close()
		print("SAVE SLOT", current_slot, "CARREGADO!")


# =========================
# DELETE
# =========================
func delete_save(slot:int):

	var path = "user://save_%d.dat" % slot

	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Save", slot, "apagado")
var game_ready := false
