# Situation.gd (Corrected with a different typing approach)
class_name Situation
extends Node

var event_data: Dictionary
var feeling_data: Dictionary
var action_data: Dictionary
# CORRECTED LINE: The variable is now declared as a generic Array.
var potential_outcomes: Array = []


func initialize_randomly() -> void:
	# 1. Pick a random event.
	var event_ids = DataManager.events.keys()
	event_data = DataManager.events[event_ids.pick_random()]
	
	# 2. Find a feeling that matches the event's positivity score.
	var event_positivity = event_data.positivity
	var valid_feelings = []
	for feeling in DataManager.feelings:
		var trigger = feeling.trigger_condition
		if event_positivity >= trigger.min and event_positivity <= trigger.max:
			valid_feelings.append(feeling)
	
	if not valid_feelings.is_empty():
		feeling_data = valid_feelings.pick_random()
	else:
		feeling_data = DataManager.feelings.pick_random()

	# 3. Pick a compatible action for the event.
	var action_id = event_data.compatible_action_ids.pick_random()
	action_data = DataManager.actions[action_id]
	
	# 4. Load the entire group of potential outcomes for this event.
	var group_id = event_data.get("outcome_group_id")
	if group_id and DataManager.outcome_groups.has(group_id):
		# The 'as' cast is no longer needed here because the types now match.
		potential_outcomes = DataManager.outcome_groups[group_id]
	else:
		potential_outcomes.clear()
		print("ERROR: Could not find outcome group with ID: ", group_id)


func get_full_description() -> String:
	var event_desc = event_data.descriptions.pick_random()
	var feeling_desc = feeling_data.descriptions.pick_random()
	var action_desc = action_data.descriptions.pick_random()
	
	return "%s %s %s" % [event_desc, feeling_desc, action_desc]


func calculate_final_outcome(client_stats: Dictionary) -> Dictionary:
	var best_outcome: Dictionary
	var highest_score = -INF

	if potential_outcomes.is_empty():
		return {"description": "The client's future remains shrouded in mystery."}
		
	for outcome in potential_outcomes:
		var current_score = 0.0
		for stat_name in outcome.likelihood_formula:
			var weight = outcome.likelihood_formula[stat_name]
			var client_stat_value = client_stats.get(stat_name, 0.0)
			current_score += client_stat_value * weight
		
		if current_score > highest_score:
			highest_score = current_score
			best_outcome = outcome
			
	return best_outcome
