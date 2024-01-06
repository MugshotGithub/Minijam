extends StaticBody2D


var rope_length = 10
var segment_scene = preload("res://ropesegment.tscn")

func _ready():
	var previous_segment = null
	var rope_holder = self
	for i in range(rope_length):
		var segment = segment_scene.instantiate()
		rope_holder.add_child(segment)  # Add the segment as a child of the RopeHolder node
		if previous_segment == null:
			previous_segment = rope_holder
		
		var joint = PinJoint2D.new()
		previous_segment.add_child(joint)
		joint.node_a = previous_segment.get_path()
		joint.node_b = segment.get_path()
		previous_segment = segment
