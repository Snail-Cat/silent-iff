extends GameCharacter
class_name InteractableNPC
## Classe base para NPCs com lógica de interação e exibição de um diálogo fixo

signal interaction_finished

const INTERACTABLE_GROUP_KEY := "interactable"

@export var default_timeline: String


func _ready():
	super()
	add_to_group(INTERACTABLE_GROUP_KEY)


func _get_timeline() -> String:
	return default_timeline


func interact():
	if default_timeline.strip_edges().is_empty():
		return
	
	Dialogic.start(_get_timeline())
	await Dialogic.timeline_ended
	interaction_finished.emit()
