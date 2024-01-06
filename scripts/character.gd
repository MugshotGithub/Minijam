extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


#Ice slippy things
var isSlipping = false
var xVelo = 0
var facingLeft = true

#Rope swingy things
var rope = null
var ropePos = null
var ropeLen = 0;


func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(self.position, Vector2(self.position.x, self.position.y+100))
	var result = space_state.intersect_ray(query)
	
	if result and is_on_floor():
		var collided_object = result.collider
		if collided_object is TileMap:
			var tilemap = collided_object
			var cellData = tilemap.get_cell_tile_data(0, tilemap.get_coords_for_body_rid (result.rid))
			isSlipping = cellData.get_custom_data("slip")
			var isRamp = cellData.get_custom_data("isRamp")
			if (isRamp):
				var dir = -1 if cellData.flip_h else 1
				xVelo = clamp(xVelo + (dir*delta*gravity), -4*SPEED,4*SPEED)
				
			if isSlipping:
				velocity.x = xVelo
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if !isSlipping:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
	else:
		velocity.x = xVelo
	if velocity.x != 0:
		xVelo = velocity.x
	
	if facingLeft && velocity.x > 0:
		self.transform *= Transform2D.FLIP_X
		facingLeft = false
	elif !facingLeft && velocity.x < 0:
		self.transform *= Transform2D.FLIP_X
		facingLeft = true

	
	move_and_slide()
	
	if rope != null:
		rope.set_point_position(1, to_local(ropePos))
		var rope_direction = Input.get_axis("up", "down")
		if rope_direction:
			ropeLen += rope_direction*delta
		if self.position.distance_to(ropePos) > ropeLen :
			print("------------------")
			#print(ropeLen)
			print(to_global((to_local(self.position) - to_local(ropePos)).normalized() * ropeLen))
			print((to_local(self.position) - to_local(ropePos)).normalized() * ropeLen)
			print(self.position)
			#self.position = to_global((self.position - ropePos).normalized() * ropeLen)
			


func _input(event):
	if event is InputEventMouseButton:
		if rope != null:
			rope.queue_free()
			rope = null
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
