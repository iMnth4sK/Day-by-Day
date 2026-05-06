extends Control

@onready var transition = $Transition

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	transition.fade_in() # Replace with function body


func _on_sair_pressed() -> void:
	await transition.fade_out()
	get_tree().quit()


func _on_opções_pressed() -> void:
	pass # Replace with function body.


func _on_novo_jogo_pressed() -> void:
	await transition.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Main Menu/Loading.tscn")
