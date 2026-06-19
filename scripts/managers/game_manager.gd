extends Node3D

# Game state constants
enum GameState { PLAYER_TURN, ENEMY_TURN, CHECK, CHECKMATE, LAST_STAND, HALLUCINATION, GAME_OVER, VICTORY }
enum GamePhase { NORMAL, PHASE_1_HALLUCINATION, PHASE_2_HALLUCINATION, PHASE_3_BREAKDOWN, PHASE_4_DEATH }

# Managers
@onready var turn_manager = $TurnManager
@onready var piece_manager = $PieceManager
@onready var hallucination_manager = $HallucninationManager
@onready var audio_manager = $AudioManager
@onready var vfx_manager = $VFXManager
@onready var camera = $Camera3D
@onready var ui = $UI/HUD
@onready var board_node = $Board
@onready var pieces_node = $Pieces

# Game state
var current_state: GameState = GameState.PLAYER_TURN
var current_phase: GamePhase = GamePhase.NORMAL
var player_king: ChessPiece
var board: ChessBoard
var willpower: int = 100
var max_willpower: int = 100
var last_stand_active: bool = false
var last_stand_turns_remaining: int = 0

# Game configuration
const BOARD_SIZE = 16
const TILE_SIZE = 1.0

# Signals
signal state_changed(new_state: GameState)
signal willpower_changed(new_willpower: int)
signal phase_changed(new_phase: GamePhase)
signal victory
signal defeat

func _ready() -> void:
	# Initialize board
	board = ChessBoard.new(BOARD_SIZE)
	
	# Setup board visuals
	_setup_board_visuals()
	
	# Create and place pieces
	_initialize_pieces()
	
	# Setup camera
	_setup_camera()
	
	# Setup UI
	_setup_ui()
	
	# Start audio
	audio_manager.play_ambient_music()
	
	# Connect signals
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.turn_ended.connect(_on_turn_ended)
	
	# Begin game
	change_state(GameState.PLAYER_TURN)

func _setup_board_visuals() -> void:
	"""Create the 16x16 chessboard with ruined appearance"""
	for x in range(BOARD_SIZE):
		for z in range(BOARD_SIZE):
			var tile = MeshInstance3D.new()
			var mesh = BoxMesh.new()
			mesh.size = Vector3(TILE_SIZE, 0.1, TILE_SIZE)
			
			tile.mesh = mesh
			tile.position = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			
			# Alternate colors with damage
			var material = StandardMaterial3D.new()
			if (x + z) % 2 == 0:
				material.albedo_color = Color(0.6, 0.6, 0.6)  # Light stone
			else:
				material.albedo_color = Color(0.4, 0.4, 0.4)  # Dark stone
			
			# Add roughness and wear
			material.roughness = 0.8
			material.metallic = 0.1
			
			tile.set_surface_override_material(0, material)
			board_node.add_child(tile)

func _initialize_pieces() -> void:
	"""Create player king and enemy pieces according to chess rules"""
	
	# Create player King at d1 (center-ish of white side)
	player_king = _create_piece("King", Color.WHITE, Vector2i(7, 0), true)
	player_king.is_player = true
	
	# Create black pieces (enemy) at top of board
	# Pawns
	for x in range(8, 16):
		_create_piece("Pawn", Color.BLACK, Vector2i(x, 6), false)
	for x in range(0, 8):
		_create_piece("Pawn", Color.BLACK, Vector2i(x, 6), false)
	
	# Back row: Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook
	_create_piece("Rook", Color.BLACK, Vector2i(0, 7), false)
	_create_piece("Knight", Color.BLACK, Vector2i(1, 7), false)
	_create_piece("Bishop", Color.BLACK, Vector2i(2, 7), false)
	_create_piece("Queen", Color.BLACK, Vector2i(3, 7), false)
	_create_piece("King", Color.BLACK, Vector2i(4, 7), false)
	_create_piece("Bishop", Color.BLACK, Vector2i(5, 7), false)
	_create_piece("Knight", Color.BLACK, Vector2i(6, 7), false)
	_create_piece("Rook", Color.BLACK, Vector2i(7, 7), false)

