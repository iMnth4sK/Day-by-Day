extends Label

func _ready():
	# Conecta o sinal do seu GameTime para atualizar a interface automaticamente
	GameTime.day_passed.connect(_on_day_passed)
	# Atualiza o texto assim que o jogo começa
	atualizar_texto()

func _on_day_passed():
	# Toda vez que o dia mudar no GameTime, essa função roda
	atualizar_texto()

func atualizar_texto():
	# Muda o texto da tela para mostrar o Dia e a Idade atuais do GameTime
	text = "Dia: " + str(GameTime.day) + " (Idade: " + str(GameTime.age) + ")"
