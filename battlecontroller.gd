extends Control
var commandprefix = "|"
var roomid
var gamestate
var ultimate_enabled = false
var ultimate_state = ""
var opposing_mon = ""
var players = []
var username
var username_mask
var playerid
var godnode
var pokedict = {
	# example data "p1":{"shownmons":{"examplemon":{"moves":["MOVE","PP"]} }}
	#"p1":{"shownmons":{}}
	"p1":{"shownmons":{"examplemon":{"moves":["MOVE","PP"],"Health":"100/100"} }}
	#"moves":["MOVE","PP"]
	#"moves":{"movenames":[],"movepp":[]}
} # data needed to store playerid's, shown mons, mons nicknames, shown moves on said mons,
var pokeslotslowerobjects = [%PrimarySlot1, %PrimarySlot2]
var pokeslotshigherobjects = [%SecondarySlot1, %SecondarySlot2]
var pokeslots = [] # slot,assined label object 
var user_poke_slots = [] # plain list of slots ownned by user
var gametype
var healthbars = [] # slot,hp val
#var userslots # not username
var battletype = 0 # 0 = single battle, 1 = double battle, 2 triple battle 
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.
	
func write_to_log(text):
	%ChatLog.append_text(text)

#func grap_poke_dict():
func update_poke_dict(function,data):
	if function == "addplayer":
		pokedict[data] = '{"examplemon":{"moves":["MOVE","PP"],"Health":"100/100"}'
		#print(pokedict[data]["moves"])
		print(pokedict["p1"]["shownmons"])
	pass
#func update_poke_slots():
func update_healthbars(health,mon):
	print("health:" + health + "mon:" +  mon)
	#write_to_log("health:" + health + "mon:" +  mon + "\n")
	pass

