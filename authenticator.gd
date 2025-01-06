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
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	print("starting auth")
	if not NewScript.player_ids.has(_username):
		print("user not recognized")
		result = false
	elif not NewScript.player_ids[_username] == _password:
		print("incorrect password")
		result = false
	else:
		print("succesful auth")
		result = true
	print("auth result sent to gatewa")
	authenticator_to_gateway_authenticate_player(gateway_id, result, player_id)

@rpc("reliable")
func authenticator_to_gateway_authenticate_player(gateway_id, result, player_id):
	multiplayer.rpc(gateway_id, self, "authenticator_to_gateway_authenticate_player", [result, player_id])
