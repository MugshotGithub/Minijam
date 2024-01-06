extends StaticBody2D


var rope_length = 5
var segment_scene = preload("res://ropesegment.tscn")
var segment_y_offset = 35  # The amount to offset the y position by
var joint_y_offset = 5  # The amount to offset the y position by

func _ready():
	var previous_segment = null
	var rope_holder = self
	for i in range(rope_length):
		var segment = segment_scene.instantiate()
		segment.position.y += i * segment_y_offset  # Offset the y position
		rope_holder.add_child(segment)  # Add the segment as a child of the RopeHolder node
		var joint
		if previous_segment == null:
			previous_segment = rope_holder
		joint = PinJoint2D.new()
		joint.softness = 1.0
		previous_segment.add_child(joint)
		joint.position.y += i * joint_y_offset
		joint.node_a = previous_segment.get_path()
		joint.node_b = segment.get_path()
		previous_segment = segment
