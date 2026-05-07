extends Node

# Nome do arquivo de save que será criado no PC do usuário
const SAVE_PATH = "user://save_game.dat"

# Sua Base de Dados (Dicionário com tudo que você quer salvar)
var database = {
	"player_name": "",
	"itens_coletados": 0,
	"npc_conversa_concluida": false,
	"posicao_player": Vector2.ZERO
}
func reset_data():
	database = {
		"player_name": "",
		"itens_coletados": 0,
		"npc_conversa_concluida": false,
		"posicao_player": Vector2.ZERO
	}

func _ready():
	# Assim que o jogo abre, ele tenta carregar o progresso anterior
	load_game()

# FUNÇÃO PARA SALVAR: Pega o que está na memória e escreve no disco
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(database)
		file.close()
		print("Sistema: Dados salvos no disco com sucesso!")

# FUNÇÃO PARA CARREGAR: Lê o arquivo do disco e coloca na memória
func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			database = file.get_var()
			file.close()
			print("Sistema: Dados carregados com sucesso!")
	else:
		print("Sistema: Nenhum save encontrado. Iniciando novo banco de dados.")
