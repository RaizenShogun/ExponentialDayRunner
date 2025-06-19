extends Node

#preload obstacles
var Enem1_scene = preload("res://Scenes/Enem1.tscn")
var Enem2_scene = preload("res://Scenes/Enem2.tscn")
var Enem3_scene = preload("res://Scenes/Enem3.tscn")
var Drone_scene = preload("res://Scenes/Drone.tscn")
var obstacle_types := [Enem1_scene, Enem2_scene, Enem3_scene]
var obstacles : Array
var Drone_heights := [200, 390]

#game variables
const PC1_START_POS:= Vector2i(150, 485)
const CAM_START_POS:= Vector2i(576, 324)
var difficulty 
const MAX_DIFFICULTY: int = 2
var score:int
const SCORE_MODIFIER: int = 10
var speed:float
const START_SPEED:float = 10.0
const MAX_SPEED:int = 25
const SPEED_MODIFIER: int = 5000
var screen_size:Vector2i
var ground_height: int
var game_running : bool
var last_obs

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()

func init_bg(a, b, c, d):
	var city = randi_range(1, 8)
	var layer1sprite = Sprite2D.new()
	layer1sprite.texture = load("res://city "+str(city)+"/"+str(a)+".png")
	layer1sprite.position = Vector2(0, 50)
	$BG/ParallaxLayer.add_child(layer1sprite)
	$BG/ParallaxLayer.motion_mirroring.x = 576 *$BG/ParallaxLayer.scale.x
	
	var layer2sprite = Sprite2D.new()
	layer2sprite.texture = load("res://city "+str(city)+"/"+str(b)+".png")
	layer2sprite.position = Vector2(0, 100)
	$BG/ParallaxLayer2.add_child(layer2sprite)
	$BG/ParallaxLayer2.motion_mirroring.x = 576 *$BG/ParallaxLayer2.scale.x
	
	var layer3sprite = Sprite2D.new()
	layer3sprite.texture = load("res://city "+str(city)+"/"+str(c)+".png")
	layer3sprite.position = Vector2(0, 150)
	$BG/ParallaxLayer3.add_child(layer3sprite)
	$BG/ParallaxLayer3.motion_mirroring.x = 576 *$BG/ParallaxLayer3.scale.x
	
	var layer4sprite = Sprite2D.new()
	layer4sprite.texture = load("res://city "+str(city)+"/"+str(d)+".png")
	layer4sprite.position = Vector2(0, 200)
	$BG/ParallaxLayer4.add_child(layer4sprite)
	$BG/ParallaxLayer4.motion_mirroring.x = 576 *$BG/ParallaxLayer4.scale.x
	
	$BG/Sprite2D.texture = load("res://city "+str(city)+"/1.png")

func new_game():
	#reset variables
	init_bg(5, 4, 3, 2)
	score = 0
	show_score()
	game_running = false
	difficulty = 0
	
#reset the nodes
	$PC1.position = PC1_START_POS
	$PC1.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

#reset hud and game over screen
	$HUD.get_node("StartLabel").show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		#speed up and adjust difficulty
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()		
		
		#generate obstacles
		generate_obs()
				
		#move player and camera
		$PC1.position.x += speed
		$Camera2D.position.x += speed

	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()
	
	#Update score
	score += speed
	show_score()
	 
	print(score) 

#update ground position
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x

func generate_obs():
	#generate ground obstacles
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

func show_score():
	$HUD.get_node("ScoreLabel").text = "Score: " + str(score / SCORE_MODIFIER)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
