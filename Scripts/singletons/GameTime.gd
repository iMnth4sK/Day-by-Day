extends Node

func _ready():
	load_from_save()
	print("SAVE CARREGADO -> Dia:", day, "Idade:", age)
	
func load_from_save():
	if GameManager.database.has("time"):
		load_save_data(GameManager.database["time"])
	else:
		GameManager.database["time"] = get_save_data()

signal day_passed
signal age_changed
signal life_stage_changed

var day := 1
var year := 1
var age := 6
var life_stage := "child"

const DAYS_PER_YEAR := 365


func next_day():

	day += 1
	print("Dia atual:", day)
	
	if day > DAYS_PER_YEAR:
		day = 1
		year += 1
		age += 1
		emit_signal("age_changed", age)
		update_life_stage()

	emit_signal("day_passed")
	save_game()


func update_life_stage():

	var previous_stage = life_stage

	if age >= 18:
		life_stage = "adult"
	elif age >= 12:
		life_stage = "teen"
	else:
		life_stage = "child"

	if previous_stage != life_stage:
		emit_signal("life_stage_changed", life_stage)


# SAVE INTEGRATION
func get_save_data():
	return {
		"day": day,
		"year": year,
		"age": age,
		"life_stage": life_stage
	}


func load_save_data(data):
	day = data["day"]
	year = data["year"]
	age = data["age"]
	life_stage = data["life_stage"]

func save_game():
	if GameManager:
		GameManager.database["time"] = get_save_data()
		GameManager.save_game()
		
func _input(event):
	if event.is_action_pressed("debug_next_day"):
		next_day()

func reset_time():

	day = 1
	year = 1
	age = 6
	life_stage = "child"

	print("Tempo resetado!")
