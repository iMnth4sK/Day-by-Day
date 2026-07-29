extends Control

# --- CAMINHO DOS NÓS AJUSTADOS CONFORME A SUA IMAGEM ---
@onready var grid_dias: GridContainer = $Fundo/GridDias
@onready var label_mes: Label = $Fundo/TituloMes

@export var atalho_tecla: String = "ui_focus_next"

func _ready() -> void:
	hide() # Começa invisível

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(atalho_tecla):
		if visible:
			fechar()
		else:
			abrir()

func abrir() -> void:
	atualizar_calendario()
	show()
	get_tree().paused = true
func fechar() -> void:
	hide()
	get_tree().paused = false


func atualizar_calendario() -> void:
	# Pega os dados do tempo salvos no GameManager
	var dados_tempo = GameManager.database.get("time", {})
	var dia_atual: int = dados_tempo.get("day", 1)
	var mes_atual: int = dados_tempo.get("month", 1)
	
	# Atualiza o texto do Mês
	if label_mes:
		label_mes.text = "Mês %d" % mes_atual

	if not grid_dias:
		print("ERRO: Nó GridDias não encontrado!")
		return

	# Pega TODOS os 28 filhos do GridContainer
	var todos_os_filhos = grid_dias.get_children()
	
	# Pula os 7 primeiros cabeçalhos (Semana 1 ao 7) e pega os 21 painéis dos dias
	var paineis_dias = todos_os_filhos.slice(7)
	
	for i in range(paineis_dias.size()):
		var slot = paineis_dias[i]
		var numero_do_dia = i + 1
		
		if numero_do_dia == dia_atual:
			slot.modulate = Color(1.0, 0.85, 0.3, 1.0) # DIA ATUAL (Destaque dourado)
		elif numero_do_dia < dia_atual:
			slot.modulate = Color(0.5, 0.5, 0.5, 0.7) # DIAS PASSADOS (Escurecido)
		else:
			slot.modulate = Color(1.0, 1.0, 1.0, 1.0) # DIAS FUTUROS (Cor normal)
