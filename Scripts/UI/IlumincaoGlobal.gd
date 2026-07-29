extends CanvasModulate

# As cores para cada momento do dia (podem ser ajustadas no Inspector depois!)
@export var cor_manha: Color = Color(1.0, 0.95, 0.85, 1.0)    # Luz solar suave (06:00 - 11:00)
@export var cor_dia: Color = Color(1.0, 1.0, 1.0, 1.0)         # Luz total do dia (12:00 - 17:00)
@export var cor_tarde: Color = Color(0.9, 0.6, 0.4, 1.0)       # Entardecer alaranjado (18:00 - 19:00)
@export var cor_noite: Color = Color(0.2, 0.25, 0.45, 1.0)     # Escuro azulado da noite (20:00 - 05:00)

func _ready() -> void:
	# Conecta ao sinal de tempo do GameTime
	if GameTime.has_signal("time_updated"):
		GameTime.time_updated.connect(_on_time_updated)
	
	# Aplica a cor da hora atual logo de cara
	atualizar_iluminacao(GameTime.hour, GameTime.minute)

func _on_time_updated(hora: int, minuto: int) -> void:
	atualizar_iluminacao(hora, minuto)

func atualizar_iluminacao(hora: int, minuto: int) -> void:
	# Converte a hora + minuto para um valor decimal continuo (ex: 18:30 vira 18.5)
	var tempo_decimal: float = hora + (minuto / 60.0)
	var cor_alvo: Color = cor_dia

	# Define a cor base dependendo do horário
	if tempo_decimal >= 5.0 and tempo_decimal < 8.0:
		# Transição Madrugada -> Manhã
		var t = (tempo_decimal - 5.0) / 3.0
		cor_alvo = cor_noite.lerp(cor_manha, t)
		
	elif tempo_decimal >= 8.0 and tempo_decimal < 12.0:
		# Manhã
		cor_alvo = cor_manha
		
	elif tempo_decimal >= 12.0 and tempo_decimal < 17.0:
		# Meio-dia até o meio da tarde
		cor_alvo = cor_dia
		
	elif tempo_decimal >= 17.0 and tempo_decimal < 20.0:
		# Pôr do Sol / Entardecer (17:00 as 20:00)
		var t = (tempo_decimal - 17.0) / 3.0
		cor_alvo = cor_dia.lerp(cor_tarde, t) if t < 0.5 else cor_tarde.lerp(cor_noite, (t - 0.5) * 2.0)
		
	else:
		# Noite (20:00 até 05:00)
		cor_alvo = cor_noite

	# Suaviza a transição da cor da luz para não dar 'trancos' na tela
	create_tween().tween_property(self, "color", cor_alvo, 1.0)
