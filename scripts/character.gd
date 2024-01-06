extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# RayCast2D to detect the terrain beneath the character
var raycast : RayCast2D

func _ready():
	# Initialize the RayCast2D
	raycast = $RayCast2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var isSlipping = false
	
	var query = PhysicsRayQueryParameters2D.create(Vector2(self.position.x, self.position.y), Vector2(self.position.x, self.position.y+43))
	var result = space_state.intersect_ray(query)
	if result:
		
		var collided_object = result.collider
		if collided_object is TileMap:
			var tilemap = collided_object
			var cellData = tilemap.get_cell_tile_data(0, tilemap.get_coords_for_body_rid (result.rid))
			isSlipping = cellData.get_custom_data("slip")
			isRamp = cellData.get_custom_data("isRamp")
	
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
