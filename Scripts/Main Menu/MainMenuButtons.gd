extends Control

@onready var transition = $Transition
@onready var novo_jogo_button = $VBoxContainer/NovoJogo

func _ready() -> void:
	transition.fade_in()
	
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		novo_jogo_button.text = "Continuar"
	else:
		novo_jogo_button.text = "Novo Jogo"
		
func _on_sair_pressed() -> void:
	await transition.fade_out()
	get_tree().quit()
	
func _on_opções_pressed() -> void:
	pass
	
func _on_novo_jogo_pressed() -> void:
	await transition.fade_out()
	
	# SE EXISTE SAVE
	if FileAccess.file_exists(GameManager.SAVE_PATH):
		GameManager.load_game()
		
		get_tree().change_scene_to_file("res://Scenes/Main Menu/Loading.tscn")
		
	# SE NÃO EXISTE SAVE
	else:
		
		GameManager.reset_data()
		
		get_tree().change_scene_to_file("res://Scenes/Player/NamePlayer.tscn")