func parse_line_by_line(packet):
	var packet_lines = packet.split("\n")
	var packetsplit
	for line in packet_lines:
		#print(line.length())
		print(line)
		#	if line[1] == ">":
		#		print("epic")
		packetsplit = line.split("|",true,4)
		if packetsplit.size() > 1:
			if packetsplit.size() > 2:
				if packetsplit.size() > 3:
					if packetsplit[1] == "player": # check if using player protocall
						if ! players.has(packetsplit[3]): # check if player is already in the player list
							if players.has(packetsplit[2]): # check if player is a 
								players[players.find(packetsplit[3]) - 1] = packetsplit[2]
							else:
								players.append(packetsplit[2])
								players.append(packetsplit[3])
								if packetsplit[3] == "username":
									username_mask = username
								print("PLAYERS:" + str(players))
								if !pokedict.has(packetsplit[2]):
									update_poke_dict("addplayer",packetsplit[2])
					elif packetsplit[1] == "c": # reuse for chat parsing same thing
						var chat_messege = packetsplit[2] + ": " + line.split("|",true,3)[3]  + "\n"
						print(chat_messege)
						write_to_log(chat_messege)
					elif packetsplit[1] == "move": # example data move|p1a: Regieleki|Tera Blast
						var split2data = packetsplit[2].split(":")
						#write_to_log(split2data[1].right(-1) + " Used " + packetsplit[3] + "\n") #WIP
						#players[players.find(split2data[0]) + 1]
						var mon_owner = split2data[0][0] + split2data[0][1]
						var mon_owner_username_id = players.find(mon_owner)
						if mon_owner_username_id != -1:
							mon_owner_username_id = mon_owner_username_id + 1
							if players[mon_owner_username_id] == username_mask:
								write_to_log(split2data[1].right(-1) + " Used " + packetsplit[3] + "\n")
							else:
								write_to_log("Opposing " + split2data[1].right(-1) + " Used " + packetsplit[3] + "\n") #WIP
							
						else:
							write_to_log(split2data[1] + " Used " + packetsplit[3] + "\n") #WIP
						
						#print("start of split1(of 3):" + packetsplit[1] + "\n")
						#print("start of split2(of 3):" + packetsplit[2] + "\n")
						#print("start of split3(of 3):" + packetsplit[3] + "\n")
					elif packetsplit[1] == "switch": # switch|p2a: Toxicroak|Toxicroak, L85, F|100/100
						var split2data = packetsplit[2].split(":")
						#print("PLAYER:" + split2data[0])
						#print("MON:" + split2data[1]
						if split2data[0] == "p1a":
							#$"p1a mon".text = split2data[1]
							
							pass
						elif split2data[0] == "p2a":
							#$"p2a mon".text = split2data[1]
							pass
						elif split2data[0] == "p1b" or split2data[0] == "p3b":
							#$"p1b_p3b mon".text = split2data[1]
							pass
						elif split2data[0] == "p2b" or split2data[0] == "p4b":
							#$"p2b_p4b mon".text = split2data[1]
							pass
						else:
							print("unsupported mon count")
							pass
						update_healthbars(packetsplit[4],split2data[0])
						var mon_owner = split2data[0][0] + split2data[0][1]
						var mon_owner_username_id = players.find(mon_owner)
						if mon_owner_username_id != -1:
							mon_owner_username_id = mon_owner_username_id + 1
							write_to_log(players[mon_owner_username_id] + " Sent out" + split2data[1] + "\n") #WIP
							# add check if users mon to say "Go MON_NAME_HERE"
						else:
							write_to_log(split2data[1] + " Used " + packetsplit[3] + "\n") #WIP
							write_to_log("Go "+ split2data[1] + "\n")
						
						
						print("start of split1(of 3):" + packetsplit[1] + "\n")
						print("start of split2(of 3):" + packetsplit[2] + "\n")
						print("start of split3(of 3):" + packetsplit[3] + "\n")
						pass
					elif packetsplit[1] == "-damage": # format of data -damage|p1a: Clefable|72/100
						var split2data = packetsplit[2].split(":")
						#showdown responce (Clefable lost 16.3% of its health!)
						write_to_log("(" + split2data[1].right(-1) + " lost " + " of it's health )\n")
					else:
						print("start of split1(of 3):" + packetsplit[1] + "\n")
						print("start of split2(of 3):" + packetsplit[2] + "\n")
						print("start of split3(of 3):" + packetsplit[3] + "\n")
							
				else:
					if packetsplit[1] == "turn":
						print("turn " + packetsplit[2] + "\n")
						write_to_log("turn " + packetsplit[2] + "\n")
					elif packetsplit[1] == "j": # reuse for chat
						print(packetsplit[2] + " joined.\n")
						write_to_log(packetsplit[2] + " joined.\n")
					elif packetsplit[1] == "l":
						print(packetsplit[2] + " left.\n")
						write_to_log(packetsplit[2] + " left.\n")
					elif packetsplit[1] == "tier":
						write_to_log("Format:\n" + packetsplit[2] + "\n")
						$".".name = packetsplit[2]
					elif packetsplit[1] == "faint": # example data |faint|p1a: Klawf
						var split2data = packetsplit[2].split(":")
						write_to_log(split2data[1].right(-1) + " fainted! \n") #WIP add "Opposing " Prefix if not in primery slot
					elif packetsplit[1] == "gametype":
						gametype = packetsplit[2]
					elif packetsplit[1] == "error":
						write_to_log(packetsplit[2] + "\n")
					else:
						print("start of split1(of 2):" + packetsplit[1] + "\n")
						print("start of split2(of 2):" + packetsplit[2] + "\n")
			elif packetsplit[1] == "deinit":
				print("exiting room")
				write_to_log("exiting room")
				var selfroom = godnode.rooms.find(roomid)
				print("self " + str(self) + " vs roomid " + roomid)
				print("PRE ROOMS" + str(godnode.rooms))
				godnode.rooms.remove_at(selfroom)
				godnode.rooms.remove_at(selfroom)
				print("ROOMS" + str(godnode.rooms))
				queue_free()
				
			else:
				print("start of split1(of 1):" + packetsplit[1] + "\n")
		pass
	#for i in range(packet.size):
		
func pass_room_data(packet):
	var packetsplit = packet.split("|",false,2)
	var packetmiddle = "null"
	if packetsplit.size() > 1:
		packetmiddle = packetsplit[1]
	if packetmiddle == "request":
		print("pasing json")
		if packetsplit.size() > 2:
			var packetend = packetsplit[2]
			passjson(packetend)# flaw assumes data is json and only works if packet size is limited to 3
	else:#if not json
		parse_line_by_line(packet)
	print("")
