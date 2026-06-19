extends Node3D

class_name VFXManager

var particle_systems: Dictionary = {}
var active_effects: Array[Node3D] = []

func _ready() -> void:
	pass

func trigger_piece_shatter(position: Vector3, piece_type: String) -> void:
	"""Create particle effect for shattering piece"""
	var particles = GPUParticles3D.new()
	particles.position = position
	particles.emitting = true
	
	# Configure particles based on piece type
	_configure_shatter_particles(particles, piece_type)
	
	add_child(particles)
	active_effects.append(particles)
	
	# Remove after effect completes
	await get_tree().create_timer(2.0).timeout
	particles.queue_free()
	active_effects.erase(particles)

func _configure_shatter_particles(particles: GPUParticles3D, piece_type: String) -> void:
	"""Configure particle system for shatter effect"""
	particles.amount = 50
	particles.lifetime = 1.5
	particles.speed_scale = 1.2

func trigger_hallucination_dissolution(piece: ChessPiece) -> void:
	"""Create vapor/dissolution effect for hallucination"""
	var particles = GPUParticles3D.new()
	particles.position = piece.visual_node.global_position
	particles.emitting = true
	
	particles.amount = 30
	particles.lifetime = 2.0
	particles.speed_scale = 0.8
	
	add_child(particles)
	active_effects.append(particles)
	
	await get_tree().create_timer(2.0).timeout
	particles.queue_free()
	active_effects.erase(particles)

func trigger_shotgun_muzzle_flash(position: Vector3) -> void:
	"""Create shotgun muzzle flash"""
	var flash = OmniLight3D.new()
	flash.position = position
	flash.light_energy_multiplier = 1.5
	flash.omni_range = 5.0
	flash.light_color = Color.YELLOW
	
	add_child(flash)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(flash, "light_energy_multiplier", 0.0, 0.1)
	await tween.finished
	flash.queue_free()

func trigger_last_stand_effect() -> void:
	"""Create Last Stand visual effect - white flames and aura"""
	var aura = OmniLight3D.new()
	aura.light_color = Color.WHITE
	aura.light_energy_multiplier = 2.0
	aura.omni_range = 10.0
	
	add_child(aura)
	active_effects.append(aura)
	
	# Pulsing effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(aura, "light_energy_multiplier", 3.0, 0.5)
	tween.tween_property(aura, "light_energy_multiplier", 1.5, 0.5)

func trigger_defeat_sequence() -> void:
	"""Trigger visual sequence for defeat"""
	# Create dark overlay
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.modulate.a = 0.0
	
	add_child(overlay)
	
	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 3.0)
	await tween.finished
	overlay.queue_free()

func trigger_hallucination_cinematic() -> void:
	"""Trigger cinematic hallucination event"""
	var vignette = ColorRect.new()
	vignette.color = Color(0.3, 0.0, 0.3, 0.0)
	vignette.anchor_right = 1.0
	vignette.anchor_bottom = 1.0
	
	add_child(vignette)
	
	var tween = create_tween()
	tween.tween_property(vignette, "color:a", 0.5, 0.5)
	tween.tween_property(vignette, "color:a", 0.0, 0.5)
	await tween.finished
	vignette.queue_free()

func trigger_screen_distortion(intensity: float) -> void:
	"""Trigger screen distortion effect"""
	var distortion_time = 1.0
	var tween = create_tween()
	# Implementation depends on custom shader
	tween.tween_callback(func(): pass)

func trigger_heavy_distortion() -> void:
	"""Trigger heavy visual distortion for Phase 3"""
	var distortion_time = 2.0
	var tween = create_tween()
	# More intense distortion effect

func trigger_conversion_effect(piece: ChessPiece) -> void:
	"""Create effect when piece converts to player"""
	var glow = OmniLight3D.new()
	glow.position = piece.visual_node.global_position
	glow.light_color = Color.WHITE
	glow.light_energy_multiplier = 2.0
	glow.omni_range = 3.0
	
	add_child(glow)
	
	var tween = create_tween()
	tween.tween_property(glow, "light_energy_multiplier", 0.0, 0.5)
	await tween.finished
	glow.queue_free()

func trigger_check_effect() -> void:
	"""Create effect for check status"""
	var warning = ColorRect.new()
	warning.color = Color.RED
	warning.anchor_right = 1.0
	warning.anchor_bottom = 1.0
	warning.modulate.a = 0.0
	
	add_child(warning)
	
	var tween = create_tween()
	tween.tween_property(warning, "modulate:a", 0.1, 0.2)
	tween.tween_property(warning, "modulate:a", 0.0, 0.2)
	
	# Flash multiple times
	for i in range(3):
		tween.tween_property(warning, "modulate:a", 0.15, 0.15)
		tween.tween_property(warning, "modulate:a", 0.0, 0.15)
	
	await tween.finished
	warning.queue_free()

func clear_all_effects() -> void:
	"""Clear all active effects"""
	for effect in active_effects:
		if is_instance_valid(effect):
			effect.queue_free()
	active_effects.clear()
