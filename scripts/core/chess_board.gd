extends RefCounted
class_name ChessBoard

var size: int
var board_state: Dictionary = {}  # grid_position -> ChessPiece

func _init(board_size: int) -> void:
	size = board_size

func place_piece(piece: ChessPiece, position: Vector2i) -> void:
	"""Place a piece on the board"""
	board_state[position] = piece
	piece.grid_position = position

func remove_piece(position: Vector2i) -> ChessPiece:
	"""Remove a piece from the board"""
	var piece = board_state.get(position)
	if piece:
		board_state.erase(position)
	return piece

func get_piece_at(position: Vector2i) -> ChessPiece:
	"""Get piece at position"""
	return board_state.get(position)

func move_piece(piece: ChessPiece, new_position: Vector2i) -> bool:
	"""Move piece to new position"""
	if not is_within_bounds(new_position):
		return false
	
	# Remove from old position
	board_state.erase(piece.grid_position)
	
	# Place at new position (capture if occupied)
	var captured = board_state.get(new_position)
	if captured:
		captured.is_destroyed = true
	
	board_state[new_position] = piece
	piece.grid_position = new_position
	
	return true

func is_within_bounds(position: Vector2i) -> bool:
	"""Check if position is within board bounds"""
	return position.x >= 0 and position.x < size and position.y >= 0 and position.y < size

func is_square_attacked(position: Vector2i, by_color: Color) -> bool:
	"""Check if square is attacked by given color"""
	for piece in board_state.values():
		if piece.color == by_color and piece.can_attack(position):
			return true
	return false

func get_all_pieces() -> Array[ChessPiece]:
	"""Get all pieces on board"""
	var pieces: Array[ChessPiece] = []
	for piece in board_state.values():
		if not piece.is_destroyed:
			pieces.append(piece)
	return pieces

func get_pieces_by_color(color: Color) -> Array[ChessPiece]:
	"""Get all pieces of given color"""
	var pieces: Array[ChessPiece] = []
	for piece in board_state.values():
		if piece.color == color and not piece.is_destroyed:
			pieces.append(piece)
	return pieces

func get_enemy_king(player_color: Color) -> ChessPiece:
	"""Get enemy king"""
	var enemy_color = Color.BLACK if player_color == Color.WHITE else Color.WHITE
	for piece in board_state.values():
		if piece.piece_type == "King" and piece.color == enemy_color:
			return piece
	return null

func grid_to_world(grid_pos: Vector2i) -> Vector3:
	"""Convert grid position to world coordinates"""
	const TILE_SIZE = 1.0
	return Vector3(grid_pos.x * TILE_SIZE + TILE_SIZE / 2, 0.5, grid_pos.y * TILE_SIZE + TILE_SIZE / 2)

func world_to_grid(world_pos: Vector3) -> Vector2i:
	"""Convert world position to grid coordinates"""
	const TILE_SIZE = 1.0
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.z / TILE_SIZE))

func get_save_data() -> Dictionary:
	"""Get saveable board state"""
	var data = {}
	for pos in board_state:
		var piece = board_state[pos]
		if not piece.is_destroyed:
			data[str(pos)] = piece.get_save_data()
	return data
