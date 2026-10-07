extends DialogicSubsystem

## Subsystem that manages showing and activating of choices.

## Emitted when a choice button was pressed. Info includes the keys 'button_index', 'text', 'event_index'.
signal choice_selected(info: Dictionary)


#region STATE
####################################################################################################

func clear_game_state(_clear_flag := DialogicGameHandler.ClearFlags.FULL_CLEAR) -> void:
	hide_choices()


func _ready() -> void:
	pass

#endregion


#region MAIN METHODS
####################################################################################################

## Hides all choice buttons.
func hide_choices() -> void:
	var nodes_in_group := get_tree().get_nodes_in_group(ActionChoicesHandler.GROUP_KEY)
	if nodes_in_group.size() <= 0:
		return
	var action_choices_handler := nodes_in_group[0] as ActionChoicesHandler
	action_choices_handler.clear()


## Collects information on the choices of the current question.
func get_current_choices_info() -> Dictionary[ActionChoices.ActionChoiceType, ActionChoiceInfo]:
	var choices: Dictionary[ActionChoices.ActionChoiceType, ActionChoiceInfo] = {}

	for choice_index in get_current_choice_indexes():
		var event: DialogicEvent = dialogic.current_timeline_events[choice_index]

		if not event is DialogicActionChoicesEvent:
			continue

		var choice_event: DialogicActionChoicesEvent = event
		var text := choice_event.get_property_translated('text')
		text = dialogic.Text.parse_text(text, 1)
		var type = choice_event.choice_type

		choices[type] = ActionChoiceInfo.new(choice_index, text, type, choice_event.extra_data)

	return choices


## Displays the choice selection UI
func show_current_question(instant := true) -> void:
	hide_choices()
	var choices_info := get_current_choices_info()
	var ambition_choice = choices_info.get(ActionChoices.ActionChoiceType.AMBITION)
	var modesty_choice = choices_info.get(ActionChoices.ActionChoiceType.MODESTY)
	if !ambition_choice or !modesty_choice:
		printerr("[ActionChoices]: A pair of modesty and ambition choice events was not found.")
		return
	var action_choices_handler := get_tree().get_nodes_in_group(ActionChoicesHandler.GROUP_KEY)[0] as ActionChoicesHandler
	if action_choices_handler.choice_selected.is_connected(_on_choice_selected):
		action_choices_handler.choice_selected.disconnect(_on_choice_selected)
	action_choices_handler.choice_selected.connect(_on_choice_selected)
	action_choices_handler.start_choice(ambition_choice, modesty_choice)


func _on_choice_selected(choice_info: ActionChoiceInfo) -> void:
	choice_selected.emit(choice_info)
	hide_choices()
	ActionChoices.register_choice(choice_info.choice_type)
	dialogic.current_state = dialogic.States.IDLE
	dialogic.handle_event(choice_info.event_index + 1)


func get_current_choice_indexes() -> Array:
	var choices := []
	var ambition_event: DialogicActionChoicesEvent
	var modesty_event: DialogicActionChoicesEvent
	var evt_idx := dialogic.current_event_idx
	var ignore := 0
	while true:
		if evt_idx >= len(dialogic.current_timeline_events):
			break
		if dialogic.current_timeline_events[evt_idx] is DialogicActionChoicesEvent:
			var choice_event := dialogic.current_timeline_events[evt_idx] as DialogicActionChoicesEvent
			if ignore == 0:
				if !ambition_event and choice_event.choice_type == ActionChoices.ActionChoiceType.AMBITION:
					ambition_event = choice_event
					choices.append(evt_idx)
				elif !modesty_event and choice_event.choice_type == ActionChoices.ActionChoiceType.MODESTY:
					modesty_event = choice_event
					choices.append(evt_idx)
				else:
					break
			ignore += 1
		elif dialogic.current_timeline_events[evt_idx].can_contain_events:
			ignore += 1
		else:
			if ignore == 0:
				break

		if dialogic.current_timeline_events[evt_idx] is DialogicEndBranchEvent:
			ignore -= 1
		evt_idx += 1
	
	return choices

#endregion


#region HELPERS
####################################################################################################

func is_question(index: int) -> bool:
	if dialogic.current_timeline_events[index] is DialogicTextEvent:
		if len(dialogic.current_timeline_events) - 1 != index:
			if dialogic.current_timeline_events[index + 1] is DialogicActionChoicesEvent:
				return true

	if dialogic.current_timeline_events[index] is DialogicActionChoicesEvent:
		if index != 0 and dialogic.current_timeline_events[index - 1] is DialogicEndBranchEvent:
			if dialogic.current_timeline_events[dialogic.current_timeline_events[index - 1].find_opening_index(index - 1)] is DialogicActionChoicesEvent:
				return false
			else:
				return true
		else:
			return true
	return false

#endregion
