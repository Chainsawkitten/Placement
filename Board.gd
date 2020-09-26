extends TextureFrame

# The board size.
var board_size

# The size of a grid cell.
var grid_size = 256

# A cell in the grid.
class Cell:
	var type = 0
	var status = 0
	var piece
	var protectors = []

# The board grid.
var grid = []

# Initialize.
func _ready():
	pass

# Set the board size.
#  size - new board size
func set_board_size(size):
	board_size = size
	set_size(size * grid_size)
	get_node("Outline").set_size(size * grid_size + Vector2(32, 32))
	
	for x in range(size.x):
		grid.append([])
		for y in range(size.y):
			grid[x].append(Cell.new())

# Get the board size.
func get_board_size():
	return board_size

# Clear solved state.
func clear():
	for x in range(board_size.x):
		for y in range(board_size.y):
			grid[x][y].type = 0
			grid[x][y].status = 0
			grid[x][y].protectors = []

# Add a piece to the board.
#  piece - the piece to add
# Returns whether the piece was added successfullt (not out of bounds).
func add_piece(piece):
	var x = int(piece.get_target_position().x / grid_size)
	var y = int(piece.get_target_position().y / grid_size)
	
	# Check that the piece is within bounds.
	if x < 0 or x >= board_size.x or y < 0 or y >= board_size.y:
		return false
	
	# Add the information to the board.
	grid[x][y].type = piece.get_type()
	grid[x][y].piece = piece
	
	return true

# Get the cell at a given position.
#  position - the position to get
func get_cell(position):
	var x = int(position.x / grid_size)
	var y = int(position.y / grid_size)
	
	return grid[x][y]

# Check whether the board is solved.
func check_solved():
	# Mark pieces.
	for x in range(board_size.x):
		for y in range(board_size.y):
			mark_piece(Vector2(x, y))
	
	# Check that all pieces are protected once.
	for x in range(board_size.x):
		for y in range(board_size.y):
			if grid[x][y].type != 0 and grid[x][y].type != 7 and grid[x][y].status != 1:
				return false
	
	return true

# Mark the piece at the given position.
#  pos - the position of the piece to mark
func mark_piece(pos):
	var cell = grid[pos.x][pos.y]
	
	if cell.type == 0:
		# Empty cell.
		return;
	elif cell.type == 1:
		# Pawn
		mark_finite(cell.piece, pos, [Vector2(-1, -1), Vector2(1, -1)])
	elif cell.type == 2:
		# Bishop
		mark_infinite(cell.piece, pos, [Vector2(-1, -1), Vector2(1, -1),
						                Vector2(1, 1),  Vector2(-1, 1)])
	elif cell.type == 3:
		# Rook
		mark_infinite(cell.piece, pos, [Vector2(0, -1), Vector2(1, 0),
						                Vector2(0, 1),  Vector2(-1, 0)])
	elif cell.type == 4:
		# Knight
		mark_finite(cell.piece, pos, [Vector2(-1, -2), Vector2(1, -2),
						              Vector2(2, -1),  Vector2(2, 1),
						              Vector2(1, 2),   Vector2(-1, 2),
						              Vector2(-2, 1),  Vector2(-2, -1)])
		pass
	elif cell.type == 5:
		# King
		mark_finite(cell.piece, pos, [Vector2(-1, -1), Vector2(0, -1),
						              Vector2(1, -1),  Vector2(1, 0),
						              Vector2(1, 1),   Vector2(0, 1),
						              Vector2(-1, 1),  Vector2(-1, 0)])
	elif cell.type == 6:
		# Queen
		mark_infinite(cell.piece, pos, [Vector2(-1, -1), Vector2(0, -1),
						                Vector2(1, -1),  Vector2(1, 0),
						                Vector2(1, 1),   Vector2(0, 1),
						                Vector2(-1, 1),  Vector2(-1, 0)])

# Mark a finite amount of spaces relative to a position.
#  piece - marking piece
#  pos - position
#  rel_pos - relative positions
func mark_finite(piece, pos, rel_pos):
	for r in rel_pos:
		mark(piece, pos + r)

# Mark an infinite amount of spaces relative to a position.
#  piece - marking piece
#  pos - position
#  rel_pos - relative positions
func mark_infinite(piece, pos, rel_pos):
	for r in rel_pos:
		var p = pos + r
		while mark(piece, p):
			p += r

# Mark a position.
#  piece - marking piece
#  pos - the position to mark
# Returns whether the marking was within-bounds and unoccupied.
func mark(piece, pos):
	# Check that the position is within bounds.
	if pos.x < 0 or pos.x >= board_size.x or pos.y < 0 or pos.y >= board_size.y:
		return false
	
	# Mark the position.
	grid[pos.x][pos.y].status += 1
	grid[pos.x][pos.y].protectors.append(piece)
	
	# Return whether it was unoccupied.
	return grid[pos.x][pos.y].type == 0

# Get whether a piece is valid (is protected once).
#  piece - the piece to check
# Returns whether the piece is protected exactly once.
func is_valid(piece):
	return get_piece_status(piece) == 1

# Get the status of a piece.
#  piece - the piece to check
# Returns the number of times the piece is protected.
func get_piece_status(piece):
	var x = int(piece.get_target_position().x / grid_size)
	var y = int(piece.get_target_position().y / grid_size)
	
	return grid[x][y].status
