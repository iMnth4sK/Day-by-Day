extends Node

var path = "res://Scenes/Jogo principal/principal.tscn"
var loaded = false

@onready var bar = $CanvasLayer/ProgressBar

func _ready():
	var err = ResourceLoader.load_threaded_request(path)
	
	if err != OK:
		print("Erro ao iniciar carregamento:", err)

func _process(_delta):
	if loaded:
		return

	var progress = []
	var status = ResourceLoader.load_threaded_get_status(path, progress)

	# Atualiza barra
	if progress.size() > 0:
		bar.value = progress[0] * 100

	# Sucesso
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		loaded = true
		var scene = ResourceLoader.load_threaded_get(path)
		get_tree().change_scene_to_packed(scene)

	# ERRO (isso evita travar infinito)
	elif status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Falha ao carregar a cena!")
