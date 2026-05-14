extends CanvasLayer

@onready var fade = $ColorRect

func _ready():
	# Garante que o fade comece cobrindo tudo se necessário
	fade.visible = true
	fade.modulate.a = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_STOP

func fade_in(duration: float = 1.5):
	fade.visible = true
	# Transição mais suave com TRANS_QUART
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	fade.visible = false
	# Libera o mouse para interagir com o jogo
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

func fade_out(duration: float = 1.0):
	fade.visible = true
	fade.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)
	
	await tween.finished
