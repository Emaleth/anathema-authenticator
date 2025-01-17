extends Node


var data := {}


func _ready() -> void:
	load_account_database()
	print(data)


func save_account_database():
	var data_file = FileAccess.open("user://account_database.json", FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	data_file.store_line(json_string)


func load_account_database():
	if not FileAccess.file_exists("user://account_database.json"):
		print("no account database file found!")
		return
	var data_file = FileAccess.open("user://account_database.json", FileAccess.READ)
	while data_file.get_position() < data_file.get_length():
		var json_string = data_file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		else:
			data = json.data
