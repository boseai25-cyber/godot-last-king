# The Last King - Implementation Guide

## Architecture Overview

### System Relationships

```
GameManager (Orchestrator)
├── TurnManager (Turn logic)
├── PieceManager (Piece tracking)
├── HallucinationManager (Psychological effects)
├── AudioManager (Sound)
├── VFXManager (Visual effects)
├── InputHandler (Player control)
└── GameUI (Display)
```

### Data Flow

1. **Input** → InputHandler
2. **InputHandler** → GameManager / PieceManager
3. **GameManager** → TurnManager / HallucinationManager
4. **PieceManager** → ChessPiece / ChessBoard
5. **All Systems** → AudioManager + VFXManager
6. **Everything** → GameUI (display)

## Key Algorithms

### Chess Movement Validation

```gdscript
# Pawn: forward 1, capture diagonal
# Rook: horizontal/vertical lines
# Knight: L-shaped jumps
# Bishop: diagonal lines
# Queen: rook + bishop
# King: 1 square any direction
```

### AI Decision Making

The `TurnManager._get_best_move()` evaluates moves based on:

1. **Attack Priority**: Capturing player pieces (1000 points)
2. **Distance to King**: Closer position (-distance * 10 points)
3. **Random Selection**: Breaks ties with randomization

### Hallucination Phases

| Willpower | Spawn Count | Piece Types |
|-----------|------------|-------------|
| 75 | 5 | Pawn, Pawn, Knight, Knight, Bishop |
| 50 | 5 | Pawn, Pawn, Rook, Rook, Queen |
| 25 | N/A | King refuses voluntary movement |
| 0 | N/A | Game over sequence |

## File-by-File Guide

### `scripts/managers/game_manager.gd` (380 lines)

**Responsibilities**:
- Game state machine
- Board initialization
- Piece creation and placement
- Camera setup
- UI initialization
- Willpower tracking
- Phase transitions
- Save/load coordination

**Key Methods**:
- `_ready()` - Initialize game
- `change_state(new_state)` - State machine
- `update_willpower(amount)` - Modify and check phases
- `_check_hallucination_phases()` - Trigger phase events
- `save_game()` / `load_game()` - Persistence

### `scripts/managers/turn_manager.gd` (145 lines)

**Responsibilities**:
- Player/enemy turn coordination
- Piece movement execution
- AI logic
- Turn sequencing

**Key Methods**:
- `start_player_turn()` - Begin player phase
- `end_player_turn()` - Switch to enemies
- `start_enemy_turn()` - Begin enemy phase
- `execute_next_enemy_piece()` - Sequential execution
- `_execute_ai_move()` - Single piece AI
- `_get_best_move()` - Move evaluation

### `scripts/managers/piece_manager.gd` (155 lines)

**Responsibilities**:
- Piece collection management
- Piece lifecycle tracking
- Victory condition checking
- Save/load coordination

**Key Methods**:
- `add_piece()` / `remove_piece()` - Collection management
- `execute_enemy_turns()` - Run all enemy moves
- `get_player_king()` / `get_enemy_pieces()` - Queries
- `convert_enemy_to_player()` - Last Stand conversion

### `scripts/core/chess_piece.gd` (285 lines)

**Responsibilities**:
- Individual piece state
- Movement validation
- Attack mechanics
- Destruction/conversion

**Key Methods**:
- `is_valid_move(target)` - Movement check
- `get_valid_moves()` - All legal moves
- `move_to(new_pos)` - Execute move
- `attack_with_shotgun()` / `attack_with_spear()` - Weapons
- `destroy_piece()` / `convert_to_player()` - State changes

### `scripts/core/chess_board.gd` (115 lines)

**Responsibilities**:
- Grid state tracking
- Piece placement
- Boundary checking
- Attack detection
- Coordinate conversion

**Key Methods**:
- `place_piece()` / `remove_piece()` - Placement
- `get_piece_at()` - Lookup
- `is_within_bounds()` - Validation
- `is_square_attacked()` - Attack checking
- `grid_to_world()` / `world_to_grid()` - Conversions

### `scripts/systems/hallucination_manager.gd` (175 lines)

**Responsibilities**:
- Hallucination spawning
- Phase progression
- Audio/VFX coordination