func passjson(jsontext):
	gamestate = JSON.parse_string(jsontext)
	print("called update... printing game state")
	if gamestate.has("active"):
		print(gamestate["active"][0])
		var ultimate_check = gamestate["active"][0]
		#print(gamestate["active"][0]["canTerastallize"])#
		if ultimate_check.has("canTerastallize"):
			ultimate_state = "terastallize"
			#%Label.Text = "Tera (" + ultimate_check["canTerastallize"] + ")"
			%Label.text = "Tera (" + ultimate_check["canTerastallize"] + ")"
			%CheckBox.show()
		elif ultimate_check.has("canMegaEvo"):
			ultimate_state = "mega"
			%CheckBox.show()
			%Label.text = "mega evo"
		elif ultimate_check.has("canDynamax"):
			ultimate_state = "max"
			%CheckBox.show()
			%Label.text = "Dynamax"
		elif ultimate_check.has("canZMove"):
			ultimate_state = "zmove"
			%CheckBox.show()
			%Label.text = "zmove (" + ultimate_check["zmove"] + ")"
			pass
		else:
			%Label.text = ""
			ultimate_state = ""
			%CheckBox.hide()
		print("again")
		var moveshortcut = gamestate["active"][0]["moves"]
		var move1 = moveshortcut[0]["move"] + " " + str(moveshortcut[0]["pp"]) + "/" + str(moveshortcut[0]["maxpp"])
		var move2 = moveshortcut[1]["move"] + " " + str(moveshortcut[1]["pp"]) + "/" + str(moveshortcut[1]["maxpp"])
		var move3 = moveshortcut[2]["move"] + " " + str(moveshortcut[2]["pp"]) + "/" + str(moveshortcut[2]["maxpp"])
		var move4 = moveshortcut[3]["move"] + " " + str(moveshortcut[3]["pp"]) + "/" + str(moveshortcut[3]["maxpp"])
		#var move1 = gamestate["active"][0]["moves"][0]["move"]
		#var move2 = gamestate["active"][0]["moves"][1]["move"]
		#var move3 = gamestate["active"][0]["moves"][2]["move"]
		#var move4 = gamestate["active"][0]["moves"][3]["move"]
		print(move1)
		print(move2)
		print(move3)
		print(move4)
		%move1.text = move1
		%move2.text = move2
		%move3.text = move3
		%move4.text = move4
		print("clean")
	else:
		if gamestate.has("forceSwitch"):
			if gamestate["forceSwitch"][0] == true:
				print("switch")
				#write_to_log("active mon dead pick new mon")
		#print(gamestate["forceSwitch"])
		pass
	var pokemon1 = gamestate["side"]["pokemon"][0]["ident"].right(-4)
	var pokemon1hp = gamestate["side"]["pokemon"][0]["condition"]
	var pokemon2 = gamestate["side"]["pokemon"][1]["ident"].right(-4)
	var pokemon2hp = gamestate["side"]["pokemon"][1]["condition"]
	var pokemon3 = gamestate["side"]["pokemon"][2]["ident"].right(-4)
	var pokemon3hp = gamestate["side"]["pokemon"][2]["condition"]
	var pokemon4 = gamestate["side"]["pokemon"][3]["ident"].right(-4)
	var pokemon4hp = gamestate["side"]["pokemon"][3]["condition"]
	var pokemon5 = gamestate["side"]["pokemon"][4]["ident"].right(-4)
	var pokemon5hp = gamestate["side"]["pokemon"][4]["condition"]
	var pokemon6 = gamestate["side"]["pokemon"][5]["ident"].right(-4)
	var pokemon6hp = gamestate["side"]["pokemon"][5]["condition"]
	
	#var pokemon7 = gamestate["side"]["pokemon"][6]["ident"]
	#print("POKEMON NAMES")
	#print(pokemon1)
	#print(pokemon2)
	#print(pokemon3)
	#print(pokemon4)
	#print(pokemon5)
	#print(pokemon6)
	#print("end of pokemon names")
	%"switch 1".text = pokemon1
	%"switch 2".text = pokemon2
	%"switch 3".text = pokemon3
	%"switch 4".text = pokemon4
	%"switch 5".text = pokemon5
	%"switch 6".text = pokemon6
	var pokemondetails1 = gamestate["side"]["pokemon"][0]["details"]
	var pokemondetails2 = gamestate["side"]["pokemon"][1]["details"]
	var pokemondetails3 = gamestate["side"]["pokemon"][2]["details"]
	var pokemondetails4 = gamestate["side"]["pokemon"][3]["details"]
	var pokemondetails5 = gamestate["side"]["pokemon"][4]["details"]
	var pokemondetails6 = gamestate["side"]["pokemon"][5]["details"]
	var poke1atk = gamestate["side"]["pokemon"][4]["stats"]["atk"]
	var poke1def = gamestate["side"]["pokemon"][4]["stats"]["def"]
	var poke1spa = gamestate["side"]["pokemon"][4]["stats"]["spa"]
	var poke1spd = gamestate["side"]["pokemon"][4]["stats"]["spd"]
	var poke1spe = gamestate["side"]["pokemon"][4]["stats"]["spe"]
	var poke1liststats = "atk " + str(poke1atk) + " def " + str(poke1def) + " spa " + str(poke1spa) + " spd " +  str(poke1spd) + " spe " + str(poke1spe)
	%"switch 1".tooltip_text = pokemondetails1 + "\n" +  pokemon1hp + "\n" + poke1liststats
	%"switch 2".tooltip_text = pokemondetails2 + "\n" +  pokemon2hp + "\n"
	%"switch 3".tooltip_text = pokemon3hp
	%"switch 4".tooltip_text = pokemon4hp
	%"switch 5".tooltip_text = pokemon5hp
	%"switch 6".tooltip_text = pokemon6hp

