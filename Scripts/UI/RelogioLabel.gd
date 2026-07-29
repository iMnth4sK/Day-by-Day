extends Label

func _ready() -> void:
	# Conecta ao novo sinal de tempo completo (hora e minuto)
	if GameTime.has_signal("time_updated"):
		GameTime.time_updated.connect(_on_time_updated)
	
	# Atualiza o texto imediatamente ao carregar
	atualizar_relogio(GameTime.hour, GameTime.minute)

func _on_time_updated(h: int, m: int) -> void:
	atualizar_relogio(h, m)

func atualizar_relogio(h: int, m: int) -> void:
	# Formata bonito com dois dígitos em cada lado (ex: 08:00, 08:10)
	text = "%02d:%02d" % [h, m]
