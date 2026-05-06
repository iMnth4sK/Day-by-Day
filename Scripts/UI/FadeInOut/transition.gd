extends CanvasLayer

@onready var fade = $ColorRect

func fade_in():

	fade.visible = true
	fade.modulate.a = 1.0

	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		0.0,
		1.0
	)

	await tween.finished

	fade.visible = false


func fade_out():

	fade.visible = true
	fade.modulate.a = 0.0

	var tween = create_tween()

	tween.tween_property(
		fade,
		"modulate:a",
		1.0,
		1.0
	)

	await tween.finished