func sendcommand(command):
	print("start of command" + command + "end of command")
	var node = get_node("/root/Control")
	node.socketsendtext(command)
	#socketsendtext
	
	#send data to the main control node that then forwads the command
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func use_attack(attacknum):
	if ultimate_enabled == true:
		sendcommand(commandprefix + "/choose move " + str(attacknum) + " " + ultimate_state)
	else:
		sendcommand(commandprefix + "/choose move " + str(attacknum))

func _on_start_battle_pressed():
	sendcommand("|/accept zooki18")
	pass # Replace with function body.


func _on_move_1_pressed():
	use_attack(1)
	pass # Replace with function body.


func _on_move_2_pressed():
	use_attack(2)
	pass # Replace with function body.


func _on_move_3_pressed():
	use_attack(3)
	pass # Replace with function body.


func _on_move_4_pressed():
	use_attack(4)
	pass # Replace with function body.


func _on_line_edit_text_submitted(new_text):
	sendcommand(commandprefix + new_text)
	%LineEdit.clear()
	%ChatLog.append_text(new_text)
	pass # Replace with function body.

func switch_mon(switchnum):
	%CheckBox.button_pressed = false
	sendcommand(commandprefix + "/choose switch " + str(switchnum))

func _on_switch_1_pressed():
	switch_mon(1)
	pass # Replace with function body.


func _on_switch_2_pressed():
	switch_mon(2)
	pass # Replace with function body.


func _on_switch_3_pressed():
	switch_mon(3)
	pass # Replace with function body.


func _on_switch_4_pressed():
	switch_mon(4)
	pass # Replace with function body.


func _on_switch_5_pressed():
	switch_mon(5)
	pass # Replace with function body.


func _on_switch_6_pressed():
	switch_mon(6)
	pass # Replace with function body.


func _on_undo_pressed():
	sendcommand(commandprefix + "/choose undo")
	pass # Replace with function body.

func passjsonreturn(jsontext):
	var jsonpass = JSON.parse_string(jsontext)
	return jsonpass

func _on_print_game_state_pressed():
	print("printing game state")
	if gamestate.has("active"):
		var ultimate_check = gamestate["active"][0]
		print(gamestate["active"][0])#
		if ultimate_check.has("canTerastallize"):
			print("yes tera")
		elif ultimate_check.has("canMegaEvo"):
			print("yes mega")
		else:
			print("no tera/mega/zmove")
		pass
	else:
		print("Game state doesn't have active lol")
	if gamestate.has("side"):
		#print("gamestate sides")
		#print(gamestate["side"])
		#print("gamestate sides pokemon")
		#print(gamestate["side"]["pokemon")
		#%"switch 5" = gamestate["side"]["pokemon"][5]
		pass



func _on_check_box_toggled(button_pressed):
	ultimate_enabled = !ultimate_enabled
	#if ultimate_state == "":
	#	%CheckBox.hide()
	#%CheckBox.button_pressed = ultimate_enabled
	print("ultimate_state toggled to " + str(ultimate_enabled))
	pass # Replace with function body.
