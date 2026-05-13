extends Node

class_name UIManager

static func fade_transition(sai: Control, entra: Control, tempo := 0.2):

	if sai:
		sai.set_process_input(false)

		var tween_out = sai.create_tween()
		tween_out.tween_property(sai, "modulate:a", 0.0, tempo)

		await tween_out.finished

		sai.visible = false

	if entra:
		entra.visible = true
		entra.modulate.a = 0

		var tween_in = entra.create_tween()
		tween_in.tween_property(entra, "modulate:a", 1.0, tempo)

		entra.set_process_input(true)

static func fade_in(node: CanvasItem, tempo := 0.2):

	node.visible = true
	node.modulate.a = 0

	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 1.0, tempo)

	return tween

static func fade_out(node: CanvasItem, tempo := 0.2):

	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, tempo)

	await tween.finished

	node.visible = false

	return tween
