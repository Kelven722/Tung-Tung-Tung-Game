extends Control

@onready var safe_anim = get_node("../../safe/AnimationPlayer")
@onready var chest_anim = get_node("../../chest/AnimationPlayer")
@onready var doorOpen = get_node("../../door open animation")
@onready var squeakSound = get_node("../../safe door/door squeak sound")
@onready var ui = get_tree().current_scene.get_node("player/player_ui")
@onready var dialogue_ui = get_tree().current_scene.get_node("player/player_ui/dialogue_ui")
@onready var real_chest = get_node("../../chest/chest")
@onready var room_2_lights_2 = get_node("../../room2 lights that flicker/room2 lights 2/SpotLight3D")
@onready var room_2_lights_3 = get_node("../../room2 lights that flicker/room2 lights 3/SpotLight3D")
@onready var room_2_lights_2_sound = get_node("../../room2 lights that flicker/room2 lights 3/SpotLight3D/AudioStreamPlayer3D")
@onready var room_2_lights_3_sound = get_node("../../room2 lights that flicker/room2 lights 3/SpotLight3D/AudioStreamPlayer3D")
@onready var room2Text = get_node("../../room 1 door (return)/Label3D")

var jumpscare_already := false
var safe_password = "0108"
var chest_password = "friend"
var safe_interactable = true
var chest_interactable = true
var is_chest_done = false
var close_diary_times = 1
var paper2_dialogue_done := false
var touching_music_started := false

var completed_tasks := {}

func _ready() -> void:
	$fade_ui/AnimationPlayer.play("fade")
	$options.visible = false
	$pause_menu.visible = false
	$controls.visible = false
	$radio_ui.visible = false
	$safe_ui.visible = false
	$chest_ui.visible = false
	#papers
	$paper_ui1.visible = false
	$paper_ui2.visible = false
	#diarys
	$diary_ui1.visible = false
	$diary_ui2.visible = false
	
	ui.set_task("lift", "Enter elevator")
	await get_tree().create_timer(1.0, false).timeout
	$INSTRUCTIONS/AnimationPlayer.play("controls")
	$fade_ui.visible = false

######################
func set_task(key: String, task_text: String):
	if completed_tasks.has(key):
		return

	$task_ui/task_text.text = task_text

func complete_task(key: String):
	completed_tasks[key] = true
######################

func open_options():
	$pause_menu.visible = false
	$options.visible = true


func open_controls():
	$pause_menu.visible = false
	$controls.visible = true


func close_menues():
	$options.visible = false
	$controls.visible = false
	$pause_menu.visible = true


func open_pause_menu():
	$radio_ui.visible = false
	$safe_ui.visible = false
	$chest_ui.visible = false
	$options.visible = false
	$controls.visible = false
	$paper_ui1.visible = false
	$diary_ui1.visible = false

	$pause_menu.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func close_pause_menu():
	$pause_menu.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Menu Button functions
func resume_game():
	close_pause_menu()


func main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main menu/main_menu.tscn")


func quit_game():
	get_tree().quit()


# Puzzles Function

### Radio ###
func open_radio():
	if $dialogue_ui.visible:
		return

	if $pause_menu.visible:
		return

	$radio_ui.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func exit_radio():
	$radio_ui.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

###

### Safe ###
func open_safe_password():
	if $dialogue_ui.visible:
		return

	if $pause_menu.visible:
		return

	if safe_interactable:
		$safe_ui.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func comfirm_password():
	if $safe_ui/%password.text == safe_password:
		safe_anim.play("open")
		
		var real_safe_node = get_node("../../safe/safe")
		
		if real_safe_node:
			real_safe_node.is_open = true
			
			
			if real_safe_node.has_method("show_prompt"):
				real_safe_node.show_prompt()
				
		safe_interactable = false
		exit_safe()
		complete_task("safe")
	
	else:
		ui.set_task("safe", "Find clue to unlock safe")

func exit_safe():
	$safe_ui.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
###

### Chest ###

func open_chest():
	if $dialogue_ui.visible:
		return

	if $pause_menu.visible:
		return

	if chest_interactable:

		if real_chest.is_open == false:
			$chest_ui.visible = true
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


		elif real_chest.is_open == true:
			room2Text.text = "[E] Unlock Door"
			open_paper2()
			Global.play_touching_music()

	
	
	
func comfirm_chest_password():

	if $chest_ui/%password.text == chest_password:

		chest_anim.play("chest_open")

		real_chest.is_open = true
		is_chest_done = true

		$"suspens music".stop()
		$"creepy child laughing".stop()




		exit_chest()

		ui.set_task("read_paper", "Read Paper")
		ui.complete_task("read_paper")


	else:
		ui.set_task("chest_clue", "Find clue to open chest")

func exit_chest():
	$chest_ui.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

###

### Papers ###
func open_paper1():
	# Get the sound node
	var sound = $"../../Room 1/paper1/newspaper_sound"
	
	# Godot 4: Force the audio node to run during pause
	sound.process_mode = Node.PROCESS_MODE_ALWAYS 
	
	# Godot 3 alternative (uncomment if using Godot 3):
	# sound.pause_mode = Node.PAUSE_MODE_PROCESS
	
	sound.play()

	if $dialogue_ui.visible:
		return

	if $pause_menu.visible:
		return

	$paper_ui1.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

