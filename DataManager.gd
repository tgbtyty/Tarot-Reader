# DataManager.gd (Updated for Outcome Groups)
extends Node

var client_stat_template: Dictionary = {}
var cards: Dictionary = {}
var events: Dictionary = {}
var feelings: Array = []
var actions: Dictionary = {}
# NEW: This will hold all our outcome groups.
var outcome_groups: Dictionary = {}


func _ready() -> void:
	print("DataManager: Loading all game data...")
	_load_client_template()
	_load_tarot_deck()
	_load_events()
	_load_feelings()
	_load_actions()
	# NEW: Loading the new file.
	_load_outcome_groups()
	print("DataManager: All data loaded successfully!")


func _load_json(path: String) -> Variant:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print("ERROR: Failed to load JSON file at path: ", path)
		return null
	return JSON.parse_string(file.get_as_text())


func _load_client_template():
	var data = _load_json("res://game_data/client_stats_template.json")
	if data:
		client_stat_template = data.stats

func _load_tarot_deck():
	var data = _load_json("res://game_data/tarot_deck.json")
	if data:
		for card_data in data.cards:
			cards[card_data.name] = card_data

func _load_events():
	var data = _load_json("res://game_data/events.json")
	if data:
		for event_data in data.events:
			events[event_data.event_id] = event_data

func _load_feelings():
	var data = _load_json("res://game_data/feelings.json")
	if data:
		feelings = data.feelings

func _load_actions():
	var data = _load_json("res://game_data/actions.json")
	if data:
		for action_data in data.actions:
			actions[action_data.action_id] = action_data

# NEW: Function to load the outcome groups.
func _load_outcome_groups():
	var data = _load_json("res://game_data/outcome_groups.json")
	if data:
		outcome_groups = data.outcome_groups
