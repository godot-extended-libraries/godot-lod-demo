# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends OmniLight
class_name LODOmniLight

# If `false`, LOD won't update anymore. This can be used for performance comparison
# purposes.
export var enable_lod := true

# The maximum shadow distance in units. Past this distance, the shadow will be disabled.
export(float, 0.0, 1000.0, 0.1) var shadow_max_distance := 15

# The distance factor at which the shadow starts fading.
# A value of 0.0 will result in the smoothest transition whereas a value of 1.0 disables fading.
export(float, 0.0, 1.0, 0.1) var shadow_fade_start := 0.8

# The maximum shadow distance in units. Past this distance, the light will be hidden.
export(float, 0.0, 1000.0, 0.1) var light_max_distance := 30

# The distance factor at which the light starts fading.
# A value of 0.0 will result in the smoothest transition whereas a value of 1.0 disables fading.
export(float, 0.0, 1.0, 0.1) var light_fade_start := 0.8

# The rate at which LODs will be updated (in seconds). Lower values are more reactive
# but use more CPU, which is especially noticeable with large amounts of LOD-enabled nodes.
# Set this accordingly depending on your camera movement speed.
# The default value should suit most projects already.
# Note: Slow cameras don't need to have LOD-enabled objects update their status often.
# This can overridden by setting the project setting `lod/refresh_rate`.
var refresh_rate := 0.25

# The LOD bias in units.
# Positive values will decrease the detail level and improve performance.
# Negative values will improve visual appearance at the cost of performance.
# This can overridden by setting the project setting `lod/bias`.
var lod_bias := 0.0

# The internal refresh timer.
var timer := 0.0

# The light's energy when it was instanced.
var base_light_energy := light_energy


func _ready() -> void:
	if ProjectSettings.has_setting("lod/bias"):
		lod_bias = ProjectSettings.get_setting("lod/bias")
	if ProjectSettings.has_setting("lod/refresh_rate"):
		refresh_rate = ProjectSettings.get_setting("lod/refresh_rate")

	# Add random jitter to the timer to ensure LODs don't all swap at the same time.
	randomize()
	timer += rand_range(0, refresh_rate)

# Despite LOD not being related to physics, we chose to run in `_physics_process()`
# to minimize the amount of method calls per second (and therefore decrease CPU usage).
func _physics_process(delta: float) -> void:
	if not enable_lod:
		return

	# We need a camera to do the rest.
	var camera := get_viewport().get_camera()
	if camera == null:
		return

	if timer <= refresh_rate:
		timer += delta
		return

	timer = 0.0

	var distance := camera.global_transform.origin.distance_to(global_transform.origin) + lod_bias

	# FIXME: Attenuation formulas aren't correct.
	visible = distance < light_max_distance
	# =MIN($C$1, MAX(0, $C$1 - D2/($B$1)*$C$1)/1/(1-$A$1)
	light_energy = clamp(
		distance / (light_max_distance/1.0/(1.0-light_fade_start)),
		0.0,
		1.0) * base_light_energy

	shadow_enabled = distance < shadow_max_distance
	var shadow_value := min(1, -shadow_fade_start + (distance / shadow_max_distance))
	shadow_color = Color(shadow_value, shadow_value, shadow_value)
