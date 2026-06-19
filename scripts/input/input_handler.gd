extends Node

class_name InputHandler

var game_manager: Node
var player_king: ChessPiece
var selected_piece: ChessPiece
var hovered_tile: Vector2i = Vector2i(-1, -1)

signal piece_selected(piece: ChessPiece)
signal action_requested(action_type: String, target: ChessPiece)
signal movement_requested(target_pos: Vector2i)

func _ready() -> void:
	set_process_input(true)

func initialize(gm: Node, king: ChessPiece) -> void:
	"""Initialize input handler"""
	game_manager = gm
	player_king = king

func _input(event: InputEvent) -> void:
	"""Handle input events"""
	if not game_manager or game_manager.current_state != game_manager.GameState.PLAYER_TURN:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_mouse_click(event.position)
	
	elif event is InputEventKey:
		if event.pressed:
			_handle_keyboard_input(event.keycode)
	
	get_tree().root.get_child(0).queue_redraw()

func _handle_mouse_click(mouse_pos: Vector2) -> void:
	"""Handle mouse click"""
	var camera = game_manager.camera
	var from = camera.project_ray_origin(mouse_pos)
	var normal = camera.project_ray_normal(mouse_pos)
	
	# Raycast to board
	var space_state = game_manager.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, from + normal * 1000)
	var result = space_state.intersect_ray(query)
	
	if result:
		var hit_pos = result.position
		var grid_pos = game_manager.board.world_to_grid(hit_pos)
		
		if game_manager.board.is_within_bounds(grid_pos):
			_process_tile_click(grid_pos)

func _process_tile_click(grid_pos: Vector2i) -> void:
	"""Process tile click"""
	var piece = game_manager.board.get_piece_at(grid_pos)
	
	if selected_piece:
		# Try to move to this tile
		if piece and piece == selected_piece:
			# Deselect
			selected_piece = null
		else:
			# Attempt move
			if selected_piece.move_to(grid_pos):
				game_manager.turn_manager.end_player_turn()
				selected_piece = null
			elif piece and piece.is_player:
				# Select new piece
				selected_piece = piece
				piece_selected.emit(piece)
	else:
		# Select piece
		if piece and piece.is_player:
			selected_piece = piece
			piece_selected.emit(piece)

func _handle_keyboard_input(keycode: int) -> void:
	"""Handle keyboard input"""
	match keycode:
		KEY_Q:  # Shotgun attack
			_attempt_shotgun_attack()
		KEY_E:  # Spear attack
			_attempt_spear_attack()
		KEY_SPACE:  # End turn
			game_manager.turn_manager.end_player_turn()
		KEY_S:  # Save
			game_manager.save_game("user://last_king_save.dat")
		KEY_L:  # Load
			game_manager.load_game("user://last_king_save.dat")

func _attempt_shotgun_attack() -> void:
	"""Attempt shotgun attack"""
	if not player_king or player_king.ammo <= 0:
		return
	
	# Find valid targets in range
	var valid_targets = _get_attack_targets(3)
	if not valid_targets.is_empty():
		var target = valid_targets[0]
		player_king.attack_with_shotgun(target)
		game_manager.audio_manager.play_sound("shotgun_fire")
		game_manager.vfx_manager.trigger_shotgun_muzzle_flash(player_king.visual_node.position)

func _attempt_spear_attack() -> void:
	"""Attempt spear attack"""
	if not player_king:
		return
	
	# Find valid targets in range
	var valid_targets = _get_attack_targets(2)
	if not valid_targets.is_empty():
		var target = valid_targets[0]
		if player_king.attack_with_spear(target):
			game_manager.update_willpower(-5)
			game_manager.audio_manager.play_sound("spear_attack")

func _get_attack_targets(range_limit: int) -> Array[ChessPiece]:
	"""Get valid attack targets within range"""
	var targets = Array[ChessPiece]()
	var all_pieces = game_manager.board.get_all_pieces()
	
	for piece in all_pieces:
		if not piece.is_player and not piece.is_destroyed:
			var distance = player_king.grid_position.distance_to(piece.grid_position)
			if distance <= range_limit:
				targets.append(piece)
	
	return targets

func clear_selection() -> void:
	"""Clear piece selection"""
	selected_piece = null
