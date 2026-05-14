extends CanvasLayer

@onready var anim = $AutoSaveAnim

func _ready():
	if anim:
		anim.modulate.a = 0
	else:
		print("ERRO: O nó AutoSaveAnim não foi encontrado na cena Interface!")

func play_autosave(duration := 1.5, ignore_pause := false):
	if not anim:
		return

	# Troca o layer: 100 garante que fica na frente de tudo
	if ignore_pause:
		self.layer = 100
		print("Layer Manual: ", self.layer)
	else:
		self.layer = 1
		print("Layer Auto: ", self.layer)

	anim.play()

	var mode = Tween.TWEEN_PAUSE_PROCESS if ignore_pause else Tween.TWEEN_PAUSE_BOUND
	var tween = create_tween().set_pause_mode(mode)

	anim.process_mode = Node.PROCESS_MODE_ALWAYS if ignore_pause else Node.PROCESS_MODE_INHERIT

	tween.tween_property(anim, "modulate:a", 1.0, 0.2)
	tween.tween_interval(duration)
	tween.tween_property(anim, "modulate:a", 0.0, 0.3)
	tween.tween_callback(anim.stop)
