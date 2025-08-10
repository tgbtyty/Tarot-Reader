# Situation.gd (Updated with hidden info)
class_name Situation
extends Node

var event_data: Dictionary
var feeling_data: Dictionary
var action_data: Dictionary
var potential_outcomes: Array[Dictionary] = []


func initialize_randomly() -> void:
	var event_ids = DataManager.events.keys()
	event_data = DataManager.events[event_ids.pick_random()]
	
	var event_positivity = event_data["positivity"]
	var valid_feelings = []
	for feeling in DataManager.feelings:
		var trigger = feeling.trigger_condition
		if event_positivity >= trigger.min and event_positivity <= trigger.max:
			valid_feelings.append(feeling)
	
	if not valid_feelings.is_empty():
		feeling_data = valid_feelings.pick_random()
	else:
		feeling_data = DataManager.feelings.pick_random()

	var action_id = event_data.compatible_action_ids.pick_random()
	action_data = DataManager.actions[action_id]
	
	potential_outcomes.clear()
	for outcome_id in event_data.compatible_outcome_ids:
		if DataManager.outcomes.has(outcome_id):
			potential_outcomes.append(DataManager.outcomes[outcome_id])

	# This line is now commented out.
	# print("Situation generated for event: ", event_data.event_id)


func get_full_description() -> String:
	var event_desc = event_data.descriptions.pick_random()
	var feeling_desc = feeling_data.descriptions.pick_random()
	var action_desc = action_data.descriptions.pick_random()
	
	return "%s %s %s" % [event_desc, feeling_desc, action_desc]


func calculate_final_outcome(client_stats: Dictionary) -> Dictionary:
	var best_outcome: Dictionary
	var highest_score = -INF

	for outcome in potential_outcomes:
		var current_score = 0.0
		for stat_name in outcome.likelihood_formula:
			var weight = outcome.likelihood_formula[stat_name]
			var client_stat_value = client_stats.get(stat_name, 0.0)
			current_score += client_stat_value * weight
		
		if current_score > highest_score:
			highest_score = current_score
			best_outcome = outcome
			
	if not best_outcome:
		return {"description": "The client's future remains shrouded in mystery."}
	
	# This line is now commented out.
	# print("Outcome calculated. Highest score: %f, Winning Outcome ID: %s" % [highest_score, best_outcome.outcome_id])
	return best_outcome
