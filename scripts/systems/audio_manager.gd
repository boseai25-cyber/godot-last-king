extends Node

class_name AudioManager

var audio_players: Dictionary = {}
var ambient_player: AudioStreamPlayer
var heartbeat_player: AudioStreamPlayer
var current_music: AudioStreamPlayer

const SOUNDS = {
	"check": preload("res://assets/audio/check.ogg"),
	"last_stand": preload("res://assets/audio/last_stand.ogg"),
	"defeat": preload("res://assets/audio/defeat.ogg"),
	"victory": preload("res://assets/audio/victory.ogg"),
	"hallucination_phase_1": preload("res://assets/audio/hallucination_phase_1.ogg"),
	"hallucination_phase_2": preload("res://assets/audio/hallucination_phase_2.ogg"),
	"hallucination_attack": preload("res://assets/audio/hallucination_attack.ogg"),
	"piece_shatter": preload("res://assets/audio/piece_shatter.ogg"),
	"piece_move": preload("res://assets/audio/piece_move.ogg"),
	"shotgun_fire": preload("res://assets/audio/shotgun_fire.ogg"),
	"spear_attack": preload("res://assets/audio/spear_attack.ogg"),
	"whispering_voices": preload("res://assets/audio/whispering_voices.ogg"),
	"defeat_sequence": preload("res://assets/audio/defeat_sequence.ogg"),
}

func _ready() -> void:
	# Create audio players
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master"
	add_child(ambient_player)
	
	heartbeat_player = AudioStreamPlayer.new()
	heartbeat_player.bus = "Master"
	add_child(heartbeat_player)
	
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Music"
	add_child(current_music)

func play_sound(sound_name: String, volume_db: float = 0.0) -> void:
	"""Play a sound effect"""
	if sound_name not in SOUNDS:
		push_error("Sound not found: " + sound_name)
		return
	
	# Create new player or reuse
	if sound_name not in audio_players:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		audio_players[sound_name] = player
	
	var player = audio_players[sound_name]
	player.stream = SOUNDS[sound_name]
	player.volume_db = volume_db
	player.play()

func play_ambient_music() -> void:
	"""Play ambient background music"""
	current_music.stream = preload("res://assets/audio/ambient_music.ogg")
	current_music.volume_db = -5.0
	current_music.bus = "Music"
	current_music.play()

func play_heartbeat(speed: float = 1.0) -> void:
	"""Play heartbeat sound at given speed"""
	heartbeat_player.stream = preload("res://assets/audio/heartbeat.ogg")
	heartbeat_player.pitch_scale = speed
	heartbeat_player.play()

func stop_heartbeat() -> void:
	"""Stop heartbeat sound"""
	heartbeat_player.stop()

func set_music_intensity(intensity: float) -> void:
	"""Set music intensity (0-1)"""
	# Crossfade between different music tracks based on intensity
	var target_volume = lerp(-40.0, 0.0, intensity)
	var tween = create_tween()
	tween.tween_property(current_music, "volume_db", target_volume, 1.0)

func create_audio_bus_layout() -> void:
	"""Create audio bus layout"""
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus == -1:
		AudioServer.add_bus(0)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Master")
	
	# Create sub-buses
	var master_idx = AudioServer.get_bus_index("Master")
	
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(master_idx)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
	
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(master_idx)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
	
	if AudioServer.get_bus_index("Ambience") == -1:
		AudioServer.add_bus(master_idx)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Ambience")

func play_last_stand_music() -> void:
	"""Play intense Last Stand music"""
	current_music.stream = preload("res://assets/audio/last_stand_music.ogg")
	current_music.volume_db = 0.0
	current_music.pitch_scale = 1.2
	current_music.play()

func reset_audio() -> void:
	"""Reset all audio"""
	stop_heartbeat()
	for player in audio_players.values():
		player.stop()
	current_music.stop()
