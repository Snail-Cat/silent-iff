extends CanvasLayer

@export var main_menu_scene_path: String

@onready var animation_player := %AnimationPlayer

func _ready():
	hide()


func _on_cutscene_finished():
	await get_tree().process_frame
	LevelManager.control_to_system()
	show()
	animation_player.play("fade_in")


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene_path)
