extends Node

class_name HallucinationManager

# Hallucination pieces
var hallucination_pieces: Array[ChessPiece] = []
var phase_active: int = 0

# References
var game_manager: Node
var piece_manager: PieceManager
var audio_manager: Node
var vfx_manager: Node

# Phase data
var phase_1_active = false
var phase_2_active = false
var phase_3_active = false

signal hallucination_spawned(piece: ChessPiece)
signal hallucination_destroyed(piece: ChessPiece)

func _ready() -> void:
	pass

func initialize(gm: Node, pm: PieceManager, am: Node, vm: Node) -> void:
	"""Initialize hallucination manager"""
	game_manager = gm
	piece_manager = pm
	audio_manager = am
	vfx_manager = vm

func trigger_phase(phase: int) -> void:
	"""Trigger hallucination phase"""
	phase_active = phase
	
	match phase:
		0:  # NORMAL
			clear_hallucinations()
		1:  # PHASE_1_HALLUCINATION
			_trigger_phase_1()
		2:  # PHASE_2_HALLUCINATION
			_trigger_phase_2()
		3:  # PHASE_3_BREAKDOWN
			_trigger_phase_3()
		4:  # PHASE_4_DEATH
			_trigger_phase_4()

func _trigger_phase_1() -> void:
	"""Trigger Phase 1 - 75 Willpower"""
	if phase_1_active:
		return
	
	phase_1_active = true
	audio_manager.play_sound("hallucination_phase_1")
	vfx_manager.trigger_hallucination_cinematic()
	
	# Spawn hallucination pieces
	_spawn_hallucination("Pawn", Vector2i(3, 3))
	_spawn_hallucination("Pawn", Vector2i(4, 3))
	_spawn_hallucination("Knight", Vector2i(2, 2))
	_spawn_hallucination("Knight", Vector2i(5, 2))
	_spawn_hallucination("Bishop", Vector2i(3, 4))

func _trigger_phase_2() -> void:
	"""Trigger Phase 2 - 50 Willpower"""
	if phase_2_active:
		return
	
	phase_2_active = true
	
	# Remove phase 1 hallucinations
	clear_hallucinations()
	
	audio_manager.play_sound("hallucination_phase_2")
	audio_manager.play_heartbeat(1.5)
	vfx_manager.trigger_screen_distortion(0.5)
	
	# Spawn phase 2 hallucinations
	_spawn_hallucination("Pawn", Vector2i(3, 2))
	_spawn_hallucination("Pawn", Vector2i(4, 2))
	_spawn_hallucination("Rook", Vector2i(1, 4))
	_spawn_hallucination("Rook", Vector2i(6, 4))
	_spawn_hallucination("Queen", Vector2i(3, 5))

func _trigger_phase_3() -> void:
	"""Trigger Phase 3 - 25 Willpower (King breakdown)"""
	if phase_3_active:
		return
	
	phase_3_active = true
	
	audio_manager.play_heartbeat(2.0)
	audio_manager.play_sound("whispering_voices")
	vfx_manager.trigger_heavy_distortion()
	
	# Make king refuse to move voluntarily
	var player_king = piece_manager.get_player_king()
	if player_king:
		player_king.can_move = false

func _trigger_phase_4() -> void:
	"""Trigger Phase 4 - 0 Willpower (Game Over)"""
	audio_manager.play_sound("defeat_sequence")
	vfx_manager.trigger_defeat_sequence()

func _spawn_hallucination(piece_type: String, grid_pos: Vector2i) -> void:
	"""Spawn a hallucination piece"""
	var piece = ChessPiece.new()
	piece.piece_type = piece_type
	piece.color = Color.BLACK
	piece.grid_position = grid_pos
	piece.is_hallucination = true
	piece.is_player = false
	
	hallucination_pieces.append(piece)
	piece_manager.add_piece(piece)
	hallucination_spawned.emit(piece)

func clear_hallucinations() -> void:
	"""Destroy all hallucination pieces"""
	for piece in hallucination_pieces:
		if not piece.is_destroyed:
			piece.is_destroyed = true
			hallucination_destroyed.emit(piece)
	
	hallucination_pieces.clear()

func hallucination_attack(piece: ChessPiece, target: ChessPiece) -> void:
	"""Handle hallucination attack"""
	if piece.is_hallucination:
		# Reduce willpower by 1
		game_manager.update_willpower(-1)
		audio_manager.play_sound("hallucination_attack")

func destroy_hallucination(piece: ChessPiece) -> void:
	"""Destroy hallucination piece"""
	if piece.is_hallucination:
		piece.is_destroyed = true
		vfx_manager.trigger_hallucination_dissolution(piece)
		hallucination_destroyed.emit(piece)
		hallucination_pieces.erase(piece)

func get_active_hallucinations() -> Array[ChessPiece]:
	"""Get all active hallucination pieces"""
	var active = []
	for piece in hallucination_pieces:
		if not piece.is_destroyed:
			active.append(piece)
	return active

func reset() -> void:
	"""Reset hallucination system"""
	clear_hallucinations()
	phase_1_active = false
	phase_2_active = false
	phase_3_active = false
	phase_active = 0
