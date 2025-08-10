# Client.gd (With Amplified Interpretation Effects)
class_name Client
extends Node

# NEW: This constant controls how powerful your interpretations are.
# Feel free to change this value to 2.0 or 3.0 to fine-tune the game's feel.
const INTERPRETATION_MULTIPLIER = 2.5

# This dictionary will hold the client's current stats, like {"Hope": 50, "Anxiety": -20}.
var stats: Dictionary = {}


# Call this to create a new, randomized client.
func initialize_randomly() -> void:
	var template = DataManager.client_stat_template
	stats.clear() # Clear any old stats.

	for stat_name in template:
		var stat_info = template[stat_name]
		# For each stat, pick a random starting value within its defined min/max range.
		stats[stat_name] = randf_range(stat_info["min"], stat_info["max"])


# Call this to apply the effects from a Tarot interpretation.
func apply_stat_changes(effects: Dictionary) -> void:
	for stat_name in effects:
		if stats.has(stat_name):
			var change_amount = effects[stat_name]
			
			# MODIFIED: We now multiply the change by our new constant.
			stats[stat_name] += change_amount * INTERPRETATION_MULTIPLIER
			
			# IMPORTANT: Clamp the value to ensure it never goes above 100 or below -100.
			stats[stat_name] = clampf(stats[stat_name], -100, 100)
		else:
			print("Warning: Attempted to change non-existent stat: ", stat_name)


# This function generates the initial text description of the client.
func get_appearance_description() -> String:
	if stats.is_empty():
		return "An empty silhouette sits before you."

	var sorted_stats: Array = []
	for key in stats:
		sorted_stats.append([key, stats[key]])

	sorted_stats.sort_custom(func(a, b): return abs(a[1]) > abs(b[1]))
	
	var top_stat_name = sorted_stats[0][0]
	var top_stat_value = sorted_stats[0][1]
	var second_stat_name = sorted_stats[1][0]
	# ADDED: We need to get the value of the second stat as well.
	var second_stat_value = sorted_stats[1][1]
	
	var description = "A client sits before you. "
	
	if top_stat_name == "Anxiety" and top_stat_value > 50:
		description += "Their leg bounces nervously, and they can't seem to meet your gaze. "
	elif top_stat_name == "Confidence" and top_stat_value > 50:
		description += "They carry themselves with an air of unshakeable confidence, looking at you expectantly. "
	elif top_stat_name == "Hope" and top_stat_value < -50:
		description += "A heavy air of despair hangs around them; their shoulders are slumped in defeat. "
	elif top_stat_name == "Cynicism" and top_stat_value > 50:
		description += "They watch you with a suspicious, narrowed gaze, a cynical smirk playing on their lips. "
	else:
		description += "They have an unreadable expression, waiting for you to begin. "
		
	# CORRECTED: These lines now use 'second_stat_value' for the number comparison.
	if second_stat_name == "Patience" and second_stat_value < -50:
		description += "You get the sense they are deeply impatient and want to get this over with."
	elif second_stat_name == "Sociability" and second_stat_value < -50:
		description += "They seem withdrawn and uncomfortable with the social interaction."

	return description
