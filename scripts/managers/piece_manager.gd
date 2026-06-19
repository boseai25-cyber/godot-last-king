extends Node

class_name PieceManager

var pieces: Array[ChessPiece] = []
var player_king: ChessPiece

signal piece_destroyed(piece: ChessPiece)
signal piece_converted(piece: ChessPiece)

func _ready() -> void:
	pass

func add_piece(piece: ChessPiece) -> void:
	"""Add piece to manager"""
	pieces.append(piece)
	piece.destroyed.connect(_on_piece_destroyed)
	piece.piece_converted.connect(_on_piece_converted)

func remove_piece(piece: ChessPiece) -> void:
	"""Remove piece from manager"""
	pieces.erase(piece)

func get_player_king() -> ChessPiece:
	"""Get player king"""
	for piece in pieces:
		if piece.is_player and piece.piece_type == "King":
			return piece
	return null

func get_enemy_pieces() -> Array[ChessPiece]:
	"""Get all enemy pieces"""
	var enemy_pieces = []
	for piece in pieces:
		if not piece.is_player and not piece.is_destroyed:
			enemy_pieces.append(piece)
	return enemy_pieces

func get_hallucination_pieces() -> Array[ChessPiece]:
	"""Get all hallucination pieces"""
	var hallucinations = []
	for piece in pieces:
		if piece.is_hallucination and not piece.is_destroyed:
			hallucinations.append(piece)
	return hallucinations

func get_all_alive_pieces() -> Array[ChessPiece]:
	"""Get all non-destroyed pieces"""
	var alive = []
	for piece in pieces:
		if not piece.is_destroyed:
			alive.append(piece)
	return alive

func execute_enemy_turns() -> void:
	"""Execute all enemy piece turns"""
	var enemy_pieces = get_enemy_pieces()
	
	for piece in enemy_pieces:
		if piece.is_destroyed:
			continue
		
		var valid_moves = piece.get_valid_moves()
		if valid_moves.is_empty():
			continue
		
		var best_move = _get_ai_best_move(piece, valid_moves)
		piece.move_to(best_move)
		await get_tree().create_timer(0.3).timeout

func _get_ai_best_move(piece: ChessPiece, valid_moves: Array[Vector2i]) -> Vector2i:
	"""Calculate best move for enemy piece"""
	if valid_moves.is_empty():
		return piece.grid_position
	
	var player_king = get_player_king()
	if not player_king:
		return valid_moves[randi() % valid_moves.size()]
	
	var best_move = valid_moves[0]
	var best_score = -1000
	
	for move in valid_moves:
		var score = 0
		
		# Distance to player king
		var distance = move.distance_to(player_king.grid_position)
		score -= distance * 10  # Negative because closer is better
		
		# Check if move captures something
		var target = piece.board.get_piece_at(move)
		if target and not target.is_player:
			score += 50
		
		if target and target.is_player:
			score += 1000  # High priority for attacking player
		
		if score > best_score:
			best_score = score
			best_move = move
	
	return best_move

func _on_piece_destroyed(piece: ChessPiece) -> void:
	"""Handle piece destruction"""
	piece_destroyed.emit(piece)
	
	# Check victory condition
	if piece.color == Color.BLACK and not piece.is_hallucination:
		if get_enemy_pieces().is_empty():
			get_tree().get_first_child_in_group("GameManager").change_state(GameManager.GameState.VICTORY)

func _on_piece_converted(piece: ChessPiece) -> void:
	"""Handle piece conversion"""
	piece_converted.emit(piece)

func get_save_data() -> Array:
	"""Get saveable piece data"""
	var data = []
	for piece in pieces:
		if not piece.is_destroyed:
			data.append(piece.get_save_data())
	return data

func load_save_data(data: Array) -> void:
	"""Load piece data"""
	pieces.clear()
	for piece_data in data:
		var piece = ChessPiece.new()
		piece.load_from_data(piece_data)
		add_piece(piece)

func convert_enemy_to_player(piece: ChessPiece) -> void:
	"""Convert enemy piece to player side"""
	if piece.color == Color.BLACK:
		piece.convert_to_player()
