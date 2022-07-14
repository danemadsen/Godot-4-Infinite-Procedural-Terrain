extends Node
class_name NoiseMaps

var base
var climate_map
var biome_map

func _init(seed):
	randomize()
	self.base = FastNoiseLite.new()
	self.base.noise_type = FastNoiseLite.TYPE_SIMPLEX
	self.base.seed = seed
	self.base.frequency = 0.005
	self.base.fractal_octaves = 5
	self.base.fractal_lacunarity = 2.5
	self.base.fractal_gain = 0.6
	self.base.fractal_weighted_strength = 1
	
	self.climate_map = FastNoiseLite.new()
	self.climate_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	self.climate_map.seed = seed + 1
	self.climate_map.frequency = 0.001
	
	self.biome_map = FastNoiseLite.new()
	self.biome_map.noise_type = FastNoiseLite.TYPE_CELLULAR
	self.biome_map.seed = seed + 2
	self.biome_map.frequency = 0.005
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
	

