# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends SpotLight
class_name LODSpotLight


# The rate at which LODs will be updated (in seconds). Lower values are more reactive
# but use more CPU, which is especially noticeable with large amounts of LOD-enabled nodes.
# Set this accordingly depending on your camera movement speed.
# The default value should suit most projects already.
# Note: Slow cameras don't need to have LOD-enabled objects update their status often.
# This can overridden by setting the project setting `lod/refresh_rate`.
var refresh_rate := 0.25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if ProjectSettings.has_setting("lod/refresh_rate"):
		refresh_rate = ProjectSettings.get_setting("lod/refresh_rate")
