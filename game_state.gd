extends Node

var current_map: String = ""

var player_position: Vector2
var player_direction: Vector2i

var current_time: int = 0
var current_weather: Weather = Weather.CLEAR
var weather_change = current_time + 20 #50

func set_current_weather() -> void:
	if current_time < weather_change:
		return
	if current_weather == Weather.CLEAR:
		current_weather = Weather.RAINING
		print("YAY ITS RAININ BITCHES" , current_weather)
	elif current_weather == Weather.RAINING:
		current_weather = Weather.CLEAR
		print("DAMN NO MORE BITCHES" , current_weather)
	weather_change = current_time + 20 #50

func get_current_weather() -> Weather:
	return current_weather

enum Weather {
	CLEAR, 
	RAINING
}
