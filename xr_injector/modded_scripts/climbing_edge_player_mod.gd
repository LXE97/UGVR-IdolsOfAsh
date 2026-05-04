extends ClimbingEdgePlayer

var root_node : Node3D = null

func get_global_position() -> Vector3:
	if root_node != null:
		return root_node.global_position
	else:
		return Vector3.ZERO

func set_root(target: Node3D):
	root_node = target
