extends Node
var serveraddress: String = "ws://sim.smogon.com:8000/showdown/websocket"
var socket = WebSocketPeer.new()
var connected = false
var message
var username
var loginusername
var loginpassword
var CHALLSTR
var rooms = []
var battleroom = preload("res://battlecontoller.tscn")
var ladder_formats = ["[Gen 9] Random Battle","[Gen 9] Unrated Random Battle"]
#var ladder_formats = []
var LadderFormatPicker 
# |/search gen9randombattle
#var showdebugmenu = true




func _ready():
	socket.connect_to_url(serveraddress)
	#var button = Button.new()
	#process_packet(">battle-693")
	#button.text = "Send"
	#button.pressed.connect(self._button_pressed)
	#add_child(button)
	#socket.connect_to_url("ws://libwebsockets.org")
	pass

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		connected = true
		while socket.get_available_packet_count():
			var textpacket = socket.get_packet().get_string_from_utf8()
			#print(socket.get_packet().get_string_from_utf8())
			#print("start of packet " + textpacket + " end of packet")
			#%RichTextLabel.text = str(%RichTextLabel.text + textpacket)
			#print("Packet: ", socket.get_packet())
			process_packet(textpacket)
			pass
	elif state == WebSocketPeer.STATE_CLOSING:
		connected = false
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		connected = false
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.

func process_packet(packet):
	var packetsplit = packet.split("|",false)
	var roomid
	var startofpacket
	
	startofpacket = packet[0]
	print("PRINTING PACKET SPLITS" + startofpacket + "end")
	if startofpacket == ">": # checking room rooms are prefixed with >
		roomid = packetsplit[0]
		roomid = roomid.right(-1)
		roomid = roomid.left(-1)
		print("roomid:" + roomid)
		if !rooms.has(roomid): # checks room array for roomid 
			print("array doesn't room id adding")
			if roomid.left(6) == "battle": # checks if its a battle room
				print("new room")
				var newroom = battleroom.instantiate()
				%"Control tab bar/TabContainer".add_child(newroom)
				rooms.append(roomid)
				rooms.append(newroom)
				#var roominstance = rooms.find(roomid) + 1
				#rooms[roominstance].roomid = roomid
				#rooms[roominstance].commandprefix = roomid + "|"
				#rooms[roominstance].name = roomid
				newroom.roomid = roomid
				newroom.commandprefix = roomid + "|"
				newroom.name = roomid
				newroom.username = username
				newroom.godnode = self
				#rooms.append(roomid)
				#rooms.append(newroom)
				print("ROOMS" + str(rooms))
		var roominstance = rooms.find(roomid) + 1
		rooms[roominstance].pass_room_data(packet)
	elif packetsplit[0] == "pm":
		print("Them pms")
	elif packetsplit[0] == "challstr":
			print("whole packet" + packet)
			CHALLSTR = packetsplit[1] + "|" + packetsplit[2]
	elif packetsplit[0] == "updateuser":
				username = packetsplit[1].right(-1)
				print("USERNAME:" + username)
				%USERNAME.text = username
	else: # put a loop here
		print(packet)
		#var packet_lines = packet.split("\n")
		#for line in packet:
		#	packetsplit = line.split("|",false,4)
		#	print(line)
			#if packetsplit[0] == "updateuser":
			#	username = packetsplit[1].right(-1)
			#	print("USERNAME:" + username)
			#	%USERNAME.text = username
			#elif packetsplit[0] == "formats": # doesn't exec since the first packet sent doesn't contain formats as the packet header but does have the formats the code needs to be rewriten
			#	print("formats")
			#	#%LadderFormatPicker.clear()
			#	#%LadderFormatPicker.add_item() loop this for each format
			#	pass


		
	#print("END OF PRINTING PACKET SPLITS")
	
	
func socketsendtext(text):
	if connected == true:
		socket.send_text(text)
	elif connected == false:
		print("not connected")
	print(text)

func _on_button_pressed():
	message = str(%TextEdit.text)
	%RichTextLabel.text = str(%RichTextLabel.text + message)
	%TextEdit.clear()
	socketsendtext(message)

func _on_line_edit_text_submitted(new_text):
	print("This is unused")
	pass # Replace with function body.


func _on_button_2_pressed():
	socketsendtext("|/accept zooki18")
	pass # Replace with function body.




func _on_search_game_pressed():
	print("|/search " + %LadderFormatPicker.get_item_text(LadderFormatPicker))
	
	#var 
	#var LadderFormatPicked = %LadderFormatPicker.get_item_at_position(new Vector2 LadderFormatPicker 0) # LadderFormatPicker.0, 0.0
	pass


func _on_ladder_format_picker_item_selected(index):
	LadderFormatPicker = index


func _on_login_entry_text_submitted(new_text): # TODO: Use "new_text" here instead of hard coded Username and password combos
	%login_entry.clear()
	#var body = "name=bunneracount123&pass=password&challstr=" + CHALLSTR + ""
	if loginusername == null:
		loginusername = new_text
		print("ented username " + new_text)
		%login_Label.text = "PASSWORD"
	else:
		if loginpassword == null:
			loginpassword = new_text
			print("ented password " + new_text)
			%login_Label.text = "USERNAME"
		var body = "name=" + loginusername + "&pass=" + loginpassword + "&challstr=" + CHALLSTR + ""
		print(body)
		var error =  $LoginRequester.request("https://play.pokemonshowdown.com/api/login", [], HTTPClient.METHOD_POST, body)
		if error != OK:
			push_error("An error occurred in the HTTP request.")


func _on_login_requester_request_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	response_text = response_text.erase(0,1)
	
	if response_code == 200:
		var json_parser = JSON.new()
		var json_result = json_parser.parse(response_text)
		print(json_result)
		if json_result != OK:
			push_error("JSON parsing error: " + json_result.error_string)
			return

		var json_dict = json_parser.data
		print(json_dict)
		if "curuser" in json_dict and json_dict.curuser.loggedin:
			#var username = "bunneracount123"
			var assertion = json_dict["assertion"]
			var message = "|/trn " + loginusername + ",0," + assertion
			socketsendtext(message)
			print("Login successful!")
			
		else:
			print("Login failed: " + str(json_dict))
	else:
		push_error("HTTP Error: " + str(response_code))
	loginusername = null
	loginpassword = null
