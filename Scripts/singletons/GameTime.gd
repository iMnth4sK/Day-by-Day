extends Node

signal day_passed
signal age_changed
signal life_stage_changed
signal hour_changed(new_hour)
signal time_updated(hour, minute) # Novo sinal que manda Hora E Minuto!

var hour := 8
var minute := 0
var day := 1
var month := 1
var year := 1
var age := 6
var life_stage := "child"

# --- CONFIGURAÇÃO DO TEMPO REAL ---
# 600s / 16h = 37.5s por hora de jogo
# 37.5s / 6 blocos (de 10 min) = 6.25s por cada 10 minutos no jogo
const SECONDS_PER_10_MIN := 6.25
var time_accumulator := 0.0

const DAYS_PER_MONTH := 21
const MONTHS_PER_YEAR := 8
const HOURS_PER_DAY := 24

func _ready() -> void:
	await get_tree().process_frame
	load_from_save()

func load_from_save() -> void:
	if GameManager and GameManager.database and GameManager.database.has("time"):
		load_save_data(GameManager.database["time"])
		print("SAVE CARREGADO ->", hour, ":", minute, "| Dia:", day)
	else:
		if GameManager and GameManager.database:
			GameManager.database["time"] = get_save_data()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
		
	time_accumulator += delta
	
	# A cada 6.25s reais, avança 10 minutos
	if time_accumulator >= SECONDS_PER_10_MIN:
		time_accumulator -= SECONDS_PER_10_MIN
		add_minutes(10)

## Avança os minutos e lida com a virada de hora
func add_minutes(mins_to_add: int) -> void:
	minute += mins_to_add
	
	if minute >= 60:
		minute = 0
		add_hours(1)
	else:
		# Se só mudou o minuto, avança a UI
		emit_signal("time_updated", hour, minute)

## Avança as horas
func add_hours(hours_to_add: int) -> void:
	hour += hours_to_add
	
	if hour >= HOURS_PER_DAY:
		hour -= HOURS_PER_DAY
		next_day(false)
		
	emit_signal("hour_changed", hour)
	emit_signal("time_updated", hour, minute)
	print("Tempo no jogo: %02d:%02d | Dia: %d" % [hour, minute, day])

## Dormir reseta os minutos para 00 e avança as 8 horas
func sleep(hours_to_sleep: int = 8) -> void:
	time_accumulator = 0.0
	minute = 0 # Acorda na hora cheia
	add_hours(hours_to_sleep)
	save_game()

func next_day(save := true) -> void:
	day += 1
	
	if day > DAYS_PER_MONTH:
		day = 1
		month += 1
		
		if month > MONTHS_PER_YEAR:
			month = 1
			year += 1
			age += 1
			emit_signal("age_changed", age)
			update_life_stage()

	emit_signal("day_passed")
	if save:
		save_game()

func update_life_stage() -> void:
	var previous_stage = life_stage
	if age >= 18:
		life_stage = "adult"
	elif age >= 12:
		life_stage = "teen"
	else:
		life_stage = "child"

	if previous_stage != life_stage:
		emit_signal("life_stage_changed", life_stage)

# --- SAVE INTEGRATION ---
func get_save_data() -> Dictionary:
	return {
		"hour": hour,
		"minute": minute,
		"day": day,
		"month": month,
		"year": year,
		"age": age,
		"life_stage": life_stage
	}

func load_save_data(data: Dictionary) -> void:
	hour = data.get("hour", 8)
	minute = data.get("minute", 0)
	day = data.get("day", 1)
	month = data.get("month", 1)
	year = data.get("year", 1)
	age = data.get("age", 6)
	life_stage = data.get("life_stage", "child")

func save_game() -> void:
	if GameManager:
		GameManager.database["time"] = get_save_data()
		GameManager.save_game()

func reset_time() -> void:
	hour = 8
	minute = 0
	day = 1
	month = 1
	year = 1
	age = 6
	life_stage = "child"
	time_accumulator = 0.0
