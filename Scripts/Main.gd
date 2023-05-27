@tool
extends Node3D
class_name Root_Node

var chunks = {}
var unready_chunks = {}
var thread
var player_position
var debug_text

var noise
@export var chunk_size : int = 128
@export var chunk_height : int = 32
@export var chunk_amount : int = 16
@export var seed : int = 148
@export var elevationCurve : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	thread = Thread.new()
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.NoiseType.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 4
	noise.seed = seed  # Use a common seed value

func add_chunk(x, z):
	var key = str(x) + "," + str(z)
	if chunks.has(key) or unready_chunks.has(key):
		return
	
	if not thread.is_started():
		var callable = Callable(self, "load_chunk")
		callable.call([thread, x, z])
		thread.start(callable)
		unready_chunks[key] = 1

# Adjusted function to pass noise to Chunk
func load_chunk(arr):
	var thread = arr[0]
	var x = arr[1]
	var z = arr[2]
	
	var chunk = Chunk.new(noise, x * chunk_size, z * chunk_size, chunk_size, chunk_height, elevationCurve)
	chunk.position = Vector3(x * chunk_size, 0, z * chunk_size)	
	call_deferred("load_done", chunk, thread)

func load_done(chunk, thread):
	add_child(chunk)
	var key = str(chunk.x / chunk_size) + "," + str(chunk.z / chunk_size)
	chunks[key] = chunk
	unready_chunks.erase(key)
	thread.wait_to_finish()

func get_chunk(x, z):
	var key = str(x) + "," + str(z)
	
	if chunks.has(key):
		return chunks.get(key)
		
	return null

func _process(delta):
	player_position = $Player.position
	update_chunks()
	clean_up_chunks()
	reset_chunks()
	debug()

func _input(event):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func update_chunks():
	var p_x = int(player_position.x) / chunk_size
	var p_z = int(player_position.z) / chunk_size
	
	for x in range(p_x - chunk_amount * 0.5, p_x + chunk_amount * 0.5):
		for z in range(p_z - chunk_amount * 0.5, p_z + chunk_amount * 0.5):
			add_chunk(x, z)
			var chunk = get_chunk(x, z)
			if chunk != null:
				chunk.should_remove = false

func clean_up_chunks():
	for key in chunks:
		var chunk = chunks[key]
		if chunk.should_remove:
			chunk.queue_free()
			chunks.erase(key)

func reset_chunks():
	for key in chunks:
		chunks[key].should_remove = true

func debug():
	debug_text = "Position:" + str(player_position)
	$Player/DebugLabel.set_text(debug_text)