func _create_piece(piece_type: String, color: Color, grid_pos: Vector2i, is_player: bool) -> ChessPiece:
	"""Factory method to create a chess piece"""
	var piece = ChessPiece.new()
	piece.piece_type = piece_type
	piece.color = color
	piece.grid_position = grid_pos
	piece.is_player = is_player
	piece.board = board
	
	# Create 3D visual
	var visual = _create_piece_visual(piece_type, color)
	visual.position = _grid_to_world(grid_pos)
	pieces_node.add_child(visual)
	piece.visual_node = visual
	
	# Add to board tracking
	board.place_piece(piece, grid_pos)
	piece_manager.add_piece(piece)
	
	return piece

func _create_piece_visual(piece_type: String, color: Color) -> Node3D:
	"""Create 3D visual representation of a chess piece"""
	var visual = Node3D.new()
	visual.name = piece_type
	
	# Create mesh based on piece type
	var mesh_instance = MeshInstance3D.new()
	var mesh: Mesh
	
	match piece_type:
		"Pawn":
			mesh = _create_pawn_mesh()
		"Rook":
			mesh = _create_rook_mesh()
		"Knight":
			mesh = _create_knight_mesh()
		"Bishop":
			mesh = _create_bishop_mesh()
		"Queen":
			mesh = _create_queen_mesh()
		"King":
			mesh = _create_king_mesh()
		_:
			mesh = SphereMesh.new()
	
	mesh_instance.mesh = mesh
	
	# Apply material based on color
	var material = StandardMaterial3D.new()
	if color == Color.WHITE:
		material.albedo_color = Color(0.95, 0.95, 0.95)  # Marble white
		material.metallic = 0.1
		material.roughness = 0.3
	else:
		material.albedo_color = Color(0.15, 0.15, 0.15)  # Obsidian black
		material.metallic = 0.4
		material.roughness = 0.2
	
	mesh_instance.set_surface_override_material(0, material)
	visual.add_child(mesh_instance)
	
	return visual

func _create_pawn_mesh() -> Mesh:
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.15
	mesh.height = 0.4
	return mesh

func _create_rook_mesh() -> Mesh:
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.3, 0.6, 0.3)
	return mesh

func _create_knight_mesh() -> Mesh:
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.25, 0.5, 0.4)
	return mesh

func _create_bishop_mesh() -> Mesh:
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.2
	mesh.height = 0.7
	return mesh

func _create_queen_mesh() -> Mesh:
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.22
	mesh.height = 0.8
	return mesh

func _create_king_mesh() -> Mesh:
	var mesh = CapsuleMesh.new()
	mesh.radius = 0.25
	mesh.height = 0.9
	return mesh

func _grid_to_world(grid_pos: Vector2i) -> Vector3:
	"""Convert grid coordinates to world position"""
	return Vector3(grid_pos.x * TILE_SIZE + TILE_SIZE / 2, 0.5, grid_pos.y * TILE_SIZE + TILE_SIZE / 2)

func _setup_camera() -> void:
	"""Configure isometric camera view"""
	camera.position = Vector3(8, 14, 12)
	camera.look_at(Vector3(8, 0, 8), Vector3.UP)
	camera.fov = 45.0

func _setup_ui() -> void:
	"""Initialize UI elements"""
	# Create HUD elements
	var willpower_label = Label.new()
	willpower_label.name = "WillpowerLabel"
	willpower_label.text = "Willpower: %d" % willpower
	willpower_label.add_theme_font_size_override("font_sizes/font_size", 24)
	ui.add_child(willpower_label)
	
	var ammo_label = Label.new()
	ammo_label.name = "AmmoLabel"
	ammo_label.text = "Shells: %d" % player_king.ammo
	ammo_label.add_theme_font_size_override("font_sizes/font_size", 24)
	ammo_label.position.y = 40
	ui.add_child(ammo_label)
	
	var turn_label = Label.new()
	turn_label.name = "TurnLabel"
	turn_label.text = "Your Turn"
	turn_label.add_theme_font_size_override("font_sizes/font_size", 20)
	turn_label.position.y = 80
	ui.add_child(turn_label)

