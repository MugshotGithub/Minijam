extends CharacterBody2D

#Ice slippy things
var isSlipping = false
var xVelo = 0
var facingLeft = false

#Rope swingy things
var rope = null
var ropePos = null
var ropeLen = 0;


var SPEED = 300.0 if rope == null else 600.0
var JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("AnimationPlayer")
@onready var _animated_sprite = $spaceman
@onready var dialogue_box = get_node("../DialogueBox")
@onready var dialogue_box_text = dialogue_box.get_node("PanelContainer").get_node("RichTextLabel")

var triggered_dialogue_box = [false,false,false,false,false]

func _process(_delta):
	print(position)
	if position.y < 3000: # this sucks and should be triggers. Too Bad!
		if position.x > -700 and position.x < -500 && triggered_dialogue_box[0] != true:
			dialogue_box_text.text = "I'm not sure I can make that jump."
			triggered_dialogue_box[0] = true
			dialogue_box.visible = true


func _physics_process(delta):

	if dialogue_box.visible:
		return
	
	if facingLeft && velocity.x > 0:
		self.transform *= Transform2D.FLIP_X
		facingLeft = false
	elif !facingLeft && velocity.x < 0:
		self.transform *= Transform2D.FLIP_X
		facingLeft = true
	
	if rope != null:
		_animated_sprite.frame = 3
		rope.set_point_position(1, to_local(ropePos))
		var rope_direction = Input.get_axis("up", "down")
		if rope_direction:
			if ropeLen + rope_direction*delta*800 > 20:
				ropeLen += rope_direction*delta*800
		if self.position.distance_to(ropePos) > ropeLen :
			var dirToRope = (ropePos - self.position).normalized()
			var clamped_position  = ropePos - dirToRope * min(ropeLen, self.position.distance_to(ropePos))
			self.position = clamped_position
	
	# Add the gravity.
	if not is_on_floor():
		if rope != null and not Input.is_action_just_pressed("jump"):
			# Apply a smaller gravity when on the rope and not jumping
			velocity.y = min(velocity.y + gravity * delta * 0.5, 400)
		else:
			velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and (is_on_floor() or rope != null):
		velocity.y = JUMP_VELOCITY
		if rope != null:
			rope.queue_free()
			rope = null
			_animated_sprite.frame = 4
		
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(self.position, Vector2(self.position.x, self.position.y+100))
	var result = space_state.intersect_ray(query)
	
	if result and is_on_floor():
		var collided_object = result.collider
		if collided_object is TileMap:
			var tilemap = collided_object
			var cellData = tilemap.get_cell_tile_data(0, tilemap.get_coords_for_body_rid (result.rid))
			var isRamp = cellData.get_custom_data("isRamp")
			if (isRamp):
				var dir = -1 if cellData.flip_h else 1
				if velocity.x == 0:
					xVelo = 0
				xVelo = clamp(xVelo + (dir*delta*gravity), -4*SPEED,4*SPEED)
			isSlipping = cellData.get_custom_data("slip")
			
				
			if isSlipping:
				velocity.x = xVelo
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if !isSlipping:
		if rope != null:
			if facingLeft and direction == 1:
				velocity.x *= -0.8
			elif !facingLeft and direction == -1:
				velocity.x *= -0.8
			if direction:
				velocity.x += direction * SPEED* delta
			
				
		else:
			if direction:
				anim.play("run")
				velocity.x = direction * SPEED 
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		velocity.x = xVelo
	if velocity.x != 0:
		xVelo = velocity.x

	
	# if rope != null and not Input.is_action_just_pressed("jump"):
	# 	velocity.y = min(velocity.y,400)

	move_and_slide()

	# print(velocity.y)


func _input(event):
	if event is InputEventMouseButton:
		if dialogue_box.visible:
			dialogue_box.visible = false
		if rope != null:
			rope.queue_free()
			rope = null
			_animated_sprite.frame = 4
		else:
			var space_state = get_world_2d().direct_space_state
			
			rope = Line2D.new()
			rope.set_name("Rope")
			add_child(rope)
			rope.add_point(Vector2(0,0),0)
			var query = PhysicsRayQueryParameters2D.create(self.position, get_global_mouse_position())
			var result = space_state.intersect_ray(query)
			if result:
				ropePos = result.position
				rope.add_point(to_local(ropePos),1)
				ropeLen = to_local(ropePos).distance_to(Vector2(0,0))
			else:
				rope.queue_free()
				rope = null
