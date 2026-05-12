extends Control

@onready var transition = $Transition
@onready var iniciar_button = $VBoxContainer/Iniciar


func _ready() -> void:
	transition.fade_in()


func _on_sair_pressed() -> void:
	await transition.fade_out()
	get_tree().quit()


func _on_opções_pressed() -> void:
	pass


func _on_iniciar_pressed() -> void:
	await transition.fade_out()

	# 🔥 vai pra tela de slots (ela decide tudo)
	get_tree().change_scene_to_file("res://Scenes/Main Menu/SaveSelect.tscn")
