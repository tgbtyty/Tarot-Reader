# Situation.gd
class_name Situation
extends Node

# These will hold the specific data for this one instance of a situation.
var event_data: Dictionary
var feeling_data: Dictionary
var action_data: Dictionary
var potential_outcomes: Array[Dictionary] = []


# This is the factory that builds the client's story.
func initialize_randomly() -> void:
	# 1. Pick a random event.
	var event_ids = DataManager.events.keys()
	event_data = DataManager.events[event_ids.pick_random()]
	
	# 2. Find a feeling that matches the event's positivity score.
	var event_positivity = event_data["positivity"]
	var valid_feelings = []
	for feeling in DataManager.feelings:
		if event_positivity >= feeling.trigger_condition.min and event_positivity <= feeling.trigger_condition.max:
			valid_feelings.append(feeling)
	
	if not valid_feelings.is_empty():
		feeling_data = valid_feelings.pick_random()
	else:
		# Fallback if no feeling is found (shouldn't happen with our current data)
		feeling_data = DataManager.feelings.pick_random()

	# 3. Pick a compatible action for the event.
	var action_id = event_data.compatible_action_ids.pick_random()
	action_data = DataManager.actions[action_id]
	
	# 4. Load the list of all possible outcomes for this event.
	for outcome_id in event_data.compatible_outcome_ids:
		if DataManager.outcomes.has(outcome_id):
			potential_outcomes.append(DataManager.outcomes[outcome_id])

	print("Situation generated for event: ", event_data.event_id)


# Assembles the full description to show the player.
func get_full_description() -> String:
	var desc1 = event_data.descriptions.subject_focused
	var desc2 = feeling_data.descriptions.pick_random()
	var desc3 = action_data.descriptions.pick_random()
	
	return "%s %s %s" % [desc1, desc2, desc3]


# The final calculation! Determines the outcome based on the client's final stats.
func calculate_final_outcome(client_stats: Dictionary) -> Dictionary:
	var best_outcome: Dictionary
	var highest_score = -INF # Start with a very low number

	# Loop through every possible outcome for this situation.
	for outcome in potential_outcomes:
		var current_score = 0.0
		# For each outcome, calculate its likelihood score.
		for stat_name in outcome.likelihood_formula:
			var weight = outcome.likelihood_formula[stat_name]
			var client_stat_value = client_stats.get(stat_name, 0.0) # Default to 0 if stat doesn't exist
			current_score += client_stat_value * weight
		
		# If this outcome has a higher score than the previous best, it's the new winner.
		if current_score > highest_score:
			highest_score = current_score
			best_outcome = outcome
			
	print("Outcome calculated. Highest score: %f, Winning Outcome ID: %s" % [highest_score, best_outcome.outcome_id])
	return best_outcome
