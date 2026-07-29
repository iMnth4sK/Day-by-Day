extends CanvasLayer

@onready var auto_save_btn: Button = $PanelContainer/VBoxContainer/ToggleAutoSave
@onready var input_hora: LineEdit = $PanelContainer/VBoxContainer/HBoxContainer_Hora/InputHora
@onready var input_minuto: LineEdit = $PanelContainer/VBoxContainer/HBoxContainer_Hora/InputMinuto
@onready var btn_set_time: Button = $PanelContainer/VBoxContainer/HBoxContainer_Hora/BtnSetTime

@onready var btn_next_day: Button = $PanelContainer/VBoxContainer/BtnNextDay
@onready var btn_next_month: Button = $PanelContainer/VBoxContainer/BtnNextMonth
@onready var btn_next_year: Button = $PanelContainer/VBoxContainer/BtnNextYear

func _ready() -> void:
	visible = false 
	_atualizar_ui()
	
	# Conexões automáticas dos botões normais
	if btn_set_time: btn_set_time.pressed.connect(_on_btn_set_time_pressed)
	if btn_next_day: btn_next_day.pressed.connect(_on_btn_next_day_pressed)
	if btn_next_month: btn_next_month.pressed.connect(_on_btn_next_month_pressed)
	if btn_next_year: btn_next_year.pressed.connect(_on_btn_next_year_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_key"):
		visible = !visible
		if visible:
			_atualizar_ui()

func _atualizar_ui() -> void:
	if GameManager and auto_save_btn is CheckButton:
		auto_save_btn.button_pressed = GameManager.auto_save_enabled
	
	# Preenche os campos com a hora atual do jogo para você ver o tempo corrente
	if GameTime:
		input_hora.text = str(GameTime.hour)
		input_minuto.text = str(GameTime.minute)

# --- DIGITAR E SETAR A HORA / MINUTO DESEJADO ---
func _on_btn_set_time_pressed() -> void:
	if not GameTime: return
	
	var nova_hora: int = input_hora.text.to_int()
	var novo_minuto: int = input_minuto.text.to_int()
	
	# Garante limites válidos (0 a 23 horas e 0 a 59 minutos)
	nova_hora = clampi(nova_hora, 0, 23)
	novo_minuto = clampi(novo_minuto, 0, 59)
	
	GameTime.hour = nova_hora
	GameTime.minute = novo_minuto
	GameTime.time_accumulator = 0.0 # Reseta o contador para não pular minuto logo em seguida
	
	# Emite os sinais para atualizar a HUD e o relógio instantaneamente
	GameTime.emit_signal("hour_changed", GameTime.hour)
	GameTime.emit_signal("time_updated", GameTime.hour, GameTime.minute)
	
	print("Debug: Tempo alterado manualmente para %02d:%02d" % [GameTime.hour, GameTime.minute])

# --- BOTÕES DE CONTROLE DE TEMPO ---

func _on_btn_next_day_pressed() -> void:
	if GameTime:
		GameTime.next_day(false)
		_atualizar_ui()
		print("Debug: +1 Dia pulado.")

func _on_btn_next_month_pressed() -> void:
	if GameTime:
		# Em vez de loop gigantesco, avança exatamente 21 dias (1 mês completo)
		for i in range(GameTime.DAYS_PER_MONTH):
			GameTime.next_day(false)
		_atualizar_ui()
		print("Debug: +1 Mês pulado.")

func _on_btn_next_year_pressed() -> void:
	if GameTime:
		# Avança 8 meses (1 ano completo no seu jogo)
		var dias_no_ano = GameTime.DAYS_PER_MONTH * GameTime.MONTHS_PER_YEAR # 21 * 8 = 168 dias
		for i in range(dias_no_ano):
			GameTime.next_day(false)
		_atualizar_ui()
		print("Debug: +1 Ano pulado.")

# --- CONTROLE DE CONFIGURAÇÃO ---

func _on_toggle_auto_save_toggled(toggled_on: bool) -> void:
	if GameManager:
		GameManager.auto_save_enabled = toggled_on
		print("Debug: Auto-save alterado para: ", toggled_on)
