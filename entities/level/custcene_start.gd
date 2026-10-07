extends Area2D

signal cutscene_finished

@export var default_timeline: String #

func _get_timeline() -> String:
	return default_timeline

# Quando player entra no collider, começa o dialogo
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Dialogic.start(_get_timeline())
		await Dialogic.timeline_ended
		cutscene_finished.emit()
		queue_free()