func close_paper1():
	$paper_ui1.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func open_paper2():
	# Get the sound node
	var sound = $"../../paper2/newspaper_sound"
	
	# Godot 4: Force the audio node to run during pause
	sound.process_mode = Node.PROCESS_MODE_ALWAYS 
	
	# Godot 3 alternative (uncomment if using Godot 3):
	# sound.pause_mode = Node.PAUSE_MODE_PROCESS
	
	sound.play()

	if $dialogue_ui.visible:
		return

	if $pause_menu.visible:
		return

	$paper_ui2.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func close_paper2():
	$paper_ui2.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if paper2_dialogue_done:
		return

	paper2_dialogue_done = true

	$dialogue_ui.speaker_name = "You"
	$dialogue_ui.start_dialogue([
		"Why’s my name there?",
		"Medical Certificate? PTSD?",
		"My medical certificate!",
		"Oh no...",
		"I remembered it now.",
		"...",
		"I was the bully.",
		"XXX was my friend",
		"...",
		"I remembered it all.",
		"I'm so sorry..."
	])

	await $dialogue_ui.dialogue_finished
	ui.complete_task("read_paper")
	ui.set_task("exit_room2", "Exit Room")
		
	
###

#### Diary #####

func open_diary():
	if $pause_menu.visible:
		return
	if $dialogue_ui.visible:
		return

	$diary_ui1.visible = true
	$diary_ui1/SubViewportContainer/SubViewport/Book.diary_active = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ui.set_task("read_diary1", "Read the Diary")
	
func diary_is_open() -> bool:
	return $diary_ui1.visible	

func close_diary():
	if jumpscare_already == true:
		$diary_ui1/SubViewportContainer/SubViewport/Book.diary_active = false
		$diary_ui1.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		return
	elif jumpscare_already == false:
		$diary_ui1/SubViewportContainer/SubViewport/Book.diary_active = false
		$diary_ui1.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		var ghost_scene = load("res://Ghost.tscn")
		var ghost_instance = ghost_scene.instantiate()
		
	# 2. Find the player's active 3D Camera 
	# (Looking at your player node structure: player -> head -> Camera3D)
		var player_camera = get_node_or_null("../head/Camera3D") as Camera3D
	
		if player_camera:
		# Attach the ghost directly to the camera so it matches the player's exact view
			player_camera.add_child(ghost_instance)
		
		# Reset local coordinates so the ghost aligns perfectly with the camera's lens
			ghost_instance.transform = Transform3D.IDENTITY
		else:
		# Fallback just in case the camera node path is slightly different
			get_tree().current_scene.add_child(ghost_instance)
			var player_node = get_parent() as Node3D
			if player_node:
				ghost_instance.global_transform = player_node.global_transform

	# 3. Wait for the jumpscare duration (e.g., 2.5 seconds)
		await get_tree().create_timer(1.7).timeout
	
	# 4. Remove the ghost when it's done so the player can keep playing normally!
		if is_instance_valid(ghost_instance):
			ghost_instance.queue_free()
		$dialogue_ui.speaker_name = "You"
		$dialogue_ui.start_dialogue(["ARRGGH! What was that?!"])
		ui.complete_task("read_diary1")
		await get_tree().create_timer(2.5).timeout
		doorOpen.play("door open")
		squeakSound.play()
		jumpscare_already = true
		await get_tree().create_timer(2.0).timeout
		$dialogue_ui.speaker_name = "You"
		$dialogue_ui.start_dialogue(["What's that sound?"])
		ui.set_task("door_open", "Investigate the sound")
	
#####

func open_diary2():
	if $pause_menu.visible:
		return
	if $dialogue_ui.visible:
		return

	$diary_ui2.visible = true
	$diary_ui2/SubViewportContainer/SubViewport/Book.diary_active = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ui.set_task("read_diary2", "Read the Diary")
	ui.complete_task("read_diary2")
	
func diary2_is_open() -> bool:
	return $diary_ui2.visible	


func close_diary2():
	if close_diary_times == 1:
		$diary_ui2/SubViewportContainer/SubViewport/Book.diary_active = false
		$diary_ui2.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		room_2_lights_2.flash()
		room_2_lights_3.flash()
		room_2_lights_2.visible = true
		room_2_lights_3.visible = true
		$"suspens music".play()

		await get_tree().create_timer(2.0).timeout
		room2()
		close_diary_times += 1

		$dialogue_ui.speaker_name = "You"
		$dialogue_ui.start_dialogue([
			"What's going on??!",
			"Why are there weird sounds?!",
			"Wait..?",
			"Why were there also Capital Words in the diary?",
			"Must be something related."
		])

		await $dialogue_ui.dialogue_finished
		ui.set_task("intense", "Investigate the room")

	elif close_diary_times > 1:
		$diary_ui2/SubViewportContainer/SubViewport/Book.diary_active = false
		$diary_ui2.visible = false
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
			
	
func room2():
	while is_chest_done == false:
		$"creepy child laughing".play()
		await get_tree().create_timer(9.0).timeout
		if is_chest_done == true:
			break
	room_2_lights_2.visible = false
	room_2_lights_3.visible = false
	room_2_lights_2_sound.stop()
	room_2_lights_3_sound.stop()


func _process(delta: float) -> void:
	if $dialogue_ui.visible:
		$radio_ui.visible = false
		$safe_ui.visible = false
		$chest_ui.visible = false
		$paper_ui1.visible = false
		$paper_ui2.visible = false
		$pause_menu.visible = false
		$options.visible = false
		$controls.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if Input.is_action_just_pressed("pause"):
		if diary_is_open():
			return
			
	if Input.is_action_just_pressed("pause"):
		if diary2_is_open():
			return
		
		if $paper_ui1.visible:
			close_paper1()
			return
		
		if $paper_ui2.visible:
			close_paper2()
			return
			

		if $pause_menu.visible:
			close_pause_menu()
		else:
			open_pause_menu()
