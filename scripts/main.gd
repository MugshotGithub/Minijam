extends Node2D

var rope_length = 10
var segment_scene = preload("res://ropesegment.tscn")

func _ready():
	var previous_segment = null
	var rope_holder = get_node("RopeHolder")  # Get a reference to the RopeHolder node
	for i in range(rope_length):
		var segment = segment_scene.instantiate()
		rope_holder.add_child(segment)  # Add the segment as a child of the RopeHolder node
		print('ad')
		if previous_segment:
			var joint = PinJoint2D.new()
			previous_segment.add_child(joint)
			joint.node_a = previous_segment.get_path()
			joint.node_b = segment.get_path()
		previous_segment = segment
