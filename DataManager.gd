# DataManager.gd
extends Node

# These dictionaries will hold all our game data, keyed by their IDs.
var client_stat_template: Dictionary = {}
var cards: Dictionary = {}
var events: Dictionary = {}
var feelings: Array = [] # Feelings are checked by range, so an array is fine.
var actions: Dictionary = {}
var outcomes: Dictionary = {}


func _ready() -> void:
	# When the game starts, load everything into memory.
	print("DataManager: Loading all game data...")
	_load_client_template()
	_load_tarot_deck()
	_load_events()
	_load_feelings()
	_load_actions()
	_load_outcomes()
	print("DataManager: All data loaded successfully!")


# --- Private Loading Functions ---

func _load_json(path: String) -> Variant:
	# Helper function to open and parse a JSON file.
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("ERROR: Failed to load JSON file at path: ", path)
		return null
	return JSON.parse_string(file.get_as_text())


func _load_client_template() -> void:
	var data = _load_json("res://game_data/client_stats_template.json")
	if data:
		client_stat_template = data["stats"]


func _load_tarot_deck() -> void:
	var data = _load_json("res://game_data/tarot_deck.json")
	if data:
		for card_data in data["cards"]:
			cards[card_data["name"]] = card_data # Use card name as the key


func _load_events() -> void:
	var data = _load_json("res://game_data/events.json")
	if data:
		for event_data in data["events"]:
			events[event_data["event_id"]] = event_data


func _load_feelings() -> void:
	var data = _load_json("res://game_data/feelings.json")
	if data:
		feelings = data["feelings"]


func _load_actions() -> void:
	var data = _load_json("res://game_data/actions.json")
	if data:
		for action_data in data["actions"]:
			actions[action_data["action_id"]] = action_data


func _load_outcomes() -> void:
	var data = _load_json("res://game_data/potential_outcomes.json")
	if data:
		for outcome_data in data["outcomes"]:
			outcomes[outcome_data["outcome_id"]] = outcome_data
