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
