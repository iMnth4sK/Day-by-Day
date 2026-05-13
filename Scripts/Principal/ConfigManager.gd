extends Node

var config = {
	"music_volume": 1.0,
	"autosave": true
}

func save_config():

	var file = FileAccess.open("user://config.dat", FileAccess.WRITE)

	if file:
		file.store_var(config)
		file.close()

func load_config():

	if not FileAccess.file_exists("user://config.dat"):
		save_config()
		return

	var file = FileAccess.open("user://config.dat", FileAccess.READ)

	if file:
		config = file.get_var()
		file.close()
