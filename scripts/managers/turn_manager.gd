extends Node

class_name TurnManager

# Turn state
var is_player_turn: bool = true
var turn_count: int = 0
var current_piece_index: int = 0
var current_piece: ChessPiece

# Signals
signal turn_started(is_player: bool)
signal turn_ended(was_player: bool)
signal piece_turn_started(piece: ChessPiece)
signal piece_turn_ended(piece: ChessPiece)

# References
var board: ChessBoard
var all_pieces: Array[ChessPiece] = []
var enemy_pieces: Array[ChessPiece] = []

func _ready() -> void:
	pass

func initialize(game_board: ChessBoard) -> void:
	"""Initialize turn manager with board reference"""
	board = game_board

func setup_pieces(pieces_array: Array[ChessPiece]) -> void:
	"""Set up piece lists"""
	all_pieces = pieces_array
	enemy_pieces = board.get_pieces_by_color(Color.BLACK)

func start_player_turn() -> void:
	"""Start player turn"""
	is_player_turn = true
	turn_count += 1
	turn_started.emit(true)

func end_player_turn() -> void:
	"""End player turn and start enemy turn"""
	is_player_turn = false
	turn_ended.emit(true)
	start_enemy_turn()

func start_enemy_turn() -> void:
	"""Start enemy turn with all enemy pieces"""
	is_player_turn = false
	current_piece_index = 0
	turn_started.emit(false)
	execute_next_enemy_piece()

func execute_next_enemy_piece() -> void:
	"""Execute next enemy piece's turn"""
	if current_piece_index >= enemy_pieces.size():
		# End enemy turn
		turn_ended.emit(false)
		start_player_turn()
		return
	
	current_piece = enemy_pieces[current_piece_index]
	piece_turn_started.emit(current_piece)
	
	# Execute AI logic
	await _execute_ai_move(current_piece)
	
	current_piece_index += 1
	execute_next_enemy_piece()

func _execute_ai_move(piece: ChessPiece) -> void:
	"""Execute AI move for enemy piece"""
	var valid_moves = piece.get_valid_moves()
	
	if valid_moves.is_empty():
		piece_turn_ended.emit(piece)
		return
	
	# Simple AI: prioritize moves based on piece type
	var best_move = _get_best_move(piece, valid_moves)
	
	if best_move:
		piece.move_to(best_move)
		await get_tree().create_timer(0.5).timeout
	
	piece_turn_ended.emit(piece)

func _get_best_move(piece: ChessPiece, valid_moves: Array[Vector2i]) -> Vector2i:
	"""Get best move for AI piece"""
	var player_king = _find_player_king()
	
	if not player_king:
		return valid_moves[randi() % valid_moves.size()]
	
	# Prioritize moves that attack or get closer to player king
	var attacking_moves = []
	var close_moves = []
	
	for move in valid_moves:
		var target = board.get_piece_at(move)
		
		# Direct capture
		if target and target.is_player:
			attacking_moves.append(move)
		
		# Get closer to king
		var distance = move.distance_to(player_king.grid_position)
		if distance < piece.grid_position.distance_to(player_king.grid_position):
			close_moves.append(move)
	
	if not attacking_moves.is_empty():
		return attacking_moves[0]
	
	if not close_moves.is_empty():
		return close_moves[randi() % close_moves.size()]
	
	return valid_moves[randi() % valid_moves.size()]

func _find_player_king() -> ChessPiece:
	"""Find player king on board"""
	for piece in board.get_all_pieces():
		if piece.is_player and piece.piece_type == "King":
			return piece
	return null

func reset_turn_state() -> void:
	"""Reset turn state"""
	turn_count = 0
	current_piece_index = 0
	is_player_turn = true
