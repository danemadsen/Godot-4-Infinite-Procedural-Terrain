extends Node
class_name NoiseHelper

var base
var climate_map
var biome_map
var mountains
var taiga
var planes
var mesa
var desert
var basebiome

var climate_cold
var climate_cool
var climate_warm
var climate_hot

func _init(n_seed):
	randomize()
	self.base = FastNoiseLite.new()
	self.base.noise_type = FastNoiseLite.TYPE_SIMPLEX
	self.base.seed = n_seed
	self.base.frequency = 0.005
	self.base.fractal_type = FastNoiseLite.FRACTAL_FBM
	self.base.fractal_octaves = 5
	self.base.fractal_lacunarity = 2.5
	self.base.fractal_gain = 0.6
	self.base.fractal_weighted_strength = 1
	self.basebiome = Biome.new("Base", base)
	
	self.climate_map = FastNoiseLite.new()
	self.climate_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	self.climate_map.seed = n_seed + 1
	self.climate_map.frequency = 0.001
	
	self.biome_map = FastNoiseLite.new()
	self.biome_map.noise_type = FastNoiseLite.TYPE_CELLULAR
	self.biome_map.seed = n_seed + 2
	self.biome_map.frequency = 0.005
	self.biome_map.fractal_type = FastNoiseLite.FRACTAL_NONE
	self.biome_map.cellular_distance_function = FastNoiseLite.DISTANCE_HYBRID
	self.biome_map.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	self.biome_map.cellular_jitter = 1
	self.biome_map.domain_warp_enabled = true
	self.biome_map.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	self.biome_map.domain_warp_amplitude = 15
	self.biome_map.domain_warp_frequency = 0.015
	self.biome_map.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_INDEPENDENT
	self.biome_map.domain_warp_fractal_octaves = 5
	self.biome_map.domain_warp_fractal_lacunarity = 2.5
	self.biome_map.domain_warp_fractal_gain = 0.5
	
	var noise
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = n_seed + 3
	noise.frequency = 0.01
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 2.5
	noise.fractal_gain = 0.5
	noise.fractal_weighted_strength = 0.9
	noise.domain_warp_enabled = true
	noise.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	noise.domain_warp_amplitude = 20
	noise.domain_warp_frequency = 0.005
	self.mountains = Biome.new("Mountain", noise)
	
	self.climate_hot = Climate.new("Hot", basebiome, basebiome, basebiome, basebiome)
	#self.climate_warm = Climate.new(0.35, base, base, base, base)
	#self.climate_cool = Climate.new(-0.35, base, base, base, base)
	self.climate_cold = Climate.new("Cold", mountains, mountains, mountains, mountains)
	

func get_weight(temperature, offset):
	var temp = (temperature + 1) * 50
	var weight = -(((int(floor(temp)) + offset) * 2) ^ 2 + 1)
	if(weight < 0):
		return 0
	else:
		return weight

func get_climate(vertex, x, z):
	if (get_weight(climate_map.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z), -50) != 0):
		return climate_cold
	else:
		return climate_hot

func get_player_climate(x, z):
	if (get_weight(climate_map.get_noise_3d(x, 0, z), -50) != 0):
		return climate_cold
	else:
		return climate_hot
