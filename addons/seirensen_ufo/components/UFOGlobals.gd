extends Node
# Global in charge of UFO functions.
# Not needed to add if there is no intention to transfer progression to other levels.

enum UFO_COLOR {
	Red = 0,
	Green = 1,
	Blue = 2
}

# Check if the data field exists.
# If it does not, set the groundwork.
func ufo_value_check_and_reset() -> void:
	if !ProfileManager.current_profile.data.has(&"ufo_value"):
		ufo_data_reset()

# Red: 0, Green: 1, Blue: 2
func ufo_data_add(ufo_value: int) -> void:
	ufo_value_check_and_reset()
	var ufo_array: Array = ProfileManager.current_profile.data.ufo_value
	
	# If the array is already full, this will add nothing to it.
	if ufo_array.size() >= 3: return
	
	# Check if it'll be the third UFO.
	if ufo_array.size() == 2:
		# Tricolor pattern is checked first (none of the UFOs can match).
		# Same color pattern is checked after that (third UFO different).
		if ((ufo_array[0] != ufo_array[1] and ufo_array.has(ufo_value))
			or (ufo_array[0] == ufo_array[1] and ufo_array[1] != ufo_value)):
			ProfileManager.current_profile.data.ufo_value.pop_at(0)
	
	ProfileManager.current_profile.data.ufo_value.append(ufo_value)

# Completely reset the UFO data.
func ufo_data_reset() -> void:
	ProfileManager.current_profile.data.ufo_value = []

func ufo_data_get() -> Array:
	ufo_value_check_and_reset()
	return ProfileManager.current_profile.data.ufo_value
