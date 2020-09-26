extends Node2D

# A list of all the levels.
var levels = []

# The current level.
var level = 0
var next_level = 0
var max_level = 0
var solved = false

# The level node.
var levelNode
var titleNode

# Level select.
var previousButton
var nextButton

# Quit button.
var quitButton

# Mute audio.
var muteButton

# Fading
var fade = false
var loaded = false
var fadeFrame
var opacity = 0
var fadeSpeed = 1.0

# Quitting.
var quit = false
var quitFrame
var quitFade = 0
var musicPlayer

# Instructions
var instructions
var instructions_button

# Determine whether we need to rezoom (window has been resized)
var last_screen_size

# Initialization.
func _ready():
	levelNode = get_node("Level")
	titleNode = get_node("Title")
	previousButton = get_node("PreviousButton")
	nextButton = get_node("NextButton")
	quitButton = get_node("QuitButton")
	muteButton = get_node("MuteButton")
	set_mute_button_textures()
	fadeFrame = get_node("FadeFrame")
	quitFrame = get_node("QuitFrame")
	instructions = get_node("Instructions")
	instructions_button = get_node("InstructionsButton")
	musicPlayer = get_node("MusicPlayer")
	if global.get_muted():
		musicPlayer.set_volume(0)
	musicPlayer.play()
	set_process(true)
	set_process_input(true)
	
	last_screen_size = get_viewport_rect().size
	
	# Load level list.
	var file = File.new()
	file.open("res://Levels/Playl.ist", File.READ)
	
	var line
	line = file.get_line()
	while !line.empty():
		levels.append(line)
		line = file.get_line()
	
	file.close()
	
	# Load current level.
	load_progress()

# Called every frame.
func _process(delta):
	var buttonOffset = 8
	previousButton.set_pos(Vector2(buttonOffset, 0))
	previousButton.set_hidden(level == 0)
	nextButton.set_hidden(level >= levels.size() - 1 or level >= max_level)
	nextButton.set_pos(Vector2(global.screen_size.x - 128 - 2 * buttonOffset, 0))
	quitButton.set_pos(Vector2(global.screen_size.x - 64 - buttonOffset, 0))
	titleNode.set_pos(Vector2((global.screen_size.x - titleNode.get_size().x) / 2, 7))
	muteButton.set_pos(Vector2(buttonOffset, global.screen_size.y - 64))
	instructions_button.set_pos(global.screen_size - Vector2(buttonOffset + 64, 64))
	
	if !solved and levelNode.is_solved():
		solved = true
		_on_NextButton_pressed()
		fadeSpeed = 1.0
		if !global.get_muted():
			get_node("VictoryJingle").play()
		if max_level <= level:
			max_level = level + 1
		save_progress()
	
	if levelNode.piece_moved:
		levelNode.piece_moved = false
	
	# Rezoom if window size has changed.
	if get_viewport_rect().size != last_screen_size:
		last_screen_size = get_viewport_rect().size
		global.set_screen_size(last_screen_size)
		zoom_level()
	
	global.set_fading(fade or quit)
	
	# Fading between levels.
	if fade:
		opacity += delta * fadeSpeed
		if opacity <= 1:
			fadeFrame.set_opacity(opacity)
		else:
			if !loaded:
				level = next_level
				load_level(level)
				loaded = true
			
			if opacity < 2:
				fadeFrame.set_opacity(2 - opacity)
			else:
				fadeFrame.set_opacity(0)
				fade = false
				opacity = 0
	
	# Quitting.
	if quit:
		quitFade += delta
		if quitFade > 1:
			get_tree().quit()
	else:
		quitFade -= delta
		if quitFade < 0:
			quitFade = 0
	
	quitFrame.set_opacity(quitFade)
	if !global.get_muted():
		musicPlayer.set_volume(1.0 - quitFade)

# Handle notifications.
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		save_placement()
		get_tree().quit()

# Handle input.
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		quit = true
	
	if event.is_action_released("ui_cancel"):
		quit = false
	
	if event.is_action_pressed("ui_windowed"):
		global.set_fullscreen(!global.fullscreen)
		global.save_config()

# Load a level in the level list.
#  index - the index of the level to load
func load_level(index):
	levelNode.load_level("res://Levels/" + levels[index] + ".lvl")
	levelNode.load_placement("user://" + levels[index] + ".sav")
	titleNode.set_text(String(index + 1))
	solved = false
	
	zoom_level()

# Save current progress.
func save_progress():
	var file = File.new()
	file.open("user://progress", File.WRITE)
	file.store_16(max_level)
	file.close()

# Load stored progress.
func load_progress():
	var file = File.new()
	if file.file_exists("user://progress"):
		file.open("user://progress", File.READ)
		max_level = file.get_16()
		file.close()
	
	if max_level < levels.size() - 1:
		level = max_level
	else:
		level = levels.size() - 1
	
	next_level = level
	load_level(level)

# Save placement.
func save_placement():
	levelNode.save_placement("user://" + levels[level] + ".sav")

# Previous button pressed.
func _on_PreviousButton_pressed():
	if next_level > 0:
		fadeSpeed = 3.0
		if opacity > 1:
			opacity = 2 - opacity
		next_level -= 1
		fade = true
		loaded = false
		save_placement()

# Next button pressed.
func _on_NextButton_pressed():
	if next_level < levels.size() - 1 and next_level <= max_level:
		fadeSpeed = 3.0
		if opacity > 1:
			opacity = 2 - opacity
		next_level += 1
		fade = true
		loaded = false
		save_placement()

# Mute button pressed.
func _on_MuteButton_pressed():
	# Toggle whether sound is muted.
	global.set_muted(!global.get_muted())
	
	if global.get_muted():
		musicPlayer.set_volume(0)
	else:
		musicPlayer.set_volume(1)
	
	set_mute_button_textures()

# Set mute button textures.
func set_mute_button_textures():
	if global.get_muted():
		muteButton.set_normal_texture(global.get_audio_off_texture())
		muteButton.set_hover_texture(global.get_audio_off_hover_texture())
	else:
		muteButton.set_normal_texture(global.get_audio_on_texture())
		muteButton.set_hover_texture(global.get_audio_on_hover_texture())

# Zoom the level an appropriate amount.
func zoom_level():
	# Calculate the max allowed area.
	# Take into account interface and description text.
	var max_area = global.screen_size
	max_area.y -= 300
	
	# Get the size of the board.
	var level_size = levelNode.board.get_board_size()
	
	# Room for pieces at the side (same on both sides).
	level_size.x += 4 + 2 * ceil(levelNode.non_block_pieces / levelNode.board.get_board_size().y)
	level_size *= levelNode.grid_size
	
	if levelNode.description != " ":
		level_size.y += levelNode.grid_size
		var description = levelNode.get_node("DescriptionLabel")
		level_size.y += description.get_line_count() * 120
		
		level_size.x = max(level_size.x, 2000)
	
	# Calculate maximum level of zoom.
	var zoom = max_area.x / level_size.x
	zoom = min(zoom, max_area.y / level_size.y)
	zoom = min(zoom, 1)
	global.set_zoom(zoom)
	
	# Place the level appropriately.
	var x_pos = (max_area.x - levelNode.get_level_size().x * zoom) / 2
	var y_pos = 150 + (max_area.y - level_size.y * zoom) / 2
	levelNode.set_pos(Vector2(floor(x_pos), floor(y_pos)))
	levelNode.set_scale(Vector2(zoom, zoom))

# Instructions button pressed.
func _on_InstructionsButton_pressed():
	instructions.open()

# Quit button pressed.
func _on_QuitButton_pressed():
	quit = true
