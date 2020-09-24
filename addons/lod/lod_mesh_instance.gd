# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends Spatial
class_name LODMeshInstance

# The rate at which LODs will be updated (in seconds). Lower values are more reactive
# but use more CPU, which is especially noticeable with large amounts of LOD-enabled
# meshes.
# Set this accordingly depending on your camera movement speed. Slow cameras
# don't need to have LOD-enabled objects update their status often.
const REFRESH_RATE = 0.25

export(float, 0.0, 1000.0, 0.1) var lod_0_max_distance := 10
export(float, 0.0, 1000.0, 0.1) var lod_1_max_distance := 25
export(float, 0.0, 1000.0, 0.1) var lod_2_max_distance := 38

var timer := 0.0


func _ready() -> void:
	# Add random jitter to the timer to ensure meshes don't all swap at the same time.
	randomize()
	timer += rand_range(0, REFRESH_RATE)


# Despite LOD not being related to physics, we chose to run in `_physics_process()`
# to minimize the amount of method calls per second (and therefore decrease CPU usage).
func _physics_process(delta: float) -> void:
	# We need a camera to do the rest.
	var camera := get_viewport().get_camera()
	if camera == null:
		return

	if timer <= REFRESH_RATE:
		timer += delta
		return

	timer = 0.0

	var distance := camera.global_transform.origin.distance_to(global_transform.origin)
	# The LOD level to choose (lower is more detailed).
	var lod: int
	if distance < lod_0_max_distance:
		lod = 0
	elif distance < lod_1_max_distance:
		lod = 1
	elif distance < lod_2_max_distance:
		lod = 2
	else:
		# Hide the LOD object entirely.
		lod = 3

	for node in get_children():
		# `-lod` also matches `-lod0`, `-lod1`, `-lod2`, …
		if node.has_method("set_visible"):
			if "-lod0" in node.name:
				node.visible = lod == 0
			if "-lod1" in node.name:
				node.visible = lod == 1
			if "-lod2" in node.name:
				node.visible = lod == 2
