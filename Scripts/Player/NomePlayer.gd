extends Control

@onready var input_name = $LineEdit
@onready var error_label = $ErrorLabel
@onready var transition = $Transition

func _ready() -> void:
	await transition.fade_in()


func _on_button_pressed():

	var player_name = input_name.text

	if player_name == "":
		error_label.visible = true
		return

	error_label.visible = false

	# SALVA O NOME NO DATABASE
	GameManager.database["player_name"] = player_name

	# ESCREVE O SAVE NO DISCO
	GameManager.save_game()

	await transition.fade_out()

	get_tree().change_scene_to_file("res://Scenes/Main Menu/Loading.tscn")
