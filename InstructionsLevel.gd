extends Node2D

# Preload piece scene.
var pieceScene = preload("Piece.tscn")

# The board node
var board

# Chess piece to give instructions for.
var piece

# The pieces showing which cells are protected.
var protected = []

# Initialization.
func _ready():
	board = get_node("Board")
	board.set_board_size(Vector2(5, 5))
	
	piece = add_piece(1)
	piece.set_pos(board.grid_size * Vector2(2, 2))
	
	# Start by displaying the pawn.
	set_piece(1)

# Add a piece to the level.
#  type - the type of the piece
# Returns the added piece.
func add_piece(type):
	var piece = pieceScene.instance()
	add_child(piece)
	piece.set_type(type)
	piece.movable = false
	return piece

# Add a protected piece.
#  position - the position to add it to
func add_protected(position):
	var piece = add_piece(8)
	protected.append(piece)
	piece.set_pos(position * board.grid_size)

# Clear protected pieces.
func clear_protected():
	for piece in protected:
		remove_child(piece)
	protected.clear()

# Set the type of piece to explain.
func set_piece(type):
	piece.set_type(type)
	clear_protected()
	
	if type == 1:
		# Pawn
		add_protected(Vector2(1, 1))
		add_protected(Vector2(3, 1))
	elif type == 2:
		# Bishop
		add_protected(Vector2(0, 0))
		add_protected(Vector2(1, 1))
		add_protected(Vector2(4, 0))
		add_protected(Vector2(3, 1))
		add_protected(Vector2(0, 4))
		add_protected(Vector2(1, 3))
		add_protected(Vector2(4, 4))
		add_protected(Vector2(3, 3))
		pass
	elif type == 3:
		# Rook
		add_protected(Vector2(2, 0))
		add_protected(Vector2(2, 1))
		add_protected(Vector2(0, 2))
		add_protected(Vector2(1, 2))
		add_protected(Vector2(3, 2))
		add_protected(Vector2(4, 2))
		add_protected(Vector2(2, 3))
		add_protected(Vector2(2, 4))
		pass
	elif type == 4:
		# Knight
		add_protected(Vector2(0, 1))
		add_protected(Vector2(1, 0))
		add_protected(Vector2(3, 0))
		add_protected(Vector2(4, 1))
		add_protected(Vector2(4, 3))
		add_protected(Vector2(3, 4))
		add_protected(Vector2(1, 4))
		add_protected(Vector2(0, 3))
		pass
	elif type == 5:
		# King
		add_protected(Vector2(1, 1))
		add_protected(Vector2(2, 1))
		add_protected(Vector2(3, 1))
		add_protected(Vector2(3, 2))
		add_protected(Vector2(3, 3))
		add_protected(Vector2(2, 3))
		add_protected(Vector2(1, 3))
		add_protected(Vector2(1, 2))
		pass
	elif type == 6:
		# Queen
		add_protected(Vector2(0, 0))
		add_protected(Vector2(2, 0))
		add_protected(Vector2(4, 0))
		add_protected(Vector2(1, 1))
		add_protected(Vector2(2, 1))
		add_protected(Vector2(3, 1))
		add_protected(Vector2(0, 2))
		add_protected(Vector2(1, 2))
		add_protected(Vector2(3, 2))
		add_protected(Vector2(4, 2))
		add_protected(Vector2(1, 3))
		add_protected(Vector2(2, 3))
		add_protected(Vector2(3, 3))
		add_protected(Vector2(0, 4))
		add_protected(Vector2(2, 4))
		add_protected(Vector2(4, 4))
		pass