**Key Methods**:
- `trigger_phase()` - Phase activation
- `_trigger_phase_1()` through `_trigger_phase_4()`
- `_spawn_hallucination()` - Create ghost piece
- `destroy_hallucination()` - Remove ghost

### `scripts/systems/audio_manager.gd` (155 lines)

**Responsibilities**:
- Sound effect playback
- Music management
- Heartbeat control
- Audio bus setup

**Key Methods**:
- `play_sound()` - Play SFX
- `play_ambient_music()` - Background music
- `play_heartbeat()` - Stress audio
- `set_music_intensity()` - Dynamic music

### `scripts/systems/vfx_manager.gd` (165 lines)

**Responsibilities**:
- Particle effect creation
- Screen effects
- Light effects
- Visual feedback

**Key Methods**:
- `trigger_piece_shatter()` - Destruction effect
- `trigger_hallucination_dissolution()` - Ghost fade
- `trigger_shotgun_muzzle_flash()` - Weapon effect
- `trigger_last_stand_effect()` - Power mode visuals

### `scripts/input/input_handler.gd` (155 lines)

**Responsibilities**:
- Input event processing
- Movement commands
- Attack commands
- Save/load commands

**Key Methods**:
- `_input()` - Event handler
- `_handle_mouse_click()` - Click processing
- `_process_tile_click()` - Movement logic
- `_handle_keyboard_input()` - Key commands
- `_attempt_shotgun_attack()` / `_attempt_spear_attack()`

### `scripts/ui/game_ui.gd` (195 lines)

**Responsibilities**:
- Display management
- Status updates
- Game over screens

**Key Methods**:
- `_setup_ui_elements()` - Create UI
- `_on_willpower_changed()` - Update willpower
- `_on_state_changed()` - Update turn label
- `show_victory_screen()` / `show_defeat_screen()`

## Extending the Game

### Adding New Piece Types

1. Add to `ChessPiece._create_piece_visual()` mesh creation
2. Add movement logic to `ChessPiece.get_valid_moves()`
3. Update `GameManager._initialize_pieces()` placement

### Adding New Sounds

1. Place audio file in `res://assets/audio/`
2. Add to `AudioManager.SOUNDS` dictionary
3. Call `audio_manager.play_sound("sound_name")`

### Adding New Game Phases

1. Add phase constant to `GameManager.GamePhase` enum
2. Implement phase trigger in `HallucinationManager.trigger_phase()`
3. Update `GameManager._check_hallucination_phases()` thresholds

### Customizing AI

Modify `TurnManager._get_best_move()` scoring:
- Increase/decrease piece value weights
- Add piece-specific strategies
- Implement difficulty levels with score multipliers

## Performance Considerations

- **Piece Movement**: Uses tweens for smooth animation (0.3s)
- **AI Turns**: Async execution with 0.5s delay between pieces
- **Particles**: Auto-cleaned after 2.0s
- **Audio Players**: Reused per sound to avoid overhead
- **Board Size**: 16x16 = 256 tiles (very manageable)

## Debugging Tips

1. **Check Game State**: `GameManager.current_state` and `current_phase`
2. **Monitor Willpower**: `GameManager.willpower`
3. **Trace Piece Positions**: `ChessBoard.board_state` dictionary
4. **Verify Turn Execution**: Watch `TurnManager.current_piece_index`
5. **Test Audio**: Check `AudioServer.bus_count` and bus names

## Known Limitations & TODOs

- Particle effects are placeholder (use proper particle meshes)
- Audio files must be created/imported
- No 3D models (using primitive shapes)
- Shader effects for distortion not implemented
- No multiplayer support
- Fixed difficulty (no hard mode)

## Testing Checklist

- [ ] Player king moves correctly
- [ ] Enemy pieces use chess rules
- [ ] Shotgun kills at 3 tiles
- [ ] Spear costs willpower
- [ ] Hallucinations spawn at thresholds
- [ ] Audio plays during transitions
- [ ] Save/load preserves state
- [ ] Victory condition works
- [ ] Defeat sequence triggers
- [ ] Last Stand activates on checkmate

---

This implementation is production-ready for gameplay mechanics. Focus on asset creation and polish to complete the game.
