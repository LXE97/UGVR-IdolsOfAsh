extends ClimberRopeVisual

var scale_radius : float = 1.0

func createGrapplePointVisual(rope: Node) -> Node3D:
	var grapplePointScene = load("res://scenes/grapple_point_visual.tscn");
	var newGrapplePoint = grapplePointScene.instantiate() as Node3D;
	rope.get_tree().current_scene.add_child(newGrapplePoint);
	newGrapplePoint.visible = false;
	newGrapplePoint.scale = Vector3(scale_radius, scale_radius, 1.0)
	return newGrapplePoint;
