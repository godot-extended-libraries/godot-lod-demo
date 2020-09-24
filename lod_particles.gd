# Copyright © 2020 Hugo Locurcio and contributors - MIT License
# See `LICENSE.md` included in the source distribution for details.
extends LODParticles


func _ready() -> void:
	# Don't show particles in the editor to avoid saturating the CPU/GPU.
	visible = true
