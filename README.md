# The Last King - Godot 4 3D Strategy Action Chess Game

A complete 3D strategy-action chess game with psychological horror elements built in Godot 4.

## 🎮 Game Overview

**The Last King** is a unique blend of turn-based chess tactics, action gameplay, and psychological horror. You control a lone White King armed with a shotgun facing an army of Black chess pieces on a 16x16 ruined board.

### Core Mechanics

- **16x16 Chessboard**: Larger battlefield with expanded tactical possibilities
- **Chess Movement**: All pieces follow standard chess rules
- **Willpower System**: Your primary resource (100 max) - depletes through attacks and stress
- **Dual Weapons**:
  - **Shotgun**: 3 shells, 3-tile range, instant kills, ammo is precious
  - **Spear**: Unlimited range 2-tile attacks, costs 5 willpower per use
- **Hallucination Phases**: As willpower drops, horrifying visions intensify

## 🎯 Game States

### Willpower Phases

| Willpower | Phase | Effects |
|-----------|-------|---------|
| 100-76 | Normal | Standard gameplay |
| 75-51 | Phase 1 | Ghost pawns, knights, bishop spawn |
| 50-26 | Phase 2 | More hallucinations, heartbeat audio, distortion |
| 25-1 | Phase 3 | King breakdown, refuses to move, visual chaos |
| 0 | Game Over | Defeat sequence |

### Special States

- **Check**: Enemy king threatens you - choose to escape or fight
- **Checkmate**: Activate "Last Stand" mode for 3 turns
- **Last Stand**: Infinite willpower & shells, converts enemies to your side
- **Victory**: Destroy or convert all enemy pieces

## 🎮 Controls

| Input | Action |
|-------|--------|
| **Left Click** | Select/move piece |
| **Q** | Shotgun attack (costs 1 shell) |
| **E** | Spear attack (costs 5 willpower) |
| **SPACE** | End turn |
| **S** | Save game |
| **L** | Load game |

## 📁 Project Structure

```
godot-last-king/
├── project.godot                 # Godot project config
├── scenes/
│   └── main.tscn                # Main game scene
├── scripts/
│   ├── managers/
│   │   ├── game_manager.gd      # Main game logic and state machine
│   │   ├── turn_manager.gd      # Turn-based system
│   │   └── piece_manager.gd     # Piece tracking and AI
│   ├── core/
│   │   ├── chess_piece.gd       # Individual piece class
│   │   └── chess_board.gd       # Board logic and state
│   ├── systems/
│   │   ├── hallucination_manager.gd  # Psychological horror system
│   │   ├── audio_manager.gd          # Sound and music
│   │   └── vfx_manager.gd            # Visual effects
│   ├── input/
│   │   └── input_handler.gd     # Player input processing
│   └── ui/
│       └── game_ui.gd           # UI display and updates
└── assets/
    └── audio/                   # Sound files
```

## 🔧 Key Systems

### Game Manager (`game_manager.gd`)
- Orchestrates all game systems
- Manages game states and transitions
- Tracks willpower and phase changes
- Handles save/load functionality

### Turn Manager (`turn_manager.gd`)
- Manages player and enemy turns
- Coordinates piece movement
- Simple AI for enemy pieces
- Priority-based move selection

### Chess Piece (`chess_piece.gd`)
- Implements all chess movement rules
- Handles weapons (shotgun/spear)
- Manages piece destruction and conversion
- Check/checkmate detection

### Hallucination Manager (`hallucination_manager.gd`)
- Spawns ghost pieces at willpower thresholds
- Phases become progressively more intense
- Controls audio and visual distortion
- Manages king breakdown mechanics

### Audio Manager (`audio_manager.gd`)
- Centralized sound effect system
- Music intensity scaling
- Heartbeat sync to stress level
- Environmental audio control

### VFX Manager (`vfx_manager.gd`)
- Particle effects for piece destruction
- Screen distortion effects
- Light effects for Last Stand
- Hallucination visual feedback

## 🎨 Visual Style

- **White Pieces**: Marble statues with smooth textures
- **Black Pieces**: Dark obsidian statues with metallic sheen
- **Board**: Cracked and ruined stone, suggests post-war aftermath
- **Camera**: Isometric 3D view, slightly tilted for dramatic effect
- **Lighting**: Dynamic system supporting hallucination visuals

## 🔊 Audio Design

- **Ambient**: Dark atmospheric background music
- **Music Intensity**: Scales with willpower level
- **Heartbeat**: Increases as stress rises
- **Voice**: Whispering, ominous tones during hallucinations
- **SFX**: Shotgun blasts, stone shattering, piece movement

## 💾 Save/Load System

Game state is saved to `user://last_king_save.dat` including:
- Willpower level
- Piece positions and states
- Game phase
- Turn count

## 🚀 Getting Started

1. **Open in Godot 4.1+**
2. **Run the project** - Main scene will load automatically
3. **Play**:
   - Move your King with mouse clicks
   - Use Q/E for attacks
   - Manage your willpower carefully
   - Defeat all enemy pieces to win

## 📋 Implementation Checklist

- [x] Core game loop and state machine
- [x] Chess piece movement (all pieces)
- [x] Turn-based system with AI
- [x] Weapon systems (shotgun/spear)
- [x] Willpower management
- [x] Hallucination system (4 phases)
- [x] Check/checkmate mechanics
- [x] Last Stand mode
- [x] Input handling
- [x] UI display
- [x] Audio system framework
- [x] VFX system framework
- [x] Save/load system
- [ ] Asset creation (models, textures, sounds)
- [ ] Shader effects for distortion
- [ ] Particle effects refinement
- [ ] Audio asset integration

## 🎓 Code Quality

- **Modular Architecture**: Each system is independent and reusable
- **Signal-Based**: Loose coupling between systems
- **Type Hints**: Full GDScript type annotations
- **Comments**: Clear documentation throughout
- **Design Patterns**: State machine, manager pattern, factory pattern

## 📚 Future Enhancements

- Multiple difficulty levels
- Enemy piece behavior variations
- Additional hallucination visuals
- Cinematic sequences
- Tutorial/story mode
- Leaderboard system
- Accessibility options

## 🤝 Contributing

This is a complete game template. Feel free to:
- Enhance AI behavior
- Add more visual/audio content
- Implement new game modes
- Optimize performance
- Port to other engines

## 📝 License

Open source - free to use and modify for personal and commercial projects.

---

**Status**: Core gameplay complete and functional. Ready for asset integration and polish.
