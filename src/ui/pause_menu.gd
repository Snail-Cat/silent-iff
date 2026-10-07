extends Control

@export var top_button: Button
@export var main_menu_scene_path: String

@onready var animation_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("RESET")
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and get_tree().paused == false:
		_pause()


func _retornar() -> void:
	animation_player.play_backwards("blur")
	await animation_player.animation_finished
	get_tree().paused = false
	var _dialogic_node = Dialogic.Styles.get_layout_node()
	if _dialogic_node:
		_dialogic_node.show()
	hide()


func _pause() -> void:
	show()
	get_tree().paused = true
	animation_player.play("blur")
	var _dialogic_node = Dialogic.Styles.get_layout_node()
	if _dialogic_node:
		_dialogic_node.hide()
	top_button.grab_focus()


func _on_retornar_pressed() -> void:
	_retornar()


func _on_sair_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	animation_player.play_backwards("blur")
	await animation_player.animation_finished
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_scene_path)