func update_willpower(amount: int) -> void:
	"""Update willpower and check for hallucination triggers"""
	willpower = clamp(willpower + amount, 0, max_willpower)
	willpower_changed.emit(willpower)
	
	# Check phase transitions
	_check_hallucination_phases()
	
	# Update UI
	if ui.has_node("WillpowerLabel"):
		ui.get_node("WillpowerLabel").text = "Willpower: %d" % willpower
	
	# Check for defeat
	if willpower <= 0 and not last_stand_active:
		_trigger_game_over()

func _check_hallucination_phases() -> void:
	"""Check willpower thresholds and trigger hallucination phases"""
	var new_phase = GamePhase.NORMAL
	
	if willpower <= 25 and willpower > 0:
		new_phase = GamePhase.PHASE_3_BREAKDOWN
	elif willpower <= 50:
		new_phase = GamePhase.PHASE_2_HALLUCINATION
	elif willpower <= 75:
		new_phase = GamePhase.PHASE_1_HALLUCINATION
	
	if new_phase != current_phase:
		current_phase = new_phase
		phase_changed.emit(current_phase)
		hallucination_manager.trigger_phase(current_phase)

func change_state(new_state: GameState) -> void:
	"""Change game state and handle transitions"""
	current_state = new_state
	state_changed.emit(new_state)
	
	match new_state:
		GameState.PLAYER_TURN:
			_handle_player_turn_start()
		GameState.ENEMY_TURN:
			_handle_enemy_turn_start()
		GameState.CHECK:
			_handle_check()
		GameState.CHECKMATE:
			_handle_checkmate()
		GameState.LAST_STAND:
			_handle_last_stand()
		GameState.HALLUCINATION:
			pass
		GameState.GAME_OVER:
			_handle_game_over()
		GameState.VICTORY:
			_handle_victory()

func _handle_player_turn_start() -> void:
	"""Start player turn"""
	if ui.has_node("TurnLabel"):
		ui.get_node("TurnLabel").text = "Your Turn"

func _handle_enemy_turn_start() -> void:
	"""Start enemy turn"""
	if ui.has_node("TurnLabel"):
		ui.get_node("TurnLabel").text = "Enemy Turn"
	piece_manager.execute_enemy_turns()

func _handle_check() -> void:
	"""Handle check state"""
	audio_manager.play_sound("check")
	change_state(GameState.PLAYER_TURN)

func _handle_checkmate() -> void:
	"""Handle checkmate - activate Last Stand"""
	change_state(GameState.LAST_STAND)

func _handle_last_stand() -> void:
	"""Activate Last Stand mode"""
	last_stand_active = true
	last_stand_turns_remaining = 3
	audio_manager.play_sound("last_stand")
	vfx_manager.trigger_last_stand_effect()

func _handle_game_over() -> void:
	"""Trigger game over sequence"""
	audio_manager.play_sound("defeat")
	vfx_manager.trigger_defeat_sequence()
	defeat.emit()

func _handle_victory() -> void:
	"""Handle victory state"""
	audio_manager.play_sound("victory")
	victory.emit()

func _trigger_game_over() -> void:
	"""Trigger immediate game over"""
	change_state(GameState.GAME_OVER)

func _on_turn_started(is_player: bool) -> void:
	"""Handle turn start"""
	if is_player:
		change_state(GameState.PLAYER_TURN)
	else:
		change_state(GameState.ENEMY_TURN)

func _on_turn_ended(was_player: bool) -> void:
	"""Handle turn end"""
	if was_player:
		change_state(GameState.ENEMY_TURN)

func save_game(filename: String) -> void:
	"""Save game state"""
	var save_data = {
		"willpower": willpower,
		"player_king_pos": player_king.grid_position,
		"current_state": current_state,
		"current_phase": current_phase,
		"pieces": piece_manager.get_save_data()
	}
	
	var file = FileAccess.open(filename, FileAccess.WRITE)
	file.store_var(save_data)

func load_game(filename: String) -> void:
	"""Load game state"""
	if not FileAccess.file_exists(filename):
		return
	
	var file = FileAccess.open(filename, FileAccess.READ)
	var save_data = file.get_var()
	
	willpower = save_data["willpower"]
	willpower_changed.emit(willpower)
	piece_manager.load_save_data(save_data["pieces"])
