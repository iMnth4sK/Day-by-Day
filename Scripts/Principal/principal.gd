extends Node

func _ready():
	await get_tree().process_frame
	queue_free()
