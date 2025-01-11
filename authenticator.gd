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
	elif not NewScript.player_ids[_username].password == _password:
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
