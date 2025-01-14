extends Node

var network := ENetMultiplayerPeer.new()
var port := 1911
var max_servers := 5


func _ready() -> void:
	StartServer()


func StartServer() -> void:
	network.create_server(port, max_servers)
	multiplayer.multiplayer_peer = network
	print("Authentication Server started")

	multiplayer.peer_connected.connect(_Peer_Connected)
	multiplayer.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(gateway_id):
	print("Gateway " + str(gateway_id) + " Connected")


func _Peer_Disconnected(gateway_id):
	print("Gateway " + str(gateway_id) + " Disconnected")


@rpc("any_peer", "reliable")
func gateway_to_authenticator_authenticate_player(player_id, _username, _password):
	print("auth request recived")
	var token
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	print("starting auth")
	if not NewScript.player_ids.has(_username):
		print("user not recognized")
		result = false
	else:
		if not NewScript.player_ids[_username].password == generate_hashed_password(_password, NewScript.player_ids[_username].salt):
			print("incorrect password")
			result = false
		else:
			print("succesful auth")
			result = true

			randomize()
			var random_number = randi()
			#print(random_number)
			var hashed = str(random_number).sha256_text()
			#print(hashed)
			var timestamp = str(int(Time.get_unix_time_from_system()))
			#print(timestamp)
			token = hashed + timestamp
			print(token)
			var gameserver = "GameServer1"
			GameServers.authenticator_to_server_DistributeLoginToken(token, gameserver)

	authenticator_to_gateway_authenticate_player(gateway_id, result, player_id, token)
	print("auth result sent to gateway")

@rpc("reliable")
func authenticator_to_gateway_authenticate_player(gateway_id, result, player_id, token):
	multiplayer.rpc(gateway_id, self, "authenticator_to_gateway_authenticate_player", [result, player_id, token])

@rpc("reliable", "any_peer")
func gateway_to_authenticator_create_account(_username, _password, player_id):
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	var message
	if NewScript.player_ids.has(_username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = generate_salt()
		var hashed_password = generate_hashed_password(_password, salt)
		NewScript.player_ids[_username] = {"password" : hashed_password, "salt" : salt}
	authenticator_to_gateway_create_account(result, player_id, gateway_id, message)
	print(NewScript.player_ids)

@rpc("reliable")
func authenticator_to_gateway_create_account(result, player_id, gateway_id, message):
	multiplayer.rpc(gateway_id, self, "authenticator_to_gateway_create_account", [result, player_id, message])

func generate_salt():
	randomize()
	var salt = str(randi()).sha256_text()
	return salt

func generate_hashed_password(_password, salt):
	var hashed_password = _password
	var rounds = pow(2, 18)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password
