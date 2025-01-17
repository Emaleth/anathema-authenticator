extends Node

var network := ENetMultiplayerPeer.new()
var gateway_api := MultiplayerAPI.create_default_interface()
var port := 1912
var max_players := 100

var gameserverlist = {}

func _ready() -> void:
	StartServer()

func _process(_delta: float) -> void:
	if not gateway_api.has_multiplayer_peer():
		return
	gateway_api.poll()


func StartServer() -> void:
	network.create_server(port, max_players)
	get_tree().set_multiplayer(gateway_api, self.get_path())
	gateway_api.multiplayer_peer = network
	print("GameServerHub started")

	gateway_api.peer_connected.connect(_Peer_Connected)
	gateway_api.peer_disconnected.connect(_Peer_Disconnected)


func _Peer_Connected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Connected")
	gameserverlist["GameServer1"] = gameserver_id
	print(gameserverlist)

func _Peer_Disconnected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Disconnected")

@rpc("reliable")
func authenticator_to_server_DistributeLoginToken(token, gameserver, uuid):
	var gameserver_peer_id = gameserverlist[gameserver]
	gateway_api.rpc(gameserver_peer_id, self, "authenticator_to_server_DistributeLoginToken", [token, uuid])
