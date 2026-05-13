extends CanvasLayer

@onready var anim = $AutoSaveAnim

func _ready():
	if anim:
		anim.modulate.a = 0
	else:
		print("ERRO: O nó AutoSaveAnim não foi encontrado na cena Interface!")

func play_autosave(duration := 1.5):
	if not anim:
		return
	anim.play()
	var tween = create_tween()
	tween.tween_property(anim, "modulate:a", 1.0, 0.2)
	tween.tween_interval(duration)
	tween.tween_property(anim, "modulate:a", 0.0, 0.3)
	tween.tween_callback(anim.stop)
