extends Node2D

# The level node
var instructions_level

# Piece names
var piece_name_label
var piece_names = ["Pawn", "Bishop", "Rook", "Knight", "King", "Queen"]

# Navigation buttons.
var current_piece = 1
var piece_type = 1
var piece_types = [1, 4, 2, 3, 6, 5]
var previous_button
var next_button

var zoom = 1
var background

# Fade in and out.
var opacity = 0
var opening = false
var closing = false
var fade_speed = 4

# Determine whether we need to rezoom (window has been resized)
var last_screen_size

# Initialization.
func _ready():
	# Get children.
	instructions_level = get_node("InstructionsLevel")
	previous_button = get_node("PreviousButton")
	next_button = get_node("NextButton")
	piece_name_label = get_node("PieceNameLabel")
	background = get_node("Background")
	
	last_screen_size = get_viewport_rect().size
	zoom_instructions()
	
	set_process(true)
	set_process_input(true)

# Called each frame.
func _process(delta):
	if opening:
		opacity += fade_speed * delta
		if opacity >= 1:
			opening = false
			opacity = 1
	elif closing:
		opacity -= fade_speed * delta
		if opacity <= 0:
			closing = false
			opacity = 0
			hide()
	
	# Rezoom if window size has changed.
	if get_viewport_rect().size != last_screen_size:
		last_screen_size = get_viewport_rect().size
		zoom_instructions()
	
	set_opacity(opacity)

# Handle input.
func _input(event):
	if is_visible():
		if event.type == InputEvent.MOUSE_BUTTON:
			if event.pos.y < background.get_pos().y or event.pos.y > background.get_pos().y + background.get_size().y:
				opening = false
				closing = true

# Previous button pressed.
func _on_PreviousButton_pressed():
	if current_piece > 1:
		current_piece -= 1
		set_piece()

# Next button pressed.
func _on_NextButton_pressed():
	if current_piece < 6:
		current_piece += 1
		set_piece()

# Set piece.
func set_piece():
	previous_button.set_hidden(current_piece <= 1)
	next_button.set_hidden(current_piece >= 6)
	
	piece_type = piece_types[current_piece - 1]
	piece_name_label.set_text(piece_names[piece_type-1])
	instructions_level.set_piece(piece_type)

# Show the instructions.
func open():
	show()
	opening = true
	closing = false

func zoom_instructions():
	# Position and scale elements accordingly.
	
	# Level
	var screen_size = global.screen_size
	var level_size = Vector2(1, 1) * 5 * instructions_level.board.grid_size
	zoom = min(screen_size.x / 2 / level_size.x, screen_size.y / 3 / level_size.y)
	instructions_level.set_pos(((screen_size - zoom * level_size) / 2).floor())
	instructions_level.set_scale(Vector2(zoom, zoom))
	
	# Buttons
	previous_button.set_pos((screen_size / 2 - Vector2(level_size.x * zoom / 2 + 32 + 100, 32)).floor())
	previous_button.hide()
	
	next_button.set_pos((screen_size / 2 + Vector2(level_size.x * zoom / 2 - 32 + 100, -32)).floor())
	
	# Show the name of the piece.
	piece_name_label.set_text("Pawn")
	var label_size = Vector2(800, 280) * zoom
	piece_name_label.set_size(label_size)
	piece_name_label.get_font("font").set_size(168 * zoom)
	piece_name_label.set_pos((screen_size / 2 - Vector2(label_size.x / 2, label_size.y + level_size.y * zoom / 2)).floor())
	
	# Background
	var background_height = floor((level_size.y + 320 * 2) * zoom)
	background.set_pos(Vector2(0, (screen_size.y - background_height) / 2).floor())
	background.set_size(Vector2(screen_size.x, background_height))
	
	# Lines.
	var top_line = get_node("TopLine")
	var line_height = floor(40 * zoom)
	top_line.set_pos(Vector2(0, (screen_size.y - background_height) / 2 - line_height).floor())
	top_line.set_size(Vector2(screen_size.x, line_height))
	
	var bottom_line = get_node("BottomLine")
	bottom_line.set_pos(Vector2(0, (screen_size.y + background_height) / 2))
	bottom_line.set_size(Vector2(screen_size.x, line_height))
	
	# Fader
	var fader = get_node("Fader")
	fader.set_size(screen_size)
