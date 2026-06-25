extends Area2D

# Caminho da cena para onde o player vai ao tocar no cubo
@export_file("*.tscn") var cena_destino: String = "res://Scenes/Jogo principal/quarto_amigo.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Portal ativado! Limpando posição antiga de spawn...")
		
		# Resetamos a posição para ZERO para o Player entender que mudou de mapa andando
		GameManager.database["posicao_player"] = Vector2.ZERO
		
		get_tree().change_scene_to_file(cena_destino)
