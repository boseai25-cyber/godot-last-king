extends RefCounted
class_name ChessPiece

# Piece types
enum PieceType { PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING }

# Properties
var piece_type: String
var color: Color
var grid_position: Vector2i
var is_player: bool = false
var is_hallucination: bool = false
var is_destroyed: bool = false
var health: int = 1
var visual_node: Node3D
var board: ChessBoard

# Weapons
var ammo: int = 3
var max_ammo: int = 3
var has_spear: bool = true

# State
var can_move: bool = true
var has_moved_this_turn: bool = false

# Signals
signal position_changed(new_pos: Vector2i)
signal destroyed
signal piece_converted

func _init() -> void:
	pass

func move_to(new_pos: Vector2i) -> bool:
	"""Attempt to move piece to new position"""
	if not can_move or not is_valid_move(new_pos):
		return false
	
	var old_pos = grid_position
	grid_position = new_pos
	position_changed.emit(new_pos)
	has_moved_this_turn = true
	
	# Update visual position
	if visual_node:
		var world_pos = board.grid_to_world(new_pos)
		var tween = create_tween()
		tween.tween_property(visual_node, "position", world_pos, 0.3)
	
	return true

func is_valid_move(target_pos: Vector2i) -> bool:
	"""Check if move is valid according to chess rules"""
	# Out of bounds check
	if not board.is_within_bounds(target_pos):
		return false
	
	# Check for friendly fire
	var target_piece = board.get_piece_at(target_pos)
	if target_piece and target_piece.color == self.color:
		return false
	
	# Get valid moves based on piece type
	var valid_moves = get_valid_moves()
	return target_pos in valid_moves

func get_valid_moves() -> Array[Vector2i]:
	"""Get all valid moves for this piece"""
	var valid = Array[Vector2i]()
	
	match piece_type:
		"Pawn":
			valid = _get_pawn_moves()
		"Rook":
			valid = _get_rook_moves()
		"Knight":
			valid = _get_knight_moves()
		"Bishop":
			valid = _get_bishop_moves()
		"Queen":
			valid = _get_queen_moves()
		"King":
			valid = _get_king_moves()
	
	return valid

func _get_pawn_moves() -> Array[Vector2i]:
	"""Pawn moves forward one square, captures diagonally"""
	var valid = Array[Vector2i]()
	var direction = -1 if color == Color.BLACK else 1
	
	# Forward move
	var forward = grid_position + Vector2i(0, direction)
	if board.is_within_bounds(forward) and not board.get_piece_at(forward):
		valid.append(forward)
	
	# Captures
	for dx in [-1, 1]:
		var capture = grid_position + Vector2i(dx, direction)
		if board.is_within_bounds(capture):
			var target = board.get_piece_at(capture)
			if target and target.color != self.color:
				valid.append(capture)
	
	return valid

func _get_rook_moves() -> Array[Vector2i]:
	"""Rook moves horizontally or vertically"""
	var valid = Array[Vector2i]()
	
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		for distance in range(1, board.size):
			var target_pos = grid_position + direction * distance
			if not board.is_within_bounds(target_pos):
				break
			
			var target = board.get_piece_at(target_pos)
			if target:
				if target.color != self.color:
					valid.append(target_pos)
				break
			
			valid.append(target_pos)
	
	return valid

func _get_knight_moves() -> Array[Vector2i]:
	"""Knight moves in L-shape"""
	var valid = Array[Vector2i]()
	var knight_moves = [
		Vector2i(2, 1), Vector2i(2, -1), Vector2i(-2, 1), Vector2i(-2, -1),
		Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, 2), Vector2i(-1, -2)
	]
	
	for move in knight_moves:
		var target_pos = grid_position + move
		if board.is_within_bounds(target_pos):
			var target = board.get_piece_at(target_pos)
			if not target or target.color != self.color:
				valid.append(target_pos)
	
	return valid

func _get_bishop_moves() -> Array[Vector2i]:
	"""Bishop moves diagonally"""
	var valid = Array[Vector2i]()
	
	for direction in [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]:
		for distance in range(1, board.size):
			var target_pos = grid_position + direction * distance
			if not board.is_within_bounds(target_pos):
				break
			
			var target = board.get_piece_at(target_pos)
			if target:
				if target.color != self.color:
					valid.append(target_pos)
				break
			
			valid.append(target_pos)
	
	return valid

func _get_queen_moves() -> Array[Vector2i]:
	"""Queen moves like rook + bishop"""
	var valid = Array[Vector2i]()
	valid.append_array(_get_rook_moves())
	valid.append_array(_get_bishop_moves())
	return valid

func _get_king_moves() -> Array[Vector2i]:
	"""King moves one square in any direction"""
	var valid = Array[Vector2i]()
	
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			
			var target_pos = grid_position + Vector2i(dx, dy)
			if board.is_within_bounds(target_pos):
				var target = board.get_piece_at(target_pos)
				if not target or target.color != self.color:
					valid.append(target_pos)
	
	return valid

func attack_with_shotgun(target: ChessPiece) -> bool:
	"""Attack with shotgun"""
	if ammo <= 0:
		return false
	
	var distance = grid_position.distance_to(target.grid_position)
	if distance > 3:
		return false
	
	ammo -= 1
	destroy_piece(target)
	
	return true

func attack_with_spear(target: ChessPiece) -> bool:
	"""Attack with spear (costs 5 willpower)"""
	if not has_spear:
		return false
	
	var distance = grid_position.distance_to(target.grid_position)
	if distance > 2:
		return false
	
	destroy_piece(target)
	return true

func destroy_piece(piece: ChessPiece) -> void:
	"""Destroy a piece"""
	piece.is_destroyed = true
	piece.destroyed.emit()
	board.remove_piece(piece.grid_position)
	
	if piece.visual_node:
		if piece.is_hallucination:
			# Dissolve hallucination into vapor
			var tween = create_tween()
			tween.tween_property(piece.visual_node, "modulate:a", 0.0, 0.5)
			tween.tween_callback(func(): piece.visual_node.queue_free())
		else:
			# Shatter real piece
			pass  # VFX handled by VFXManager

func convert_to_player() -> void:
	"""Convert enemy piece to player side"""
	color = Color.WHITE
	piece_converted.emit()

func is_in_check() -> bool:
	"""Determine if king is in check"""
	if piece_type != "King":
		return false
	
	# Check all enemy pieces
	for piece in board.get_all_pieces():
		if piece.color != self.color and piece.can_attack(self.grid_position):
			return true
	
	return false

func can_attack(target_pos: Vector2i) -> bool:
	"""Check if piece can attack position"""
	var valid_moves = get_valid_moves()
	return target_pos in valid_moves

func get_save_data() -> Dictionary:
	"""Get saveable data"""
	return {
		"piece_type": piece_type,
		"color": color,
		"grid_position": grid_position,
		"is_hallucination": is_hallucination,
		"ammo": ammo
	}

func load_from_data(data: Dictionary) -> void:
	"""Load from save data"""
	piece_type = data["piece_type"]
	color = data["color"]
	grid_position = data["grid_position"]
	is_hallucination = data["is_hallucination"]
	ammo = data["ammo"]
