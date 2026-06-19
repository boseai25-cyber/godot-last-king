extends Control

class_name GameUI

@onready var willpower_label = Label.new()
@onready var ammo_label = Label.new()
@onready var turn_label = Label.new()
@onready var status_label = Label.new()
@onready var info_panel = PanelContainer.new()

var game_manager: Node
var player_king: ChessPiece

func _ready() -> void:
	_setup_ui_elements()

func initialize(gm: Node, king: ChessPiece) -> void:
	"""Initialize UI with game manager and player king"""
	game_manager = gm
	player_king = king
	
	# Connect signals
	game_manager.willpower_changed.connect(_on_willpower_changed)
	game_manager.state_changed.connect(_on_state_changed)

func _setup_ui_elements() -> void:
	"""Setup all UI elements"""
	# Willpower display
	willpower_label.name = "WillpowerLabel"
	willpower_label.text = "WILLPOWER: 100/100"
	willpower_label.add_theme_font_size_override("font_sizes/font_size", 24)
	willpower_label.add_theme_color_override("font_color", Color.WHITE)
	willpower_label.position = Vector2(20, 20)
	add_child(willpower_label)
	
	# Ammo display
	ammo_label.name = "AmmoLabel"
	ammo_label.text = "SHELLS: 3/3"
	ammo_label.add_theme_font_size_override("font_sizes/font_size", 24)
	ammo_label.add_theme_color_override("font_color", Color.YELLOW)
	ammo_label.position = Vector2(20, 60)
	add_child(ammo_label)
	
	# Turn label
	turn_label.name = "TurnLabel"
	turn_label.text = "YOUR TURN"
	turn_label.add_theme_font_size_override("font_sizes/font_size", 28)
	turn_label.add_theme_color_override("font_color", Color.WHITE)
	turn_label.position = Vector2(get_viewport().get_visible_rect().size.x / 2 - 100, 20)
	add_child(turn_label)
	
	# Status label
	status_label.name = "StatusLabel"
	status_label.text = ""
	status_label.add_theme_font_size_override("font_sizes/font_size", 20)
	status_label.position = Vector2(20, 100)
	add_child(status_label)
	
	# Info panel
	info_panel.name = "InfoPanel"
	info_panel.position = Vector2(get_viewport().get_visible_rect().size.x - 300, 20)
	info_panel.custom_minimum_size = Vector2(280, 200)
	add_child(info_panel)
	
	# Controls info
	var controls_label = Label.new()
	controls_label.text = "[Q] Shotgun  [E] Spear\n[SPACE] End Turn\n[S] Save  [L] Load"
	controls_label.add_theme_font_size_override("font_sizes/font_size", 16)
	controls_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	info_panel.add_child(controls_label)

func _on_willpower_changed(new_willpower: int) -> void:
	"""Update willpower display"""
	var color = Color.WHITE
	if new_willpower <= 25:
		color = Color.RED
	elif new_willpower <= 50:
		color = Color.ORANGE
	elif new_willpower <= 75:
		color = Color.YELLOW
	
	willpower_label.text = "WILLPOWER: %d/100" % new_willpower
	willpower_label.add_theme_color_override("font_color", color)
	
	# Update status based on phase
	match game_manager.current_phase:
		0:
			status_label.text = ""
		1:
			status_label.text = "HALLUCINATIONS: Phase 1 (Memories)"
			status_label.add_theme_color_override("font_color", Color.CYAN)
		2:
			status_label.text = "HALLUCINATIONS: Phase 2 (Intensifying)"
			status_label.add_theme_color_override("font_color", Color.MAGENTA)
		3:
			status_label.text = "HALLUCINATIONS: Phase 3 (BREAKDOWN)"
			status_label.add_theme_color_override("font_color", Color.RED)

func _on_state_changed(new_state: int) -> void:
	"""Update turn label based on game state"""
	match new_state:
		game_manager.GameState.PLAYER_TURN:
			turn_label.text = "YOUR TURN"
			turn_label.add_theme_color_override("font_color", Color.LIME)
		game_manager.GameState.ENEMY_TURN:
			turn_label.text = "ENEMY TURN"
			turn_label.add_theme_color_override("font_color", Color.RED)
		game_manager.GameState.CHECK:
			turn_label.text = "CHECK!"
			turn_label.add_theme_color_override("font_color", Color.YELLOW)
		game_manager.GameState.LAST_STAND:
			turn_label.text = "LAST STAND!!!"
			turn_label.add_theme_color_override("font_color", Color.WHITE)
		game_manager.GameState.VICTORY:
			turn_label.text = "VICTORY!"
			turn_label.add_theme_color_override("font_color", Color.LIME)
		game_manager.GameState.GAME_OVER:
			turn_label.text = "GAME OVER"
			turn_label.add_theme_color_override("font_color", Color.RED)

func update_ammo_display(current_ammo: int, max_ammo: int) -> void:
	"""Update ammunition display"""
	ammo_label.text = "SHELLS: %d/%d" % [current_ammo, max_ammo]
	
	if current_ammo == 0:
		ammo_label.add_theme_color_override("font_color", Color.RED)
	else:
		ammo_label.add_theme_color_override("font_color", Color.YELLOW)

func show_victory_screen() -> void:
	"""Show victory screen"""
	var victory_screen = Control.new()
	victory_screen.name = "VictoryScreen"
	
	var bg = ColorRect.new()
	bg.color = Color.BLACK
	bg.modulate.a = 0.7
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	victory_screen.add_child(bg)
	
	var text = Label.new()
	text.text = "VICTORY!\n\nAll enemies defeated!"
	text.add_theme_font_size_override("font_sizes/font_size", 48)
	text.add_theme_color_override("font_color", Color.LIME)
	text.anchor_left = 0.5
	text.anchor_top = 0.5
	text.offset_left = -200
	text.offset_top = -100
	victory_screen.add_child(text)
	
	add_child(victory_screen)

func show_defeat_screen() -> void:
	"""Show defeat screen"""
	var defeat_screen = Control.new()
	defeat_screen.name = "DefeatScreen"
	
	var bg = ColorRect.new()
	bg.color = Color.BLACK
	bg.modulate.a = 0.9
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	defeat_screen.add_child(bg)
	
	var text = Label.new()
	text.text = "DEFEATED\n\nYour willpower has been consumed..."
	text.add_theme_font_size_override("font_sizes/font_size", 48)
	text.add_theme_color_override("font_color", Color.RED)
	text.anchor_left = 0.5
	text.anchor_top = 0.5
	text.offset_left = -300
	text.offset_top = -100
	defeat_screen.add_child(text)
	
	add_child(defeat_screen)
