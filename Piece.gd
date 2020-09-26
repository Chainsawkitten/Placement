extends TextureButton

# The type of piece.
var type = 0

# Whether the piece is able to be moved.
# Pieces in the instructions shouldn't be moved.
var movable = true

# Whether the piece is currently being moved.
var moving = false

# Whether the piece has been moved.
var moved = false

# Relative mouse positions.
var relative_mouse_pos

# Starting position.
var initial_position = Vector2(0, 0)

# Size of a grid cell.
var grid_size = 256

# Target position.
var target_position = Vector2(0, 0)
var min_move_speed = 4000.0
var min_speed_distance = 800.0

# Whether the piece is hovered.
var hover = false

# Color highlighting.
var valid = true
var black = Color(0.0, 0.0, 0.0, 1.0)
var red = Color(0.7, 0.15, 0.15, 1.0)

# Highlight.
var highlight_node
var highlighted = false
var highlight_opacity = 0

# Initialization
func _ready():
	highlight_node = get_node("Highlight")
	
	set_process(true)
	set_process_input(true)

# Called every frame.
func _process(delta):
	if movable:
		if moving:
			set_pos((get_viewport().get_mouse_pos() / global.get_zoom() - relative_mouse_pos).floor())
		else:
			var movement_direction = target_position - get_pos()
			var distance = movement_direction.length()
			
			# Move faster when further away from target.
			var speed = min_move_speed
			if (distance > min_speed_distance):
				speed += (distance - min_speed_distance) * 4.0
			
			if distance < speed * delta:
				set_pos(target_position)
			else:
				set_pos((get_pos() + movement_direction.normalized() * speed * delta).floor())
	
	# Fade in/out highlight.
	if highlighted:
		highlight_node.show()
		highlight_opacity += 2 * delta
		if highlight_opacity > 1:
			highlight_opacity = 1
	else:
		highlight_opacity -= 2 * delta
		if highlight_opacity < 0:
			highlight_node.hide()
		if highlight_opacity < -0.5:
			highlight_opacity = -0.5
	highlight_node.set_opacity(highlight_opacity)

# Handle button presses.
func _input(event):
	# Right mouse button clicked.
	if movable and type != 7 and event.is_action_pressed("remove_piece") and hover and !global.is_fading():
		moved = true
		target_position = initial_position
	
	# Left mouse button released.
	if event.is_action_released("move_piece") and moving:
		moving = false
		target_position = Vector2(round(get_pos().x / grid_size) * grid_size, round(get_pos().y / grid_size) * grid_size)
		if !global.get_muted():
			get_node("SoundEffect").set_default_pitch_scale(0.9 + 0.2*randf())
			get_node("SoundEffect").play("Move")
		moved = true

# Set the type of piece this is.
func set_type(type):
	self.type = type
	set_normal_texture(global.get_piece_texture(type))
	if type == 7:
		set_draw_behind_parent(true)
	if type < 7:
		highlight_node.set_texture(global.get_piece_highlight_texture(type))

# Get the type of piece this is.
func get_type():
	return type

# Clear whether the piece has been moved.
func clear_moved():
	moved = false

# Get whether the piece has been moved.
func has_moved():
	return moved

# Set the piece's starting position.
#  pos - the position to set
func set_initial_position(pos):
	set_pos(pos)
	initial_position = pos
	target_position = pos

# Reset the piece to its initial position.
func reset_position():
	target_position = initial_position

# Set target position.
#  pos - the position to move to
func set_target_position(pos):
	target_position = pos

# Get target position.
func get_target_position():
	return target_position

# Called when the button is pressed.
func _on_Piece_button_down():
	if movable and !global.is_fading():
		if type != 7 or global.get_editor():
			moving = true
			relative_mouse_pos = get_viewport().get_mouse_pos() / global.get_zoom() - get_pos()

# Mouse enter.
func _on_Piece_mouse_enter():
	hover = true

# Mouse leave.
func _on_Piece_mouse_exit():
	hover = false

# Set whether the piece is valid.
# Colors the piece depending on validity.
func set_valid(valid):
	self.valid = valid
	if valid:
		set_modulate(black)
	else:
		set_modulate(red)

# Get whether the piece is valid.
func is_valid():
	return valid

# Set whether the piece should be highlighted.
#  highlighted - whether the piece should be highlighted
func set_highlighted(highlighted):
	self.highlighted = highlighted
