extends ClimbingEdgePlayer

var hand : Node = null
var root_node : Node = null

const offset = Vector3(0.0, -0.055, 0.117)
var scale = 1.0

func get_global_position() -> Vector3:
	if root_node != null:
		return root_node.global_transform * Transform3D(Basis.IDENTITY, offset * scale).origin
	else:
		return Vector3.ZERO

func set_root(target: Node, use_physics: bool):
	if use_physics:
		hand = target
		root_node = hand.get_parent()
		hand.blocked.connect(_on_hand_blocked)
		hand.unblocked.connect(_on_hand_unblocked)
	else:
		root_node = target

func _on_hand_blocked() -> void:
	print("Hand blocked")
	root_node = hand

func _on_hand_unblocked() -> void:
	print("Hand unblocked")
	root_node = hand.get_parent()
