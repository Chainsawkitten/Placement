extends Node

# Piece textures.
var textures = [preload("res://Graphics/Pieces/Pawn.png"),
				preload("res://Graphics/Pieces/Bishop.png"),
				preload("res://Graphics/Pieces/Rook.png"),
				preload("res://Graphics/Pieces/Knight.png"),
				preload("res://Graphics/Pieces/King.png"),
				preload("res://Graphics/Pieces/Queen.png"),
				preload("res://Graphics/Pieces/Block.png"),
				preload("res://Graphics/Pieces/Protected.png")]

# Piece textures.
var textures_highlight = [preload("res://Graphics/Pieces/PawnHighlight.png"),
						  preload("res://Graphics/Pieces/BishopHighlight.png"),
						  preload("res://Graphics/Pieces/RookHighlight.png"),
						  preload("res://Graphics/Pieces/KnightHighlight.png"),
						  preload("res://Graphics/Pieces/KingHighlight.png"),
						  preload("res://Graphics/Pieces/QueenHighlight.png")]

# Mute button textures.
var audio_on_texture = preload("res://Graphics/AudioOn.png")
var audio_on_hover_texture = preload("res://Graphics/AudioOnHover.png")
var audio_off_texture = preload("res://Graphics/AudioOff.png")
var audio_off_hover_texture = preload("res://Graphics/AudioOffHover.png")

# Whether we're in the level editor.
var editor = false

# Whether audio should be muted.
var muted = false

# Window size.
var fullscreen = true
var window_width = 1024
var window_height = 768
var screen_size = Vector2(window_width, window_height)

# Zoom
var zoom = 1

# Whether we're currently fading between levels.
var fading = false

# Initialization.
func _ready():
	# Don't allow enter or space to switch levels, etc.
	if InputMap.has_action("ui_accept"):
		InputMap.erase_action("ui_accept");
	InputMap.add_action("ui_accept");
	
	# Load settings from config file.
	var config = ConfigFile.new()
	var error = config.load("user://settings.cfg")
	if error == OK:
		muted = config.get_value("audio", "muted", false)
		fullscreen = config.get_value("window", "fullscreen", true)
		window_width = config.get_value("window", "width", 1024)
		if window_width < 640:
			window_width = 640
		window_height = config.get_value("window", "height", 768)
		if window_height < 480:
			window_height = 480
	
	# Change window mode based on settings.
	set_fullscreen(fullscreen)

# Get the texture for a chess piece.
#  type - the type of chess piece
func get_piece_texture(type):
	return textures[type - 1]

# Get the highlight texture for a chess piece.
#  type - the type of chess piece
func get_piece_highlight_texture(type):
	return textures_highlight[type - 1]

# Set whether we're in the editor.
#  editor - whether we're in the editor
func set_editor(editor):
	self.editor = editor

# Get whether we're in the editor.
func get_editor():
	return editor

# Set whether audio should be muted.
#  muted - whether audio should be muted
func set_muted(muted):
	self.muted = muted
	save_config()

# Get whether audio should be muted.
func get_muted():
	return muted

# Get texture for mute button when audio is on.
func get_audio_on_texture():
	return audio_on_texture

# Get hover texture for mute button when audio is on.
func get_audio_on_hover_texture():
	return audio_on_hover_texture

# Get texture for mute button when audio is off.
func get_audio_off_texture():
	return audio_off_texture

# Get hover texture for mute button when audio is off.
func get_audio_off_hover_texture():
	return audio_off_hover_texture

# Set the level of zoom.
#  zoom - the level of zoom.
func set_zoom(zoom):
	self.zoom = zoom;

# Get the level of zoom.
func get_zoom():
	return zoom

# Save config to file.
func save_config():
	# Save in config file.
	var config = ConfigFile.new()
	config.set_value("audio", "muted", muted)
	config.set_value("window", "fullscreen", fullscreen)
	config.set_value("window", "width", window_width)
	config.set_value("window", "height", window_height)
	config.save("user://settings.cfg")

# Set whether we're currently fading between levels.
#  fading - whether we're fading between levels
func set_fading(fading):
	self.fading = fading

# Get whether we're currently fading between levels.
func is_fading():
	return fading

# Set whether to use fullscreen mode.
#  fullscreen - whether to use fullscreen mode
func set_fullscreen(fullscreen):
	self.fullscreen = fullscreen
	
	if fullscreen:
		# Change to fullscreen mode.
		OS.set_window_fullscreen(true)
		if OS.get_name() != "OSX":
			OS.set_borderless_window(true)
	else:
		# Change to windowed mode.
		if OS.get_name() != "OSX":
			OS.set_borderless_window(false)
		OS.set_window_fullscreen(false)
		OS.set_window_size(Vector2(global.window_width, global.window_height))

# Set the size of the screen.
#  screen_size - the size of the screen
func set_screen_size(screen_size):
	if !self.fullscreen:
		window_width = screen_size.x
		window_height = screen_size.y
		save_config()
	
	if screen_size.x < 640:
		screen_size.x = 640
	if screen_size.y < 480:
		screen_size.y = 480
	self.screen_size = screen_size
