# test_scene.gd (Version for GODOT 4.x)
extends Node

const ClientScene = preload("res://client.tscn")
const SituationScene = preload("res://situation.tscn")

signal choice_made(choice: int)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var key_string = event.as_text()
		if key_string.is_valid_int():
			var choice_num = key_string.to_int()
			if choice_num >= 0 and choice_num <= 9:
				print(">> You chose: %d" % choice_num)
				choice_made.emit(choice_num)

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	run_encounter()

func run_encounter() -> void:
	print("\n\n=============== A NEW CLIENT APPROACHES ===============")

	var client = ClientScene.instantiate()
	var situation = SituationScene.instantiate()
	add_child(client)
	add_child(situation)
	client.initialize_randomly()
	situation.initialize_randomly()

	print("\n--- APPEARANCE ---")
	print(client.get_appearance_description())
	await get_tree().create_timer(1.0).timeout

	var deck_keys = DataManager.cards.keys()
	deck_keys.shuffle()
	var player_hand = [deck_keys[0], deck_keys[1], deck_keys[2]]

	print("\n--- YOUR HAND ---")
	print("You draw three cards from your deck:")
	print("  1. %s" % player_hand[0])
	print("  2. %s" % player_hand[1])
	print("  3. %s" % player_hand[2])
	print("  4. Leave it to fate (Draw a random card)")
	print("\nCHOOSE A CARD (Press 1-4)...")

	var card_choice = -1
	while card_choice < 1 or card_choice > 4:
		card_choice = await self.choice_made
		if card_choice < 1 or card_choice > 4:
			print("Invalid choice. Please press a key from 1 to 4.")

	var chosen_card_name: String
	if card_choice == 4:
		chosen_card_name = deck_keys[3]
		print("You let fate decide and draw the [", chosen_card_name, "]...")
	else:
		chosen_card_name = player_hand[card_choice - 1]
		print("You select the [", chosen_card_name, "]...")

	var chosen_card_data = DataManager.cards[chosen_card_name]
	await get_tree().create_timer(1.0).timeout

	print("\n--- THE CLIENT'S STORY ---")
	print("The client leans in and speaks:")
	print("\"", situation.get_full_description(), "\"")
	await get_tree().create_timer(1.0).timeout

	# --- MODIFIED SECTION START ---
	# Get all interpretations and shuffle them to randomize the order.
	# We use .duplicate() so we don't change the order in the DataManager.
	var all_interpretations = chosen_card_data.interpretations.duplicate()
	all_interpretations.shuffle()

	# Decide how many to show (a maximum of 3, or fewer if the card doesn't have 3).
	var num_to_offer = min(3, all_interpretations.size())
	# Take the first few from the shuffled list.
	var offered_interpretations = all_interpretations.slice(0, num_to_offer)

	print("\n--- YOUR INTERPRETATION ---")
	print("You consult the [", chosen_card_name, "] and prepare your reading. How do you interpret the card?")
	# Loop through and print only the 3 random options.
	for i in offered_interpretations.size():
		print("  %d. \"%s\"" % [i + 1, offered_interpretations[i].text])
	print("\nCHOOSE AN INTERPRETATION (Press 1-%d)..." % offered_interpretations.size())
	
	var interp_choice = -1
	# The input loop now correctly checks against the number of offered interpretations.
	while interp_choice < 1 or interp_choice > offered_interpretations.size():
		interp_choice = await self.choice_made
		if interp_choice < 1 or interp_choice > offered_interpretations.size():
			print("Invalid choice. Please press a key from 1 to %d." % offered_interpretations.size())

	# Select the interpretation from the smaller, randomized list.
	var chosen_interpretation = offered_interpretations[interp_choice - 1]
	# --- MODIFIED SECTION END ---

	client.apply_stat_changes(chosen_interpretation.effects)
	await get_tree().create_timer(1.0).timeout

	print("\n--- THE OUTCOME ---")
	var final_outcome = situation.calculate_final_outcome(client.stats)
	print("You deliver your reading. The client nods, thanks you, and leaves...")
	print("Weeks later, you hear what became of them:")
	print("\"", final_outcome.description, "\"")

	client.queue_free()
	situation.queue_free()

	print("\n=============== ENCOUNTER ENDS ===============")
	await get_tree().create_timer(3.0).timeout
	run_encounter()
