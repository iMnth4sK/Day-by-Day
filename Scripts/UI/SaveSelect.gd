extends Control

@onready var slot1 = $VBoxContainer/HBoxContainer/Slot1
@onready var slot2 = $VBoxContainer/HBoxContainer2/Slot2
@onready var slot3 = $VBoxContainer/HBoxContainer3/Slot3
@onready var del_slot1 = $VBoxContainer/HBoxContainer/DelSlot1
@onready var del_slot2 = $VBoxContainer/HBoxContainer2/DelSlot2
@onready var del_slot3 = $VBoxContainer/HBoxContainer3/DelSlot3
@onready var delete_confirm = $DeleteConfirm

var slot_to_delete := -1

func _ready():
	update_slots()
	
func _on_slot_1_pressed() -> void:
	enter_slot(1)

func _on_slot_2_pressed() -> void:
	enter_slot(2)

func _on_slot_3_pressed() -> void:
	enter_slot(3)

func update_slots():
	update_button(slot1, del_slot1, 1)
	update_button(slot2, del_slot2, 2)
	update_button(slot3, del_slot3, 3)

func update_button(button, del_button, slot):

	var path = "user://save_%d.dat" % slot

	var exists = FileAccess.file_exists(path)

	del_button.visible = exists

	if exists:

		var file = FileAccess.open(path, FileAccess.READ)
		var data = file.get_var()
		file.close()

		button.text = "Slot %d | %s | Dia %d | Idade %d" % [
			slot,
			data["player_name"],
			data["time"]["day"],
			data["time"]["age"]
		]

	else:
		button.text = "Slot %d — Novo Jogo" % slot

func _on_del_slot_1_pressed() -> void:
	ask_delete(1)

func _on_del_slot_2_pressed() -> void:
	ask_delete(2)

func _on_del_slot_3_pressed() -> void:
	ask_delete(3)

func enter_slot(slot):

	GameManager.current_slot = slot

	var path = GameManager.get_save_path()

	if FileAccess.file_exists(path):
		GameManager.load_game()
		get_tree().change_scene_to_file("res://Scenes/Main Menu/Loading.tscn")
	else:
		GameManager.reset_data()
		GameTime.reset_time()
		get_tree().change_scene_to_file("res://Scenes/Player/NamePlayer.tscn")
	
func delete_slot(slot):

	GameManager.delete_save(slot)

	if GameManager.current_slot == slot:
		GameTime.reset_time()
		GameManager.reset_data()

	update_slots()
	
func ask_delete(slot):

	slot_to_delete = slot
	delete_confirm.popup_centered()
	
func _on_delete_confirm_confirmed():
	delete_slot(slot_to_delete)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main Menu/MainMenu.tscn")
